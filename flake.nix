{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }@inputs:

    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Formatter for 'nix fmt'
      formatter.${system} = pkgs.nixfmt;

      # Apps for common tasks
      apps.${system} = {
        format = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "format" ''
              set -e
              echo "Formatting all Nix files..."
              find . -name "*.nix" -type f \
                ! -path "./.git/*" \
                ! -path "./result/*" \
                ! -path "./result-*/*" \
                -print0 | xargs -0 ${pkgs.nixfmt}/bin/nixfmt
              echo "✓ All files formatted!"
            ''
          );
        };
        check-format = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "check-format" ''
              set -e
              echo "Checking formatting of all Nix files..."
              find . -name "*.nix" -type f \
                ! -path "./.git/*" \
                ! -path "./result/*" \
                ! -path "./result-*/*" \
                -print0 | xargs -0 ${pkgs.nixfmt}/bin/nixfmt --check
              echo "✓ All files are properly formatted!"
            ''
          );
        };
      };

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
