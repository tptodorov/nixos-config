# Kernel configuration for blade
# Uses the latest mainline Linux kernel for best hardware support and performance
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Use the latest stable Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Additional kernel parameters for laptop optimization
  boot.kernelParams = [
    # Enable power-efficient workqueue for better battery life
    "workqueue.power_efficient=1"

    # Disable watchdog (saves power, reduces unnecessary wake-ups)
    "nowatchdog"

    # Reduce VM writeback time for better responsiveness
    "vm.dirty_writeback_centisecs=1500"
  ];

  # Enable kernel modules for better hardware support
  boot.kernelModules = [
    # Uncomment if you need specific modules
    # "tcp_bbr"  # BBR TCP congestion control
  ];

  # Kernel sysctl settings for performance and battery life
  boot.kernel.sysctl = {
    # Virtual memory tuning
    "vm.swappiness" = 10; # Reduce swap usage
    "vm.vfs_cache_pressure" = 50; # Keep more directory/inode cache

    # Network performance
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
