{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "aaron";
  home.homeDirectory = "/home/aaron";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    eza
    cmatrix
    cowsay
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
    ls = "eza -l";
  };

  programs.bash = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Aaron Bromma";
    userEmail = "aaron@bromma.dev";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Use the 1Password SSH agent for all hosts.
      "*" = {
        extraOptions = {
          identityAgent = "~/.1password/agent.sock";
        };
      };
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    newSession = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
