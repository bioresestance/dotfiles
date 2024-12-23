{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "aaron";
  home.homeDirectory = "/home/aaron";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.packages = [
  ];

  home.file = {
  };

  home.sessionVariables = {
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
      home-rebuild = "home-manager switch --flake /home/aaron/.dotfiles";
      nix-rebuild = "sudo nixos-rebuild switch --flake /home/aaron/.dotfiles";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
