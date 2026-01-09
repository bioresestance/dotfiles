{
  pkgs,
  lib,
  ...
}:
with lib;
let
  # Raspberry Pi Pico udev rules for development
  # From: https://github.com/raspberrypi/picotool/blob/master/udev/60-picotool.rules
  picoUdevRules = pkgs.writeTextFile {
    name = "60-picotool.rules";
    destination = "/etc/udev/rules.d/60-picotool.rules";
    text = ''
      # Raspberry Pi Pico udev rules
      # https://github.com/raspberrypi/picotool/blob/master/udev/60-picotool.rules
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", TAG+="uaccess", MODE="660", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0009", TAG+="uaccess", MODE="660", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="000a", TAG+="uaccess", MODE="660", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="000f", TAG+="uaccess", MODE="660", GROUP="plugdev"
    '';
  };
in
{

  config = {
    # Create the plugdev group for USB device access
    users.groups.plugdev = { };

    users.users.aaron = {
      isNormalUser = true;
      description = "Aaron Bromma";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "lpadmin"
        "dialout"
        "scanner"
        "lp"
        "plugdev"
      ];
      shell = pkgs.zsh;
    };
    services.udev.packages = [
      pkgs.platformio-core
      pkgs.openocd
      pkgs.segger-jlink
      picoUdevRules
    ];
  };

}
