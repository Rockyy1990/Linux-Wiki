
 Beispielkonfiguration NixOS
 
 (/etc/nixos/configuration.nix)

 Die configuration.nix ist die zentrale Konfigurationsdatei für NixOS, ein Linux-basiertes Betriebssystem, das auf dem Nix-Paketmanager basiert. 
 In dieser Datei werden Systemdienste, Benutzer, Pakete und andere Systemparameter in einer deklarativen Syntax definiert, 
 was eine reproduzierbare und konsistente Systemkonfiguration ermöglicht.
 
 
 Basic Commands:

 Switch / Upgrade Stable Channel or change to unstable channel

 # List avaiable channels
 nix-channel --list

 sudo nix-channel --add https://nixos.org/channels/nixos-23.05 nixos

 # Unstable latest packages
 sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos

 # After adding a channel update them for fetch the packages
 sudo nix-channel --update

 sudo nixos-rebuild switch --upgrade



 # Enable changes from configuration.nix and installs NixOS
 sudo nixos-rebuild switch

 sudo nixos-rebuild test

 sudo nixos-rebuild switch --rollback


 # This command will remove all old generations of your NixOS system that are no longer referenced by the current system.
 sudo nix-collect-garbage


 # Package search over terminal
 nix search <Paketname>

 # Remove older generations from the bootloader
 sudo nix-collect-garbage --delete-older-than 14d
 sudo nixos-rebuild boot


--------------------------------------------------------------------------------------------------------


{ config, pkgs, lib, ... }:


  # Kernel and the gpu driver 
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = ["amdgpu"];
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.deviceSection = ''Option "TearFree" "true"''; # For amdgpu.


# Use the GRUB 2 boot loader.
  boot.loader = {
	efi = {
		canTouchEfiVariables = true;
		efiSysMountPoint = "/boot/efi";
	};
	grub = {
		enable = true;
	  	device = "nodev"; # or "nodev" for efi only
		efiSupport = true;
	  };
  };	
  


 # Installs the kernel for nixos
  boot.kernelPackages = pkgs.linuxPackages_latest; 
  #boot.kernelPackages = pkgs.linuxPackages_zen;
  #boot.kernelPackages = pkgs.linuxPackages_lqx;

  # If you want to install the LTS kernel as well, you can add it to the environment.systemPackages
  environment.systemPackages = with pkgs; [
    linuxPackages.lts
  ];

 
  # Enable TRIM for SSDs
  services.fstrim.enable = true;

 fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];


 # Enable automatic store optimization
 nix.optimise.automatic = true;

 # Nix automatically detects files in the store that have identical contents, and replaces them with hard links to a single copy. This saves disk space
 nix.settings.auto-optimise-store = true;



# Setze die maximale Anzahl der Generationen

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.maxGenerations = 10;  # Setze die maximale Anzahl der Generationen
  
  # Konfiguriere den Upgrade-Zeitplan

  system.autoUpgrade.schedule = {
    # Setze den Zeitplan auf alle 10 Tage
    # Hier wird ein Cron-ähnlicher Zeitplan verwendet
    # "0 0 */10 * *" bedeutet jeden 10. Tag um Mitternacht
    # Du kannst dies anpassen, um es nach deinen Bedürfnissen zu ändern
    cron = "0 0 */10 * *";
  };

 alternativ:
 sudo crontab -e
 0 0 */10 * * nixos-rebuild switch --upgrade



