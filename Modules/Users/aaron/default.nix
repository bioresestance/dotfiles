{
  pkgs,
  lib,
  ...
}:
with lib;
{

  config = {
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
      ];
      shell = pkgs.zsh;
    };
    services.udev.packages = [
      pkgs.platformio-core
      pkgs.openocd
      pkgs.segger-jlink
    ];
  };

}
