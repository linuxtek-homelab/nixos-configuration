# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let

  # Samba Share Mount Options
  # Credenetials are stored in root only accessible file
  cifsMountOptions = [
    "vers=3.0"
    "credentials=/etc/nixos/smb-secrets"
    "uid=1000"
    "gid=100"
    "file_mode=0777"
    "dir_mode=0777"
  ];
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./xfce.nix      
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Define Kernel Package - Latest Stable kernel.org version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Add NAS Mount Shares
  fileSystems."/home/keitarou/Mounts/NAS" = {
    device = "//192.168.2.50/NAS";
    fsType = "cifs";
    options = cifsMountOptions; 
  };

 # Add Media Mount Shares
  fileSystems."/home/keitarou/Mounts/Media" = {
    device = "//192.168.2.50/Media";
    fsType = "cifs";
    options = cifsMountOptions;
  };

  # Global Settings - Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Set the default editor to vim
  environment.variables.EDITOR = "vim";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire."fiio-config" = { 
      "context.properties" = {
        "default.clock.rate" = 192000; # Default sample rate in Hz
        "default.clock.allowed-rates" = [ 48000 44100 ]; # Allowed rate
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.keitarou = {
    isNormalUser = true;
    description = "Keitarou Urashima";
    extraGroups = [ "networkmanager" "wheel" "docker" "audio"];
    packages = with pkgs; [      
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-utils
    cifs-utils
    cpufrequtils
    curl
    dmidecode
    discord
    docker
    docker-client
    ffmpeg-full
    firefox
    gedit
    gimp
    git
    google-chrome
    gparted
    htop
    imagemagick
    jq
    gnome.cheese
    libreoffice
    lsof
    lutris
    neofetch
    neovim
    nfs-utils
    openrgb-with-all-plugins
    openssh
    p7zip
    python3
    rpi-imager
    steam
    samba
    slack
    solaar
    terraform
    unzip
    usbutils
    ventoy-full
    vim
    vlc
    vscode
    wget
    xfce.thunar
    yt-dlp
  ];

  # Enable nix-ld for dynamic linking (VS Code Fix)
  programs.nix-ld.enable = true;

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;    
  }; 
  
  # Install Docker and enable Rootless Mode
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
