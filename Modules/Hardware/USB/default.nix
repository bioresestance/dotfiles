{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.module.hardware.usb;
in
{
  options = {
    module.hardware.usb.enable = mkOption {
      description = "Enable USB hardware optimizations for docks and hubs.";
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {

    # Ensure Thunderbolt is properly configured
    services.hardware.bolt.enable = true;

    # Enable Thunderbolt kernel driver
    boot.kernelModules = [ "thunderbolt" ];

    # Keep the dock's Realtek NIC driver from ever loading so it cannot wedge xHCI
    boot.blacklistedKernelModules = [
      "r8152"
      "r8152-cfgselector"
    ];

    # Install USB debugging tools
    environment.systemPackages = with pkgs; [
      usbutils
    ];
  };
}
