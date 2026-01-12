{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.module.hardware.networking;
in
{
  imports = [
    ./mt7925-firmware.nix
  ];
  options = {
    module.hardware.networking.enable = mkOption {
      description = "Enable networking support (NetworkManager, Bluetooth).";
      default = true;
      type = types.bool;
    };

    module.hardware.networking.hostName = mkOption {
      description = "The hostname of the system.";
      default = "nixos";
      type = types.str;
    };

    module.hardware.networking.bluetooth.enable = mkOption {
      description = "Enable Bluetooth support.";
      default = true;
      type = types.bool;
    };

    module.hardware.networking.useIwd = mkOption {
      description = ''
        Use iwd (iNet Wireless Daemon) as the WiFi backend instead of wpa_supplicant.
        iwd is generally more stable and efficient, especially with newer WiFi chipsets
        like the MediaTek mt7925. This can help prevent system lockups caused by
        wpa_supplicant interactions with problematic drivers.
      '';
      default = false;
      type = types.bool;
    };

    module.hardware.networking.disable_mt7925 = mkOption {
      description = ''
        Temporarily blacklist the MediaTek `mt7925` WiFi modules to work around
        kernel/driver hangs. This is a mitigation that will disable the built-in
        WiFi device; prefer updating kernel/firmware or reverting when a proper
        fix is available.
      '';
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # Enable networking
    networking.hostName = cfg.hostName;
    networking.networkmanager = {
      enable = true;
      # Use iwd as WiFi backend if enabled (more stable with mt76 drivers)
      wifi.backend = if cfg.useIwd then "iwd" else "wpa_supplicant";
    };

    # Enable iwd service if using iwd backend
    networking.wireless.iwd = mkIf cfg.useIwd {
      enable = true;
      settings = {
        General = {
          # Disable power saving to prevent driver deadlocks
          EnableNetworkConfiguration = false; # Let NetworkManager handle IP config
        };
        Settings = {
          AutoConnect = true;
        };
      };
    };

    # Enable Bluetooth
    hardware.bluetooth = mkIf cfg.bluetooth.enable {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    # Optional mitigation: blacklist mt7925 modules if requested
    environment.etc = lib.mkIf cfg.disable_mt7925 {
      # add a small note file so it's easy to see why modules are blacklisted
      "mt7925-blacklist-note".text = ''Blacklisted mt7925 modules via NixOS config.'';
    };

    boot.blacklistedKernelModules = lib.optional cfg.disable_mt7925 [
      "mt7925e"
      "mt7925"
      "mt76"
    ];
  };
}
