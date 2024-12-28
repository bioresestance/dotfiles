{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-vscode-extensions,
    }@inputs:

    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        Bromma-Laptop = lib.nixosSystem {
          inherit system;
          modules = [ ./Systems/Bromma-Laptop/configuration.nix ];
          specialArgs = {
            inherit inputs;
          };
        };
      };
      homeConfigurations = {
        aaron = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./Users/aaron/home.nix ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
      };
    };
}
