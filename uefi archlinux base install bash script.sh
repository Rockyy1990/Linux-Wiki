#!/bin/bash

# Skript für die Installation von Arch Linux mit UEFI, ext4 und xfs /home Partition.
# Installiert werden der Linx-Zen Kernel mit Firefox, Thunderbird, Vlc sowie andere nützliche Programme und Grafiktreiber.
# Angelegt werden ein User namens lxadmin samt wheel und video Gruppe.

# Setze die Variablen
HOSTNAME="archlinux"
USERNAME="lxadmin"
PASSWORD="dein_passwort" # Ändere dies zu einem sicheren Passwort

# Partitionierung
parted /dev/sda mklabel gpt
parted /dev/sda mkpart primary fat32 1MiB 512MiB
parted /dev/sda mkpart primary ext4 512MiB 20GiB
parted /dev/sda mkpart primary xfs 20GiB 100%

# UEFI Partition formatieren
mkfs.fat -F32 /dev/sda1
# Root Partition formatieren
mkfs.ext4 /dev/sda2
# Home Partition formatieren
mkfs.xfs /dev/sda3

# Mounten der Partitionen
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
mkdir /mnt/home
mount /dev/sda3 /mnt/home

# Temporäre Verzeichnisse im tmpfs einrichten
mkdir -p /mnt/tmp
mount -t tmpfs tmpfs /mnt/tmp

# Basis Installation
pacstrap /mnt base base-devel linux-zen linux-firmware nano

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
pacman -Syu --needed --noconfirm grub efibootmgr xorg-server xorg-xinit xorg-xauth xfce4 mousepad xfce4-terminal \
lightdm lightdm-gtk-greeter vlc firefox thunderbird file-roller ufw mesa mesa-utils \
pipewire pavucontrol alsa-utils alsa-firmware pipewire-alsa pipewire-pulse gst-plugins-pipewire wireplumber \
networkmanager network-manager-applet git htop wget curl ttf-dejavu ttf-liberation \
gvim ranger feh maim xclip xdotool brightnessctl \
# Grafikkartentreiber
xf86-video-intel xf86-video-amdgpu xf86-video-ati xf86-video-nouveau xf86-video-vesa

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