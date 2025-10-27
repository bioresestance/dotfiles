{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.module.apps.gaming;
in
{
  options = {
    module.apps.gaming.enable = mkOption {
      description = "Enable gaming support (Steam).";
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
    };
  };
}
