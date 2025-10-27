{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.module.apps.security;
in
{
  options = {
    module.apps.security.enable = mkOption {
      description = "Enable security applications (1Password).";
      default = false;
      type = types.bool;
    };

    module.apps.security.polkitPolicyOwners = mkOption {
      description = "List of users to grant 1Password polkit policies.";
      default = [ ];
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = cfg.polkitPolicyOwners;
    };
  };
}
