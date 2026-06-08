{ ... }:

{
  imports = [
    ./modules/core.nix
    ./modules/packages.nix
    ./modules/identity.nix
    ./modules/shell.nix
    ./modules/terminal.nix
    ./modules/fastfetch.nix
    ./modules/desktop.nix
    ./modules/editors.nix
  ];
}
