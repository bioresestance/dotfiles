{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.module.hardware.gpu.hybrid;
in
{
  options = {
    module.hardware.gpu.hybrid.enable = mkOption {
      description = "Enable hybrid GPU support (NVIDIA + AMD).";
      default = false;
      type = types.bool;
    };

    module.hardware.gpu.hybrid.nvidiaBusId = mkOption {
      description = "PCI Bus ID for NVIDIA GPU.";
      default = "PCI:100:0:0";
      type = types.str;
    };

    module.hardware.gpu.hybrid.amdgpuBusId = mkOption {
      description = "PCI Bus ID for AMD GPU.";
      default = "PCI:101:0:0";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # Enable OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # AMD GPU support
    hardware.amdgpu.initrd.enable = true;

    # Load nvidia driver for Xorg and Wayland
    services.xserver = {
      enable = true;
      videoDrivers = [
        "nvidia"
        "amdgpu"
      ];
    };

    hardware.nvidia = {
      # Modesetting is required
      modesetting.enable = true;

      # Nvidia power management
      powerManagement.enable = true;

      # Fine-grained power management (turns off GPU when not in use)
      # Works on Turing or newer GPUs
      powerManagement.finegrained = true;

      # Use open source kernel module
      open = true;

      # Disable Nvidia settings menu
      nvidiaSettings = false;

      # Use latest driver version
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      # Configure NVIDIA Prime for hybrid graphics
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        nvidiaBusId = cfg.nvidiaBusId;
        amdgpuBusId = cfg.amdgpuBusId;
      };
    };
  };
}
