{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.module.hardware.audio;
in
{
  options = {
    module.hardware.audio.enable = mkOption {
      description = "Enable audio support with PipeWire.";
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # Enable sound with pipewire
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
