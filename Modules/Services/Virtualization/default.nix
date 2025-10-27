{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.module.services.virtualization;
in
{
  options = {
    module.services.virtualization.enable = mkOption {
      description = "Enable virtualization support (Docker).";
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
  };
}
