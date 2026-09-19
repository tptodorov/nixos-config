{ ... }:
{
  networking.hostName = "blade";

  # networkmanager, avahi, and openssh are already enabled with these exact
  # settings in modules/profiles/base.nix; blade has nothing to add here.
}
