{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.module.desktop.plasma;
in
{
  options = {
    module.desktop.plasma.enable = mkOption {
      description = "Enable KDE Plasma Desktop Environment with SDDM.";
      default = false;
      type = types.bool;
    };

    module.desktop.plasma.autoLogin = {
      enable = mkOption {
        description = "Enable automatic login.";
        default = false;
        type = types.bool;
      };

      user = mkOption {
        description = "User to automatically log in.";
        default = "";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable the KDE Plasma Desktop Environment
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;

    # Enable automatic login if configured
    services.displayManager.autoLogin = mkIf cfg.autoLogin.enable {
      enable = true;
      user = cfg.autoLogin.user;
    };
    services.displayManager.defaultSession = mkIf cfg.autoLogin.enable "plasma";

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
    environment.systemPackages = with pkgs; [
      kdePackages.kwallet-pam # Allows automatic unlocking of KWallet when wallet password matches user password.
    ];
  };
}
