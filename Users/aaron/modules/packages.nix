{ pkgs, inputs, ... }:

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
    codex

    # Desktop Applications
    google-chrome
    vivaldi
    discord
    thunderbird
    zoom-us
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
    feishin

    # Office and Productivity
    libreoffice
    stirling-pdf

    # File Management and Transfer
    filezilla
    taler-sync

    # Development
    (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.orca.overrideAttrs (old: {
      # Orca checks this browser's upstream hash before copying it to an SSH host.
      postFixup =
        let
          browserSearch = ''$(find "$out/lib/Orca/resources" -mindepth 1 -maxdepth 1 ! -name orcad-template)'';
          preservedBrowserSearch = ''$(find "$out/lib/Orca/resources" -mindepth 1 -maxdepth 1 ! -name orcad-template ! -name agent-browser-linux-x64)'';
        in
        assert pkgs.lib.hasInfix browserSearch old.postFixup;
        pkgs.lib.replaceStrings [ browserSearch ] [ preservedBrowserSearch ] old.postFixup;
    }))
    hugo
    spec-kit
    openspec
    godot

    # KDE Applications
    kdePackages.okular
    kdePackages.kate
  ];
}
