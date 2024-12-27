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
    ".config/1Password/ssh/agent.toml" = {
      enable = true;
      text = ''
        [[ssh-keys]]
        vault = "Development"
      '';
    };
  };

  home.sessionVariables = {
  };

  home.shellAliases = {
    ll = "ls -l";
    ".." = "cd ..";
    home-rebuild = "home-manager switch --flake /home/aaron/.dotfiles";
    nix-rebuild = "sudo nixos-rebuild switch --flake /home/aaron/.dotfiles";
  };

  programs.bash = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Aaron Bromma";
    userEmail = "aaron@bromma.dev";
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        extraOptions = {
          identityAgent = "~/.1password/agent.sock";
        };
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
