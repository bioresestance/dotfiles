{ ... }:

{
  home.username = "aaron";
  home.homeDirectory = "/home/aaron";
  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      celeste = prev.celeste.overrideAttrs (old: {
        env = (old.env or { }) // {
          RUSTC_BOOTSTRAP = "celeste";
        };
      });
      remarkable = prev.callPackage ../packages/remarkable.nix { };
      spec-kit = prev.callPackage ../packages/spec-kit.nix { };
      claude-code = prev.callPackage ../packages/claude-code.nix { };
    })
  ];

  home.sessionVariables = { };

  programs.home-manager.enable = true;
}
