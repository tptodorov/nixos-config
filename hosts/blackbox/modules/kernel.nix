# Kernel configuration for blackbox
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

  # Kernel parameters for desktop performance
  boot.kernelParams = [
    # Disable watchdog (not needed on desktop)
    "nowatchdog"
  ];

  # Kernel sysctl settings for performance
  boot.kernel.sysctl = {
    # Virtual memory tuning
    "vm.swappiness" = 10; # Reduce swap usage
    "vm.vfs_cache_pressure" = 50; # Keep more directory/inode cache

    # Network performance
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
