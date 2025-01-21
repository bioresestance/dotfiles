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
      ];
    };
  };
}
