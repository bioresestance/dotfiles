{
  home.shellAliases = {
    ll = "ls -l";
    ".." = "cd ..";
    home-rebuild = "home-manager switch --flake /home/aaron/.dotfiles";
    ls = "eza -l";
  };

  programs.bash = {
    enable = true;
  };

  home.file.".config/zsh/catppuccin_zsh-syntax-highlighting.zsh".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/zsh-syntax-highlighting/main/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh";
    sha256 = "1x2105vl3iiym9a5b6zsclglff4xy3r4iddz53dnns7djy6cf21d";
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      source ~/.config/zsh/catppuccin_zsh-syntax-highlighting.zsh
      fastfetch

      nix-rebuild() {
        local flake="/home/aaron/.dotfiles"
        local subcommand="''${1:-switch}"
        local errors=0

        echo "==> Updating flake inputs..."
        if ! nix flake update --flake "$flake"; then
          echo "ERROR: Flake update failed. Aborting."
          return 1
        fi

        echo ""
        echo "==> Formatting Nix files..."
        if (cd "$flake" && ./scripts/format.sh); then
          echo "Lint cleanup succeeded."
        else
          echo "WARNING: Lint cleanup failed; continuing."
        fi

        echo ""
        echo "==> Committing and pushing flake changes..."
        if [[ -d "$flake/.git" ]]; then
          (
            cd "$flake" || exit 1
            local preexisting
            preexisting=$(git status --porcelain | awk '{ print $2 }' \
              | grep -Ev '^(flake\.lock|.*\.nix)$' || true)
            if [[ -n "$preexisting" ]]; then
              echo "WARNING: Repository has pre-existing changes; skipping git commit/push:"
              echo "$preexisting" | sed 's/^/  - /'
              exit 0
            fi

            if git diff --quiet && git diff --cached --quiet; then
              echo "No flake changes to commit."
              exit 0
            fi

            if ! git add -A; then
              echo "WARNING: git add failed; skipping commit/push."
              exit 0
            fi
            if ! git commit -m "Updated flake"; then
              echo "WARNING: git commit failed; skipping push."
              exit 0
            fi
            if ! git push; then
              echo "WARNING: git push failed; continuing."
              exit 0
            fi
            echo "Git commit/push succeeded."
          )
        else
          echo "WARNING: $flake is not a git repository; skipping commit/push."
        fi

        echo ""
        echo "==> Rebuilding NixOS system ($subcommand)..."
        if sudo nixos-rebuild "$subcommand" --flake "$flake"; then
          echo "NixOS rebuild succeeded."
        else
          echo "ERROR: NixOS rebuild failed."
          errors=$((errors + 1))
        fi

        if [[ "$subcommand" == "switch" ]]; then
          echo ""
          echo "==> Rebuilding home-manager..."
          if home-manager switch --flake "$flake"; then
            echo "Home-manager rebuild succeeded."
          else
            echo "ERROR: Home-manager rebuild failed."
            errors=$((errors + 1))
          fi
        else
          echo ""
          echo "==> Skipping home-manager (subcommand is '$subcommand', not 'switch')."
        fi

        echo ""
        if [[ $errors -eq 0 ]]; then
          echo "All rebuilds completed successfully."
        else
          echo "$errors rebuild(s) failed."
          return 1
        fi
      }
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

  programs.oh-my-posh = {
    enable = true;
    useTheme = "catppuccin";
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
