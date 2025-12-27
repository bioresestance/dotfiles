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

  config = mkIf cfg.enable (
    let
      globalPython = pkgs.python313.withPackages (ps: [
        ps.proxmoxer
        ps.pytest
        ps."ansible-core"
      ]);
    in
    {
      nixpkgs.config.permittedInsecurePackages = [
        "segger-jlink-qt4-874"
        "snapmaker-luban-4.15.0"
      ];
      nixpkgs.config.segger-jlink.acceptLicense = true;

      environment.systemPackages = [
        globalPython
        pkgs.python313Packages.pipx
      ]
      ++ (with pkgs; [
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
        go
        jdk21_headless

        # Version Control
        git

        # Code Quality and Linting
        nixfmt-rfc-style
        nixd
        ansible-lint

        # Infrastructure as Code

        # Other Development Tools
        direnv
        platformio
        avrdude
        openocd
        segger-jlink
        mongodb-tools
        hugo
        github-copilot-cli
        gh
        jq
        iperf3
        unzip
        traceroute
      ]);
    }
  );
}
