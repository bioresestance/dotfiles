{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.module.apps.development;
in
{
  options = {
    module.apps.development.enable = mkOption {
      description = "Enable development tools and IDEs.";
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # IDEs and Editors
      vscode
      jetbrains.clion

      # Build Tools
      gcc14
      clang
      clang-tools
      cppcheck
      libgcc
      gnumake
      cmake
      extra-cmake-modules
      stdenv.cc.cc.lib
      just
      conan

      # Languages and Runtimes
      python312
      python313Packages.pytest
      go
      jdk21_headless

      # Version Control
      git

      # Code Quality and Linting
      nixfmt-rfc-style
      nixd

      # Infrastructure as Code
      ansible
      ansible-lint

      # Other Development Tools
      platformio
      mongodb-tools
      hugo
    ];
  };
}
