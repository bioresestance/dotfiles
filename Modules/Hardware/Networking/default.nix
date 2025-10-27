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
  };

  config = mkIf cfg.enable {
    # Enable networking
    networking.hostName = cfg.hostName;
    networking.networkmanager.enable = true;

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
  };
}
