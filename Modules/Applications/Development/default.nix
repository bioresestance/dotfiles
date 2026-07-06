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

      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          libglvnd
          mesa

          stdenv.cc.cc
          zlib

          libx11
          libxext
          libxrender
          libsm
          libice

          fontconfig
          freetype
          glib

          expat
          libGL

        ];
      };

      environment.systemPackages = [
        globalPython
        (pkgs.python313Packages.pipx.overridePythonAttrs (_: {
          # Tests fail on nixpkgs unstable due to packaging lib output formatting changes.
          doCheck = false;
          doInstallCheck = false;
        }))
      ]
      ++ (with pkgs; [
        # IDEs and Editors
        jetbrains.clion

        # Build Tools
        gcc14
        clang
        clang-tools
        cppcheck
        libgcc
        gnumake
        cmake
        kdePackages.extra-cmake-modules
        stdenv.cc.cc.lib
        just
        (conan.overridePythonAttrs (old: {
          pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "patch-ng" ];
          doCheck = false;
          doInstallCheck = false;
        }))

        # Languages and Runtimes
        go
        jdk21_headless
        nodejs_22

        # Version Control
        git

        # Code Quality and Linting
        nixfmt
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
        minicom
      ]);
    }
  );
}
