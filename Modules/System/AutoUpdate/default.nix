{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.module.system.autoUpdate;

  safeDirectories =
    if cfg.git.safeDirectories != [ ] then
      cfg.git.safeDirectories
    else
      optional (cfg.repoPath != null) cfg.repoPath;

  notifyUser = if cfg.notification.user != null then cfg.notification.user else cfg.repoUser;

  autoUpdateScript = pkgs.writeShellApplication {
    name = "nix-flake-auto-update";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.gnugrep
      pkgs.gnused
      pkgs.openssh
      pkgs.nix
      pkgs.util-linux
      pkgs.sudo
      cfg.homeManagerPackage
    ];
    text = ''
      set -euo pipefail

      log() {
        printf '[%s] %s\n' "$(date --iso-8601=seconds)" "$*"
      }

      notify() {
        local title="$1"
        local body="$2"
        local urgency="$3"
        local extra_body="$4"

        if [[ "$AUTOUPDATE_NOTIFY" != "1" ]]; then
          return
        fi

        local base_cmd=("$AUTOUPDATE_NOTIFY_COMMAND")
        local cmd=("''${base_cmd[@]}")
        local notify_user="$AUTOUPDATE_NOTIFY_USER"

        if [[ -n "$notify_user" ]]; then
          local notify_uid=""
          if notify_uid="$(id -u "$notify_user" 2>/dev/null)"; then
            local runtime_dir="/run/user/$notify_uid"
            local bus_path="$runtime_dir/bus"
            if [[ -S "$bus_path" ]]; then
              cmd=(
                sudo -u "$notify_user"
                env
                XDG_RUNTIME_DIR="$runtime_dir"
                DBUS_SESSION_BUS_ADDRESS="unix:path=$bus_path"
                "''${base_cmd[@]}"
              )
            fi
          fi
        fi

        local full_body="$body"
        if [[ -n "$extra_body" ]]; then
          full_body+=$'\n'
          full_body+="$extra_body"
        fi

        if [[ -n "$AUTOUPDATE_NOTIFY_APP" ]]; then
          cmd+=("--app-name" "$AUTOUPDATE_NOTIFY_APP")
        fi

        if [[ -n "$AUTOUPDATE_NOTIFY_ICON" ]]; then
          cmd+=("--icon" "$AUTOUPDATE_NOTIFY_ICON")
        fi

        if [[ -n "$AUTOUPDATE_NOTIFY_TIMEOUT" ]]; then
          cmd+=("--expire-time" "$AUTOUPDATE_NOTIFY_TIMEOUT")
        fi

        if [[ -n "$urgency" ]]; then
          cmd+=("--urgency" "$urgency")
        fi

        if [[ -n "$AUTOUPDATE_NOTIFY_EXTRA" ]]; then
          # shellcheck disable=SC2206
          local extra_args=( $AUTOUPDATE_NOTIFY_EXTRA )
          cmd+=("''${extra_args[@]}")
        fi

        cmd+=("$title" "$full_body")

        "''${cmd[@]}" >/dev/null 2>&1 || true
      }

      repo="$AUTOUPDATE_REPO"
      nix_targets="$AUTOUPDATE_NIX_TARGETS"
      home_targets="$AUTOUPDATE_HOME_TARGETS"
      hm_bin="$AUTOUPDATE_HOME_MANAGER"
      repo_user="$AUTOUPDATE_REPO_USER"
      nixos_rebuild="$AUTOUPDATE_NIXOS_REBUILD"
      allow_dirty="$AUTOUPDATE_GIT_ALLOW_DIRTY"

      if [[ -z "$nixos_rebuild" ]]; then
        nixos_rebuild="nixos-rebuild"
      fi

      run_repo_cmd() {
        if [[ -z "$repo_user" || "$repo_user" == "root" ]]; then
          "$@"
        else
          sudo -u "$repo_user" -H -- "$@"
        fi
      }

      if [[ -z "$repo" ]]; then
        echo "AUTOUPDATE_REPO not set" >&2
        exit 1
      fi

      if [[ ! -d "$repo" ]]; then
        echo "Repository path $repo not found" >&2
        exit 1
      fi

      cd "$repo"

      if [[ "$allow_dirty" != "1" ]]; then
        if [[ -n "$(run_repo_cmd git status --porcelain --untracked-files=all)" ]]; then
          failure "git working tree is dirty"
        fi
      fi

      lock_backup=""
      cleanup() {
        if [[ -n "$lock_backup" && -f "$lock_backup" ]]; then
          rm -f "$lock_backup"
        fi
      }
      trap cleanup EXIT

      backup_lock() {
        if [[ -f "flake.lock" ]]; then
          lock_backup="$(mktemp --tmpdir auto-update-lock.XXXXXX)"
          cp flake.lock "$lock_backup"
        fi
      }

      restore_lock() {
        if [[ -n "$lock_backup" && -f "$lock_backup" ]]; then
          cp "$lock_backup" flake.lock
          return
        fi
        git checkout -- flake.lock >/dev/null 2>&1 || true
      }

      summarize_targets() {
        local items="$1"
        local label="$2"
        if [[ -z "$items" ]]; then
          printf '%s: none' "$label"
          return
        fi
        printf '%s: %s' "$label" "$items"
      }

      log "Starting automatic flake update"
      start_details="$(summarize_targets "$nix_targets" "NixOS")"
      if [[ -n "$home_targets" ]]; then
        start_details+=$'\n'
        start_details+="$(summarize_targets "$home_targets" "Home")"
      fi
      notify "Nix auto update" "Update started" "normal" "$start_details"

      backup_lock

      failure() {
        local message="$1"
        log "Failure: $message"
        restore_lock
        notify "Nix auto update" "Update failed" "critical" "$message"
        exit 1
      }

      log "Running nix flake update"
      if ! run_repo_cmd nix flake update; then
        failure "flake update failed"
      fi

      if [[ -n "$nix_targets" ]]; then
        for target in $nix_targets; do
          log "Switching NixOS target $target"
          if ! "$nixos_rebuild" switch --flake "$repo#$target"; then
            failure "nixos-rebuild failed for $target"
          fi
        done
      fi

      if [[ -n "$home_targets" ]]; then
        for spec in $home_targets; do
          user="''${spec%%:*}"
          attr="''${spec#*:}"
          log "Switching home-manager profile $attr for $user"
          if ! runuser -l "$user" -c "$hm_bin switch --flake '$repo#$attr'"; then
            failure "home-manager failed for $user ($attr)"
          fi
        done
      fi

      log "Preparing git commit"
      if ! run_repo_cmd git add flake.lock; then
        failure "git add flake.lock failed"
      fi

      if run_repo_cmd git diff --cached --quiet -- flake.lock; then
        log "No lockfile changes detected"
      else
        commit_message="$AUTOUPDATE_GIT_MESSAGE $(date --iso-8601=seconds)"
        if ! run_repo_cmd git commit -m "$commit_message"; then
          failure "git commit failed"
        fi
        log "Committed lockfile update"
      fi

      push_result="skipped"
      if [[ "$AUTOUPDATE_GIT_PUSH" == "1" ]]; then
        remote="$AUTOUPDATE_GIT_REMOTE"
        branch="$AUTOUPDATE_GIT_BRANCH"
        if [[ -z "$branch" ]]; then
          branch="$(run_repo_cmd git rev-parse --abbrev-ref HEAD)"
        fi
        log "Pushing to $remote $branch"
        if run_repo_cmd git push "$remote" "$branch"; then
          push_result="succeeded"
        else
          push_result="failed"
        fi
      fi

      summary="Flake update + switches completed. Git push $push_result."
      log "$summary"
      notify "Nix auto update" "Update succeeded" "normal" "$summary"
    '';
  };

  homeTargetType = types.submodule {
    options = {
      user = mkOption {
        type = types.str;
        description = "System user that owns the home-manager profile.";
      };
      flakeAttr = mkOption {
        type = types.str;
        description = "Flake output under homeConfigurations to rebuild.";
      };
    };
  };
