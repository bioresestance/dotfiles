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
    # Disable USB autosuspend to prevent Thunderbolt dock USB hub delays
    boot.kernelParams = [
      "usbcore.autosuspend=-1"
      "usbcore.use_both_schemes=y"
      "usbcore.old_scheme_first=y"
      "usbcore.initial_descriptor_timeout=20000"
    ];

    # Add USB and Thunderbolt quirks
    boot.extraModprobeConfig = ''
      # Disable USB autosuspend for hubs
      options usbcore autosuspend=-1 use_both_schemes=1 old_scheme_first=1 initial_descriptor_timeout=20000
      
      # Quirks for GenesysLogic USB hubs (05e3:0610, 05e3:0626)
      options usb-storage quirks=05e3:0610:u,05e3:0626:u
      
      # xHCI quirks for better Thunderbolt compatibility
      options xhci_hcd quirks=0x0200
      
      # Thunderbolt debug logging
      options thunderbolt dyndbg=+p
    '';

    # Ensure Thunderbolt is properly configured
    services.hardware.bolt.enable = true;
    
    # Enable Thunderbolt kernel driver
    boot.kernelModules = [ "thunderbolt" ];

    # Add udev rules to disable power management for USB hubs
    services.udev.extraRules = ''
      # Disable autosuspend for all USB hubs to prevent enumeration issues
      ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
      
      # Disable autosuspend for GenesysLogic hubs specifically
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", ATTR{idProduct}=="0610", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", ATTR{idProduct}=="0626", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
      
      # Disable autosuspend for Cypress hubs (also in your dock)
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="04b4", ATTR{idProduct}=="6504", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="04b4", ATTR{idProduct}=="6506", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
      
      # Disable autosuspend for Plugable hubs
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2230", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
      
      # Disable autosuspend for Fresco Logic hubs
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1d5c", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
      
      # Increase reset-resume quirk for USB devices behind Thunderbolt
      ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTR{../power/control}="on"
      
      # Authorize Thunderbolt devices automatically at boot
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
    '';

    # Install USB debugging tools
    environment.systemPackages = with pkgs; [
      usbutils
    ];
  };
}
