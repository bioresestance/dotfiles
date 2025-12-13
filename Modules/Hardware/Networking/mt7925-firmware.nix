# Overlay to fetch the latest mt7925 WiFi firmware from upstream linux-firmware.
# This provides newer firmware than what's in the current nixpkgs linux-firmware package.
#
# The mt7925 driver (mt76) has known issues with older firmware versions that can
# cause kernel hung tasks and system lockups. This overlay fetches the firmware
# directly from the upstream linux-firmware git repository.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.module.hardware.networking.mt7925FirmwareUpdate;

  # Upstream commit hash for the firmware
  firmwareRev = "6c60d1128566f8cc9c3ddd7ad1db7adec824f71b";

  # Individual firmware file fetches
  wifi-ram = pkgs.fetchurl {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/mt7925/WIFI_RAM_CODE_MT7925_1_1.bin?id=${firmwareRev}";
    name = "WIFI_RAM_CODE_MT7925_1_1.bin";
    sha256 = "15cbrv7ld84r4pay05nmm3981bmyf4la6l72qzdqwk5c565q8lpz";
  };

  wifi-patch = pkgs.fetchurl {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/mt7925/WIFI_MT7925_PATCH_MCU_1_1_hdr.bin?id=${firmwareRev}";
    name = "WIFI_MT7925_PATCH_MCU_1_1_hdr.bin";
    sha256 = "04vg12912jdm3szdrpqd3va4111dffkkv8nll4c2ixkh0c2q0156";
  };

  bt-ram = pkgs.fetchurl {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/mt7925/BT_RAM_CODE_MT7925_1_1_hdr.bin?id=${firmwareRev}";
    name = "BT_RAM_CODE_MT7925_1_1_hdr.bin";
    sha256 = "1cnzb0bzki860lxfj7zgn5lkja1iq8xgm4w2191d76sgzjciyc84";
  };

  # Fetch the latest mt7925 firmware files from upstream linux-firmware git
  mt7925-firmware-latest = pkgs.runCommand "mt7925-firmware-latest-20251213" { } ''
    mkdir -p $out/lib/firmware/mediatek/mt7925
    cp ${wifi-ram} $out/lib/firmware/mediatek/mt7925/WIFI_RAM_CODE_MT7925_1_1.bin
    cp ${wifi-patch} $out/lib/firmware/mediatek/mt7925/WIFI_MT7925_PATCH_MCU_1_1_hdr.bin
    cp ${bt-ram} $out/lib/firmware/mediatek/mt7925/BT_RAM_CODE_MT7925_1_1_hdr.bin
  '';
in
{
  options = {
    module.hardware.networking.mt7925FirmwareUpdate = {
      enable = mkOption {
        description = ''
          Enable fetching the latest MT7925 WiFi firmware from upstream linux-firmware.
          This can help fix kernel hung tasks and lockups caused by buggy firmware.
        '';
        default = false;
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    # Add the latest mt7925 firmware to the firmware path
    # This will be loaded in preference to the older firmware in linux-firmware
    hardware.firmware = [ mt7925-firmware-latest ];
  };
}
