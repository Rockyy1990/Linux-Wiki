#!/bin/bash

# Skript für die Installation von Arch Linux mit UEFI, btrfs für die Root-Partition und xfs für die /home-Partition.
# Installiert werden der Linux-Zen Kernel mit Firefox, Thunderbird, VLC sowie andere nützliche Programme und Grafiktreiber.
# Angelegt werden ein User namens lxadmin samt wheel und video Gruppe.

# Setze die Variablen
HOSTNAME="archlinux"
USERNAME="lxadmin"
PASSWORD="dein_passwort" # Ändere dies zu einem sicheren Passwort

# Partitionierung
parted /dev/sda mklabel gpt
parted /dev/sda mkpart primary fat32 1MiB 512MiB
parted /dev/sda mkpart primary btrfs 512MiB 100%

# 2. Festplatte mit xfs für /home
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart primary xfs 1MiB 100%

# UEFI Partition formatieren
mkfs.fat -F32 /dev/sda1
# Root Partition formatieren mit btrfs
mkfs.btrfs /dev/sda2
# home Partition formatieren mit xfs
mkfs.xfs /dev/sdb1

# Mounten der Partitionen
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Btrfs Subvolumes erstellen
btrfs subvolume create /mnt/@

# Subvolumes mounten
umount /mnt
mount -o subvol=@ /dev/sda2 /mnt
mkdir /mnt/home
# Mount der XFS Partition für /home
mount /dev/sdb1 /mnt/home

# Temporäre Verzeichnisse im tmpfs einrichten (optional)
# mkdir -p /mnt/tmp
# mount -t tmpfs tmpfs /mnt/tmp

# Basis Installation
pacstrap /mnt base base-devel linux-zen linux-firmware snap-pac snapper udisks2-btrfs bash-completion nano

# Fstab generieren
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot in das neue System
arch-chroot /mnt /bin/bash <<EOF

# Zeitzone setzen
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

# Locale setzen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=de_DE.UTF-8" > /etc/locale.conf

# Hostname setzen
echo "$HOSTNAME" > /etc/hostname

# Netzwerkkonfiguration
cat <<EOL >> /etc/hosts
127.0.0.1 localhost
::1 localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
EOL

# Root Passwort setzen
echo "root:dein_passwort" | chpasswd

# Benutzer anlegen
useradd -m -G wheel,video $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

# Installiere Pakete
pacman -Syu --needed --noconfirm grub grub-btrfs efibootmgr xorg-server xorg-xinit xorg-xauth xfce4 mousepad xfce4-terminal \
lightdm lightdm-gtk-greeter vlc firefox thunderbird file-roller ufw mesa mesa-utils vulkan-mesa-layers vulkan-icd-loader \
pipewire pavucontrol alsa-utils alsa-firmware pipewire-alsa pipewire-pulse gst-plugins-pipewire wireplumber \
networkmanager network-manager-applet git htop wget curl ttf-dejavu ttf-liberation \
ranger feh maim xclip xdotool brightnessctl lame flac ffmpeg \
# Grafikkartentreiber
xf86-video-intel xf86-video-amdgpu xf86-video-ati xf86-video-nouveau xf86-video-vesa \


# GRUB installieren
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# LightDM aktivieren
systemctl enable lightdm.service

# NetworkManager aktivieren
systemctl enable NetworkManager.service

# UFW aktivieren
systemctl enable ufw.service

# Beende chroot
EOF

# Unmounten der Partitionen
umount -R /mnt

echo "Installation abgeschlossen! Starte das System neu."
