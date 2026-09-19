# Kernel configuration for blackbox
# Uses the latest mainline Linux kernel for best hardware support and performance
{ ... }:
{
  # Kernel parameters for desktop performance
  boot.kernelParams = [
    # Disable watchdog (not needed on desktop)
    "nowatchdog"
  ];

  # boot.kernelPackages and the shared sysctl tuning now live in
  # modules/profiles/base.nix.
}
