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
    # boot.kernelParams = [
    #   "usbcore.autosuspend=-1"
    #   "usbcore.use_both_schemes=y"
    #   "usbcore.old_scheme_first=y"
    #   "usbcore.initial_descriptor_timeout=20000"
    # ];

    # Add USB and Thunderbolt quirks
    # boot.extraModprobeConfig = ''
    #   # Disable USB autosuspend for hubs
    #   options usbcore autosuspend=-1 use_both_schemes=1 old_scheme_first=1 initial_descriptor_timeout=20000

    #   # Quirks for GenesysLogic USB hubs (05e3:0610, 05e3:0626)
    #   options usb-storage quirks=05e3:0610:u,05e3:0626:u

    #   # xHCI quirks for better Thunderbolt compatibility
    #   options xhci_hcd quirks=0x0200

    #   # Thunderbolt debug logging
    #   options thunderbolt dyndbg=+p
    # '';

    # Ensure Thunderbolt is properly configured
    services.hardware.bolt.enable = true;

    # Enable Thunderbolt kernel driver
    boot.kernelModules = [ "thunderbolt" ];

    # Keep the dock's Realtek NIC driver from ever loading so it cannot wedge xHCI
    boot.blacklistedKernelModules = [
      "r8152"
      "r8152-cfgselector"
    ];

    # Add udev rules to disable power management for USB hubs
    # services.udev.extraRules = ''
    #   # Disable autosuspend for all USB hubs to prevent enumeration issues
    #   ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"

    #   # Disable autosuspend for GenesysLogic hubs specifically
    #   ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", ATTR{idProduct}=="0610", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
    #   ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", ATTR{idProduct}=="0626", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"

    #   # Disable autosuspend for Cypress hubs (also in your dock)
    #   ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="04b4", ATTR{idProduct}=="6504", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
    #   ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="04b4", ATTR{idProduct}=="6506", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"

    #   # Disable autosuspend for Plugable hubs
    #   ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2230", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"

    #   # Disable autosuspend for Fresco Logic hubs
    #   ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1d5c", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"

    #   # Hard-disable the Plugable dock Realtek RTL8156 ethernet function before it can bind
    #   ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", \
    #     ATTR{authorized}="0"

    #   # Increase reset-resume quirk for USB devices behind Thunderbolt
    #   ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTR{../power/control}="on"

    #   # Authorize Thunderbolt devices automatically at boot
    #   ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
    # '';

    # Force the Realtek RTL8156 (Plugable dock NIC) to stay out of low-power states
    # whenever NetworkManager brings the interface up. This works around repeated
    # usb_reset_device stalls and the "network connected but dead" symptom seen in
    # the logs.
    # networking.networkmanager.dispatcherScripts = [
    #   {
    #     type = "basic";
    #     source = pkgs.writeShellScript "nm-r8156-workaround" ''
    #       iface="$1"
    #       action="$2"

    #       if [ -z "$iface" ] || [ ! -d "/sys/class/net/$iface" ]; then
    #         exit 0
    #       fi

    #       vendorFile="/sys/class/net/$iface/device/idVendor"
    #       productFile="/sys/class/net/$iface/device/idProduct"

    #       if [ ! -f "$vendorFile" ] || [ ! -f "$productFile" ]; then
    #         exit 0
    #       fi

    #       vendor="$(cat "$vendorFile" | tr 'A-F' 'a-f')"
    #       product="$(cat "$productFile" | tr 'A-F' 'a-f')"

    #       if [ "$vendor:$product" != "0bda:8156" ]; then
    #         exit 0
    #       fi

    #       case "$action" in
    #         up|pre-up|carrier|dhcp4-change|dhcp6-change|connectivity-change)
    #           ${pkgs.ethtool}/bin/ethtool --set-eee "$iface" off || true
    #           ${pkgs.ethtool}/bin/ethtool -K "$iface" tso off gso off gro off lro off || true
    #           ${pkgs.ethtool}/bin/ethtool --set-priv-flags "$iface" flow-director off 2>/dev/null || true
    #           ;;
    #       esac
    #     '';
    #   }
    # ];

    # Install USB debugging tools
    environment.systemPackages = with pkgs; [
      usbutils
    ];
  };
}
