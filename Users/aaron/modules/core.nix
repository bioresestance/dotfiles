{ ... }:

{
  home.username = "aaron";
  home.homeDirectory = "/home/aaron";
  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      celeste = prev.celeste.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ../patches/celeste-let-chains.patch ];
      });
      remarkable = prev.callPackage ../packages/remarkable.nix { };
      spec-kit = prev.callPackage ../packages/spec-kit.nix { };
    })
  ];

  home.sessionVariables = { };

  programs.home-manager.enable = true;
}
