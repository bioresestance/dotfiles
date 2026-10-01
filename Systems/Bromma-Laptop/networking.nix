{ pkgs, ... }:

let
  dockEthernetProfile = pkgs.writeText "dock-ethernet.nmconnection" ''
    [connection]
    id=Dock Ethernet
    uuid=21917c9e-63aa-4a07-9a37-79fba399a097
    type=ethernet
    autoconnect=true
    permissions=

    [ethernet]
    mac-address=8C:AE:4C:BE:04:75

    [ipv4]
    method=auto

    [ipv6]
    addr-gen-mode=eui64
    method=auto

    [proxy]
  '';
in
{
  module.services.network-mounts = {
    enable = true;
    shares = [
      {
        mountPoint = "/mnt/Media";
        device = "//192.168.69.57/Media";
      }
      {
        mountPoint = "/mnt/Homes";
        device = "//192.168.69.57/Homes";
      }
      {
        mountPoint = "/mnt/Backups";
        device = "//192.168.69.57/Backups";
      }
    ];
  };

  # Temporary NFS test: remove this filesystem and tmpfiles rule when finished.
  fileSystems."/mnt/nfs-test/nfs-media" = {
    device = "truenas.local:/mnt/MainPool/Media";
    fsType = "nfs4";
    options = [
      "vers=4"
      "proto=tcp"
      "hard"
      "timeo=600"
      "retrans=2"
      "_netdev"
    ];
  };
  systemd.tmpfiles.rules = [ "d /mnt/nfs-test/nfs-media 0755 root root -" ];

  # Ensure Thunderbolt is properly configured
  services.hardware.bolt.enable = true;

  # Force Realtek USB NICs (including RTL8156) into the vendor-specific
  # configuration so the r8152 driver binds instead of the generic CDC stack.
  services.udev.extraRules = ''
    ACTION!="add", GOTO="usb_realtek_net_end"
    SUBSYSTEM!="usb", GOTO="usb_realtek_net_end"
    ENV{DEVTYPE}!="usb_device", GOTO="usb_realtek_net_end"

    ENV{REALTEK_MODE1}="1"
    ENV{REALTEK_MODE2}="3"

    # Realtek OEM adapters
    ATTR{idVendor}=="0bda", ATTR{idProduct}=="815[2,3,5,6]", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
    ATTR{idVendor}=="0bda", ATTR{idProduct}=="8053", ATTR{bcdDevice}=="e???", ATTR{bConfigurationValue}!="$env{REALTEK_MODE2}", ATTR{bConfigurationValue}="$env{REALTEK_MODE2}"

    LABEL="usb_realtek_net_end"
  '';

  # Provide a persistent NetworkManager profile so the dock NIC keeps
  # autoconnecting even if the kernel renames the interface after USB resets.
  environment.etc."NetworkManager/system-connections/dock-ethernet.nmconnection" = {
    source = dockEthernetProfile;
    mode = "0600";
  };
}
