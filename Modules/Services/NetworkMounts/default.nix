{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.module.services.network-mounts;
in
{
  options = {
    module.services.network-mounts.enable = mkOption {
      description = "Enable CIFS/SMB network mounts.";
      default = false;
      type = types.bool;
    };

    module.services.network-mounts.credentialsFile = mkOption {
      description = "Path to the credentials file for SMB/CIFS mounts.";
      default = "/home/aaron/.dotfiles/smb-credentials";
      type = types.str;
    };

    module.services.network-mounts.shares = mkOption {
      description = "List of network shares to mount.";
      default = [ ];
      type = types.listOf (
        types.submodule {
          options = {
            mountPoint = mkOption {
              description = "Local mount point path.";
              type = types.str;
            };

            device = mkOption {
              description = "Network share path (e.g., //server/share).";
              type = types.str;
            };

            options = mkOption {
              description = "Mount options.";
              type = types.listOf types.str;
              default = [
                "x-systemd.automount"
                "noauto"
                "x-systemd.idle-timeout=60"
                "x-systemd.device-timeout=5s"
                "x-systemd.mount-timeout=5s"
              ];
            };
          };
        }
      );
    };
  };

  config = mkIf cfg.enable {
    # Ensure required packages are available
    environment.systemPackages = with pkgs; [
      cifs-utils
    ];

    # Configure CIFS mount wrapper for proper permissions
    security.wrappers = {
      "mount.cifs" = {
        source = "${pkgs.cifs-utils}/bin/mount.cifs";
        setuid = true;
        owner = "root";
        group = "root";
      };
    };

    # Create mount points and configure file systems
    systemd.tmpfiles.rules = map (share: "d ${share.mountPoint} 0755 root root -") cfg.shares;

    fileSystems = builtins.listToAttrs (
      map (share: {
        name = share.mountPoint;
        value = {
          device = share.device;
          fsType = "cifs";
          options = [
            "credentials=${cfg.credentialsFile}"
            "uid=1000"
            "gid=100"
            "file_mode=0644"
            "dir_mode=0755"
          ]
          ++ share.options;
        };
      }) cfg.shares
    );
  };
}
