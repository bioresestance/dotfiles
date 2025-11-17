{ pkgs, ... }:

let
  rofiCatppuccinTheme = builtins.toFile "rofi-catppuccin-mocha.rasi" ''
    /* Catppuccin Mocha inspired theme */
    * {
      font: "Cascadia Code 12";
      background: #1e1e2e;
      background-alt: #181825;
      foreground: #cdd6f4;
      foreground-alt: #bac2de;
      highlight: #313244;
      accent: #89b4fa;
      accent-alt: #b4befe;
      urgent: #f38ba8;
    }

    window {
      width: 40%;
      border: 2px;
      border-radius: 12px;
      padding: 20px;
      background-color: @background;
      border-color: @accent;
    }

    mainbox {
      background-color: transparent;
      spacing: 12px;
      children: [ inputbar, listview ];
    }

    inputbar {
      background-color: transparent;
      spacing: 8px;
    }

    prompt,
    entry {
      padding: 8px 12px;
      border-radius: 8px;
      background-color: @highlight;
      text-color: @foreground;
    }

    listview {
      background-color: transparent;
      lines: 8;
      columns: 1;
      spacing: 6px;
      scrollbar: false;
    }

    element {
      padding: 8px 12px;
      border-radius: 6px;
    }

    element normal.normal {
      background-color: transparent;
      text-color: @foreground;
    }

    element alternate.normal {
      background-color: transparent;
      text-color: @foreground-alt;
    }

    element selected.normal {
      background-color: @accent;
      text-color: #1e1e2e;
    }

    element urgent.normal {
      background-color: @urgent;
      text-color: #1e1e2e;
    }
  '';
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "aaron";
  home.homeDirectory = "/home/aaron";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Allow unfree packages in home-manager
  nixpkgs.config.allowUnfree = true;

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

    # Desktop Applications
    google-chrome
    discord
    thunderbird
    zoom-us
    insync

    # Media and Creative
    vlc
    plexamp
    gimp
    kicad
    freecad-wayland
    cheese

    # Office and Productivity
    libreoffice
    stirling-pdf

    # File Management and Transfer
    filezilla

    # Development
    hugo

    # KDE Applications
    kdePackages.okular
    kdePackages.kate
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
    settings = {
      user = {
        name = "Aaron Bromma";
        email = "aaron@bromma.dev";
      };
      init.defaultBranch = "main";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      # Use the 1Password SSH agent for all hosts.
      "*" = {
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    newSession = true;
  };

  ################################# Shell Configs #################################

  # Use the Catppuccin Mocha theme for Zsh syntax highlighting.
  home.file.".config/zsh/catppuccin_zsh-syntax-highlighting.zsh".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/zsh-syntax-highlighting/main/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh";
    sha256 = "1x2105vl3iiym9a5b6zsclglff4xy3r4iddz53dnns7djy6cf21d";
  };

  # ZSH configuration.
  programs.zsh = {
    enable = true;
    initContent = ''
      source ~/.config/zsh/catppuccin_zsh-syntax-highlighting.zsh
      fastfetch
    '';
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    history.size = 10000;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "z"
      ];
    };
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    font = {
      size = 12;
      name = "Cascadia Code";
    };
    themeFile = "Catppuccin-Mocha";
    settings = {
      background_opacity = 0.9;
      window_background_opacity = 0.9;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      confirm_os_window_close = 0;
    };
  };

  programs.oh-my-posh = {
    enable = true;
    useTheme = "catppuccin";
    enableZshIntegration = true;
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "builtin";
        height = 15;
        width = 30;
        padding = {
          top = 5;
          left = 3;
        };
      };

      modules = [
        "break"
        {
          type = "custom";
          format = "┌──────────────────────Hardware──────────────────────┐";
        }
        {
          type = "host";
          key = " PC";
          keyColor = "green";
        }
        {
          type = "cpu";
          key = "│ ├";
          keyColor = "green";
        }
        {
          type = "gpu";
          key = "│ ├󰍛";
          keyColor = "green";
        }
        {
          type = "memory";
          key = "│ ├󰍛";
          keyColor = "green";
        }
        {
          type = "disk";
          key = "└ └";
          keyColor = "green";
        }
        {
          type = "custom";
          format = "└────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌──────────────────────Software──────────────────────┐";
        }
        {
          type = "os";
          key = " OS";
          keyColor = "yellow";
        }
        {
          type = "kernel";
          key = "│ ├";
          keyColor = "yellow";
        }
        {
          type = "bios";
          key = "│ ├";
          keyColor = "yellow";
        }
        {
          type = "packages";
          key = "│ ├󰏖";
          keyColor = "yellow";
        }
        {
          type = "shell";
          key = "└ └";
          keyColor = "yellow";
        }
        "break"
        {
          type = "de";
          key = " DE";
          keyColor = "blue";
        }
        {
          type = "lm";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "wm";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "wmtheme";
          key = "│ ├󰉼";
          keyColor = "blue";
        }
        {
          type = "terminal";
          key = "└ └";
          keyColor = "blue";
        }
        {
          type = "custom";
          format = "└────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌────────────────────Uptime / Age / DT────────────────────┐";
        }
        {
          type = "command";
          key = "  OS Age ";
          keyColor = "magenta";
          text = ''
            birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days
          '';
        }
        {
          type = "uptime";
          key = "  Uptime ";
          keyColor = "magenta";
        }
        {
          type = "datetime";
          key = "  DateTime ";
          keyColor = "magenta";
        }
        {
          type = "custom";
          format = "└─────────────────────────────────────────────────────────┘";
        }
        "break"
      ];
    };
  };

  programs.rofi = {
    enable = true;
    theme = rofiCatppuccinTheme;
  };

  #################################################################################

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
