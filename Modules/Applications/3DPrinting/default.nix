{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options = {
    module.apps.ThreeDPrinting = {
      enable = mkOption {
        description = "Enable 3D printing services and applications.";
        default = false;
        type = types.bool;
      };

    };
  };

  config = mkIf config.module.apps.ThreeDPrinting.enable {
    environment.systemPackages = with pkgs; [
      # snapmaker-luban
      orca-slicer
      # bambu-studio
    ];

    # nixpkgs.config.permittedInsecurePackages = [
    #   "snapmaker-luban-4.14.0"
    # ];
  };
}
