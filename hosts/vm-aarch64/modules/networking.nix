{ config, pkgs, lib, ... }:
{
  networking.hostName = "vm-aarch64";
  networking.networkmanager.enable = true;

  # Enable mDNS for hostname resolution (blackbox.local)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # Enable OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      PubkeyAuthentication = true;
    };
  };
}