in
{
  options.module.system.autoUpdate = {
    enable = mkEnableOption "Automatic flake update";

    repoPath = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/home/aaron/.dotfiles";
      description = "Absolute path to the flake repository to update.";
    };

    repoUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "aaron";
      description = "User account that owns the repo; nix flake update and git operations run as this user.";
    };

    nixosTargets = mkOption {
      type = types.listOf types.str;
      default = [ config.networking.hostName ];
      description = "List of nixosConfigurations attributes to rebuild.";
    };

    homeManagerTargets = mkOption {
      type = types.listOf homeTargetType;
      default = [ ];
      description = "Home-manager profiles to rebuild (user + flake attribute).";
    };

    homeManagerPackage = mkOption {
      type = types.package;
      default = pkgs.home-manager;
      description = "Package that provides the home-manager CLI.";
    };

    notification = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable desktop notifications via notify-send (or custom command).";
      };

      user = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "User account whose desktop session should receive notifications (falls back to repoUser when unset).";
      };

      command = mkOption {
        type = types.str;
        default = "${pkgs.libnotify}/bin/notify-send";
        description = "Command used to send notifications.";
      };

      appName = mkOption {
        type = types.str;
        default = "Nix Auto Update";
        description = "Application name shown in notifications.";
      };

      icon = mkOption {
        type = types.nullOr types.str;
        default = "preferences-system-updates";
        description = "Notification icon name or path.";
      };

      timeoutMs = mkOption {
        type = types.int;
        default = 8000;
        description = "Notification timeout in milliseconds.";
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ "--hint=int:transient:1" ];
        description = "Extra flags appended to the notification command.";
      };
    };

    git = {
      commitMessagePrefix = mkOption {
        type = types.str;
        default = "Auto-update";
        description = "Prefix for the auto-generated git commit message.";
      };

      enablePush = mkOption {
        type = types.bool;
        default = true;
        description = "Push the updated lockfile after a successful rebuild.";
      };

      remote = mkOption {
        type = types.str;
        default = "origin";
        description = "Git remote to push to.";
      };

      branch = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Branch to push to (falls back to current branch when null).";
      };

      safeDirectories = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of repository paths to mark as Git safe.directory for root-run commands.";
      };

      allowDirty = mkOption {
        type = types.bool;
        default = false;
        description = "Allow auto-update to proceed even if the Git working tree has uncommitted changes.";
      };
    };

    timer = {
      onCalendar = mkOption {
        type = types.str;
        default = "daily";
        description = "systemd OnCalendar expression for the update timer.";
      };

      onBootSec = mkOption {
        type = types.str;
        default = "15min";
        description = "Delay after boot before the timer first triggers.";
      };

      randomizedDelaySec = mkOption {
        type = types.nullOr types.str;
        default = "1h";
        description = "Randomized delay added to the timer (set null to disable).";
      };

      persistent = mkOption {
        type = types.bool;
        default = true;
        description = "Persist missed timer events so updates run once per day even if offline.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.repoPath != null;
        message = "module.system.autoUpdate.repoPath must be set when enabling auto updates.";
      }
    ];

    programs.git = mkIf (safeDirectories != [ ]) {
      enable = mkDefault true;
      config.safe.directory = mkBefore safeDirectories;
    };

    systemd.services.nix-flake-auto-update = {
      description = "Automatic flake update and rebuild";
      serviceConfig = {
        Type = "oneshot";
        WorkingDirectory = cfg.repoPath;
        ExecStart = "${autoUpdateScript}/bin/nix-flake-auto-update";
      };

      environment = {
        AUTOUPDATE_REPO = cfg.repoPath;
        AUTOUPDATE_REPO_USER = if cfg.repoUser == null then "" else cfg.repoUser;
        AUTOUPDATE_NIX_TARGETS = concatStringsSep " " cfg.nixosTargets;
        AUTOUPDATE_HOME_TARGETS = concatStringsSep " " (
          map (target: "${target.user}:${target.flakeAttr}") cfg.homeManagerTargets
        );
        AUTOUPDATE_HOME_MANAGER = "${cfg.homeManagerPackage}/bin/home-manager";
        AUTOUPDATE_NIXOS_REBUILD = "${config.system.build.nixos-rebuild}/bin/nixos-rebuild";
        AUTOUPDATE_NOTIFY = if cfg.notification.enable then "1" else "0";
        AUTOUPDATE_NOTIFY_USER = if notifyUser == null then "" else notifyUser;
        AUTOUPDATE_NOTIFY_COMMAND = cfg.notification.command;
        AUTOUPDATE_NOTIFY_APP = cfg.notification.appName;
        AUTOUPDATE_NOTIFY_ICON = if cfg.notification.icon == null then "" else cfg.notification.icon;
        AUTOUPDATE_NOTIFY_TIMEOUT = toString cfg.notification.timeoutMs;
        AUTOUPDATE_NOTIFY_EXTRA = concatStringsSep " " cfg.notification.extraArgs;
        AUTOUPDATE_GIT_MESSAGE = cfg.git.commitMessagePrefix;
        AUTOUPDATE_GIT_PUSH = if cfg.git.enablePush then "1" else "0";
        AUTOUPDATE_GIT_REMOTE = cfg.git.remote;
        AUTOUPDATE_GIT_BRANCH = if cfg.git.branch == null then "" else cfg.git.branch;
        AUTOUPDATE_GIT_ALLOW_DIRTY = if cfg.git.allowDirty then "1" else "0";
      };
    };

    systemd.timers.nix-flake-auto-update = {
      description = "Schedule automatic flake updates";
      wantedBy = [ "timers.target" ];
      timerConfig = (
        {
          OnCalendar = cfg.timer.onCalendar;
          OnBootSec = cfg.timer.onBootSec;
          Persistent = cfg.timer.persistent;
          Unit = "nix-flake-auto-update.service";
        }
        // optionalAttrs (cfg.timer.randomizedDelaySec != null) {
          RandomizedDelaySec = cfg.timer.randomizedDelaySec;
        }
      );
    };
  };
}
