# Kernel configuration for blade
# Uses the latest mainline Linux kernel for best hardware support and performance
{ ... }:
{
  # Additional kernel parameters for laptop optimization
  boot.kernelParams = [
    # Enable power-efficient workqueue for better battery life
    "workqueue.power_efficient=1"

    # Disable watchdog (saves power, reduces unnecessary wake-ups)
    "nowatchdog"

    # Reduce VM writeback time for better responsiveness
    "vm.dirty_writeback_centisecs=1500"
  ];

  # boot.kernelPackages and the shared sysctl tuning now live in
  # modules/profiles/base.nix.
}
