{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Shell and Terminal
    eza
    cmatrix
    cowsay
    oh-my-zsh
    fastfetch
    kitty-themes
    cascadia-code
    zsh-autosuggestions
    oh-my-posh
    usbutils
    wakeonlan
    transmission_4
    pandoc
    tea

    # Desktop Applications
    google-chrome
    vivaldi
    discord
    thunderbird
    zoom-us
    celeste
    moonlight-qt
    obsidian
    remarkable
    claude-code
    telegram-desktop

    # Media and Creative
    vlc
    plexamp
    gimp
    kicad
    cheese

    # Office and Productivity
    libreoffice
    stirling-pdf

    # File Management and Transfer
    filezilla

    # Development
    hugo
    spec-kit
    cursor-cli

    # KDE Applications
    kdePackages.okular
    kdePackages.kate
  ];
}