# Pipewire
# Remove sound.enable or set it to false if you had it set previously, as sound.enable is only meant for ALSA-based configurations
# rtkit is optional but recommended
services.pulseaudio.enable = false;
security.rtkit.enable = true;
services.pipewire = {
  enable = true;
  #alsa.enable = true;
  #alsa.support32Bit = true;
  pulse.enable = true;
  # If you want to use JACK applications, uncomment this
  #jack.enable = true;
};


   # Custom PulseAudio configuration
    daemonConfig = ''
      # Config for better sound quality
      daemonize = no
      cpu-limit = no
      high-priority = yes
      nice-level = -11
      realtime-scheduling = yes
      realtime-priority = 5
      resample-method = speex-float-10
      avoid-resampling = false
      enable-remixing = no
      rlimit-rtprio = 9
      default-sample-format = float32le
      default-sample-rate = 96000
      alternate-sample-rate = 48000
      default-sample-channels = 2
      default-channel-map = front-left,front-right
      default-fragments = 2
      default-fragment-size-msec = 125
    '';
 

  
  
  
  
  # Set custom DNS servers (both IPv4 and IPv6)
  networking.nameservers = [
    "1.1.1.1"  # Example IPv4 DNS
    "8.8.8.8"  # Example IPv4 DNS
    "2001:4860:4860::8888"  # Google Public DNS IPv6
    "2606:4700:4700::1111"  # Cloudflare DNS IPv6
  ];

  # Optional: If you want to use systemd-resolved
  # services.systemd.resolved.enable = true;
  # networking.resolvconf.enable = true; # Enable resolvconf if needed


  


  # Enable the X11 windowing system
  services.xserver.enable = true;
  
  # Enable libinput
  services.libinput.enable = true;

  
  # Enable the XFCE desktop environment
  services.xserver.desktopManager.xfce.enable = true;

  # Optionally, enable a display manager (like LightDM)
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeter = pkgs.lightdm-gtk-greeter;

  # Optional: Set your preferred keyboard layout
   networking.keyMap = "de"; # Change to your preferred layout

  # Optional: Enable additional XFCE components
  # environment.systemPackages = with pkgs; [
  # xfce4-terminal  # Terminal emulator for XFCE
  # xfce4-screenshooter  # Screenshot tool
  # xfce4-appfinder  # Application finder
  # xfce4-power-manager  # Power management
  # xfce4-notifyd  # Notification daemon
 # ];

 

  # Update the CPU microcode for AMD processors
  hardware.cpu.amd.updateMicrocode = true;
  
  # Update the CPU microcode for Intel processors
  hardware.cpu.intel.updateMicrocode = true;
  
  
  
  # Whether to enable fwupd, a DBus service that allows applications to update firmware
  services.fwupd.enable = true;
  
  # Whether to enable udisks2, a DBus service that allows applications to query and manipulate storage devices
  services.udisks2.enable = true;
  
  # Choose between dbus and dbus_broker. Dbus_broker is a high-performance D-Bus.
  services.dbus.implementation = "broker";
  
  
  
  # Sets variables in /etc/environment
  environment.variables = {
    CPU_LIMIT = "0";
    CPU_GOVERNOR = "performance";
    GPU_USE_SYNC_OBJECTS = "1";
    SHARED_MEMORY = "1";
    LC_ALL = "de_DE.UTF-8";
    TIMEZONE = "Europe/Berlin";
    PYTHONOPTIMIZE = "1";
    ELEVATOR = "noop";
    TRANSPARENT_HUGEPAGES = "madvise";
    NET_CORE_WMEM_MAX = "1048576";
    NET_CORE_RMEM_MAX = "1048576";
    NET_IPV4_TCP_WMEM = "1048576";
    NET_IPV4_TCP_RMEM = "1048576";
    MALLOC_CONF = "background_thread:true";
    MALLOC_CHECK = "0";
    MALLOC_TRACE = "0";
    LD_DEBUG_OUTPUT = "0";
    AMD_VULKAN_ICD = "RADV";
    RADV_PERFTEST = "aco,sam,nggc";
    RADV_DEBUG = "novrsflatshading";
    STEAM_RUNTIME_HEAVY = "1";
    STEAM_FRAME_FORCE_CLOSE = "0";
    GAMEMODE = "1";
    vblank_mode = "1";
    PROTON_LOG = "0";
    PROTON_USE_WINED3D = "0";
    PROTON_NO_ESYNC = "1";
    DXVK_ASYNC = "1";
    WINE_FULLSCREEN_FSR = "1";
    WINE_VK_USE_FSR = "1";
    MESA_BACK_BUFFER = "ximage";
    MESA_NO_DITHER = "1";
    MESA_SHADER_CACHE_DISABLE = "false";
    mesa_glthread = "true";
    MESA_DEBUG = "0";
    LIBGL_DEBUG = "0";
    LIBGL_NO_DRAWARRAYS = "0";
    LIBGL_THROTTLE_REFRESH = "1";
    LIBC_FORCE_NOCHECK = "1";
    LIBGL_DRI3_DISABLE = "1";
    __GLVND_DISALLOW_PATCHING = "1";
    __GL_THREADED_OPTIMIZATIONS = "1";
    __GL_SYNC_TO_VBLANK = "1";
    __GL_SHADER_DISK_CACHE = "0";
    __GL_YIELD = "NOTHING";
    VK_LOG_LEVEL = "error";
    VK_LOG_FILE = "/dev/null";
    ANV_ENABLE_PIPELINE_CACHE = "1";
    HISTCONTROL = "ignoreboth:eraseboth";
    HISTSIZE = "5";
    LESSHISTFILE = "-";
    LESSHISTSIZE = "0";
    LESSSECURE = "1";
    PAGER = "less";
    EDITOR = "nano";
    VISUAL = "nano";
  };

  
  
  
  # Works out of the Box with amdgpu
  hardware.graphics = {
  enable = true;
  enable32Bit = true;
};
  
  # Whether to enable loading amdgpu kernelModule in stage 1. Can fix lower resolution in boot screen during initramfs phase 
  hardware.amdgpu.initrd.enable = true;

  # Enable OpenCL support using ROCM runtime library
  hardware.amdgpu.opencl.enable = true;
  
  # Whether to enable Experimental features support
  hardware.amdgpu.amdvlk.supportExperimental.enable = true;
  


  
  # Whether to enable the kernel’s NFS server
  services.nfs.server.enable = true;
 
 
  # Whether to enable Samba, the SMB/CIFS protocol
  services.samba.enable = true;
 
  # Whether to enable user-configurable Samba shares
  services.samba.usershares.enable = true;
 
 
 
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
 
 # Installs needed packages SystemWide for all users
  environment.systemPackages = with pkgs; [
    nano
    git
	wget
	curl
	fakeroot
	binutils
	#gnome.gvfs
	pciutils
	unixtools.quota
	kmod
	bind 
	samba
	
	xorg.xf86videoamdgpu
	xorg.xkill
	xorg.xvfb
	xorg.xf86videofbdev
	xorg.xrandr
	xorg.libXv
	xorg.libXfixes
	xorg.libXcomposite
	libwnck
	
	mesa
	vulkan-loader
	vulkan-tools
	vulkan-validation-layers
	ocl-icd
	libvdpau-va-gl
	libva-vdpau-driver
	libva
	libdrm
	
	openal
	faudio
	libgdiplus
	vkd3d
	wine
	winetricks
	protonup-qt
	
	whitesur-icon-theme
    mint-l-icons
	
	ventoy
	libreoffice-fresh
	pavucontrol
	#kdePackages.kate
	xfce.mousepad
	file-roller
	python3Full
	gsmartcontrol
	
	vlc
	strawberry
	soundconverter
	yt-dlp
	
	alsa-firmware
	sof-firmware
	ffmpeg_6-full
	gst_all_1.gstreamer
	lame
	flac
	x264
	x265
	
	gnome-disk-utility
	ntfs3g
	xfsdump
	mtools
	f2fs-tools
	btrfs-progs
	jfsutils
	
  ];

 
 # Some needed fonts
 fonts.packages = with pkgs; [
  noto-fonts
  noto-fonts-cjk-sans
  noto-fonts-emoji
  liberation_ttf
  fira-code
  fira-code-symbols
  open-sans
  roboto
  corefonts
  ];
 
 # Enable irqbalance daemon
 services.irqbalance.enable = true;
 
 
 
 # Installs Virt-Manager
 programs.virt-manager.enable = true;
 users.groups.libvirtd.members = ["your_username"];
 virtualisation.libvirtd.enable = true;
 virtualisation.spiceUSBRedirection.enable = true;
 
 
 #Installs Virtualbox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
   
   virtualisation.virtualbox.host.enable = true;
   virtualisation.virtualbox.host.enableExtensionPack = true;
 
 
 
 
 # Installs Chromium mit Widevine
 programs.chromium = {
  enable = true;  # Enable Chromium
  enableWidevine = true;  # Enable Widevine support
};
 
 # Install Firefox Browser
 programs.firefox.enable = true;
 
 # Install Thunderbird
 programs.thunderbird.enable = true;
 
 
 # Install Flatpak
 xdg.portal.enable = true; 
 # Specify the portal implementation

  xdg.portal.extraPortals = [
     pkgs.xdg-desktop-portal-gtk  # For GTK-based environments
 # pkgs.xdg-desktop-portal-kde  # Uncomment this line for KDE-based environments

  ];
 services.flatpak.enable = true;
 
 
 
 
 # Enable Printing Support
 services.printing.enable = true;
 
 services.printing.drivers = [ pkgs.gutenprintBin pkgs.gutenprint ];
 
 services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
};




 # Installs Steam Gaming Platform
 
 # Enable GameMode to optimise system performance on demand
 programs.gamemode.enable = true;
 
 # Enable protontricks, a simple wrapper for running Winetricks commands for Proton-enabled games
 programs.steam.protontricks.enable = true;
 
 programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
};

 nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
  ];
 
 # Enable udev rules for Steam hardware such as the Steam Controller, other supported controllers and the HTC Vive
 hardware.steam-hardware.enable = true;
 
 
 
 
 # Enable UFW
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ]; # Add your allowed TCP ports
  networking.firewall.allowedUDPPorts = [ ]; # Add your allowed UDP ports if needed

 # Enable UFW
   services.ufw.enable = true;

  # Optional: Set default policies
   services.ufw.defaultIncomingPolicy = "deny"; # Deny all incoming connections by default
   services.ufw.defaultOutgoingPolicy = "allow"; # Allow all outgoing connections by default

 
 
 # The line system.stateVersion = "24.11"; in configuration.nix specifies the version of the NixOS system configuration 
 # that should be used to ensure compatibility with the features and changes introduced up to that version.
 # system.stateVersion = "unstable"; for use with unstable channel. Use with caution.
 system.stateVersion = "24.11";  
