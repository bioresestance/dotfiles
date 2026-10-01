{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      llm-agents,
    }@inputs:

    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
      formatApp = mode: {
        type = "app";
        program = toString (
          pkgs.writeShellScript "format-nix" ''
            export DOTFILES_NIXFMT=${pkgs.nixfmt}/bin/nixfmt
            exec ${pkgs.bash}/bin/bash ./scripts/format.sh ${mode}
          ''
        );
      };
    in
    {
      # Formatter for 'nix fmt'
      formatter.${system} = pkgs.nixfmt;

      # Development environment loaded by direnv via .envrc
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.nixfmt
          pkgs.nixd
        ];
      };

      # Both apps use the same file selection and formatter script.
      apps.${system} = {
        format = formatApp "";
        check-format = formatApp "--check";
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
