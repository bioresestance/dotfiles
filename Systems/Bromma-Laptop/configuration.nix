# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../Modules/Common
    ../../Modules/Users/aaron
    ../../Modules/Applications/3DPrinting
    ../../Modules/Applications/Tailscale
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amdgpu.exp_hw_support=1" # For experimental GPU support, if applicable
  ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  hardware.amdgpu.initrd.enable = true;

  programs.nix-ld.enable = true;

  networking.hostName = "Bromma-Laptop"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pipewire.wireplumber.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "aaron";
  services.displayManager.defaultSession = "plasma";

  # Install firefox.
  programs.firefox.enable = true;
  services.fwupd.enable = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    linux-firmware
    pciutils
    vim
    neovim
    vscode
    kitty
    lshw
    google-chrome
    pavucontrol
    git
    gcc14
    okular
    bat
    powertop
    htop
    stirling-pdf
    wget
    just
    nodejs_23
    python312
    nixfmt-rfc-style
    tmux
    uv
    nixd
    nvtopPackages.full
    gparted
    ansible
    plexamp
    gnome-firmware
    libreoffice
    kicad
    gimp
    tldr
    okular
    mongodb-tools
    xorg.xrandr
    jdk21_headless
    hugo
    filezilla
    simple-scan
    kdePackages.kate
    sshpass
    asusctl
    nmap
    cifs-utils
    vlc
    ollama-cuda
    lmstudio
  ];

  services.ollama = {
    enable = true;
    acceleration = "cuda";

  };

  services.asusd.enable = true;

  hardware.enableAllFirmware = true;
  services.hardware.bolt.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [

      libGL.dev
    ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [
    "nvidia"
    "modesetting"
  ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # # Fine-grained power management. Turns off GPU when not in use.
    # # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # forceFullCompositionPipeline = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      #Make sure to use the correct Bus ID values for your system!
      nvidiaBusId = "PCI:100:0:0";
      amdgpuBusId = "PCI:101:0:0";
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  virtualisation.docker.enable = true;
  powerManagement.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "aaron" ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession.enable = true;
  };

  module.apps.ThreeDPrinting.enable = true;

  fileSystems."/mnt/Media" = {
    device = "//192.168.69.57/Media";
    fsType = "cifs";
    options = [
      "credentials=/home/aaron/.dotfiles/smb-credentials"
      "uid=1000"
      "gid=1000"
      "iocharset=utf8"
      "vers=3.0"
      "x-systemd.requires=network-online.target"
      "x-systemd.mount-timeout=30s"
    ];
  };

  fileSystems."/mnt/Homes" = {
    device = "//192.168.69.57/Homes";
    fsType = "cifs";
    options = [
      "credentials=/home/aaron/.dotfiles/smb-credentials"
      "uid=1000"
      "gid=1000"
      "iocharset=utf8"
      "vers=3.0"
      "x-systemd.requires=network-online.target"
      "x-systemd.mount-timeout=30s"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
