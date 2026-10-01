{ pkgs, ... }:

{
  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # Keep /boot from filling up
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amdgpu.exp_hw_support=1" # For experimental GPU support, if applicable

    # MT7925 WiFi stability fixes - disable ASPM power management to prevent driver deadlocks
    "mt7925e.disable_aspm=1"

    # PCIe power management - disable ASPM globally for more stability (can help with warm boot issues)
    "pcie_aspm=off"

    # System stability - enable watchdog and panic handling
    "panic=10" # Reboot 10 seconds after kernel panic
    "kernel.hung_task_panic=1" # Panic (and thus reboot) on hung tasks
    "kernel.hung_task_timeout_secs=300" # Wait 5 minutes before declaring hung

    # Disable PSR (Panel Self Refresh) which can cause display/system hangs on some AMD iGPUs
    "amdgpu.dcdebugmask=0x10"
  ];
  boot.blacklistedKernelModules = [
    "nouveau"
  ];
  # Enable Thunderbolt kernel driver
  boot.kernelModules = [ "thunderbolt" ];

  #systemd configurations
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "30s";
    # Force shutdown even if services don't stop cleanly
    DefaultTimeoutAbortSec = "30s";
    # Watchdog configuration for system manager
    RuntimeWatchdogSec = "30s";
    RebootWatchdogSec = "5min";
    KExecWatchdogSec = "5min";
  };

  # Improve shutdown behavior for user services
  systemd.user.settings.Manager = {
    DefaultTimeoutStopSec = "15s";
    DefaultTimeoutAbortSec = "15s";
  };

  # Enable systemd-oomd for better handling of memory pressure situations
  systemd.oomd.enable = true;

  # Kernel sysctl settings for stability
  boot.kernel.sysctl = {
    # Hung task detection - panic on hung tasks to force reboot instead of permanent freeze
    "kernel.hung_task_panic" = 1;
    "kernel.hung_task_timeout_secs" = 300; # 5 minutes

    # VM/memory tuning to reduce pressure that can trigger driver issues
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;

    # Network stability tuning
    "net.core.netdev_max_backlog" = 4096;
  };
}
