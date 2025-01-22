{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.module.apps.tailscale;
in
{
  options = {
    module.apps.tailscale.enable = mkOption {
      description = "Enable Tailscale Module.";
      default = true;
      type = types.bool;
    };

  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tailscale
    ];

    services.tailscale = {
      enable = true;
    };
  };
}
