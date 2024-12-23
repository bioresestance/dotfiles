{
    description = "NixOS configurations";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs }: {
        nixosConfigurations = {

            Bromma-Laptop = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./configuration.nix
                ];
            };
        };
    };
}