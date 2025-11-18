{ config, pkgs, lib, ... }:
{
  networking.hostName = "blackbox";
  networking.networkmanager.enable = true;

  # Create NetworkManager connection file for USB gadget
  environment.etc."NetworkManager/system-connections/usb-gadget.nmconnection" = {
    text = ''
      [connection]
      id=usb-gadget
      type=ethernet
      interface-name=usb0
      autoconnect=true
      autoconnect-priority=100

      [ethernet]

      [ipv4]
      address1=192.168.10.1/24
      method=manual

      [ipv6]
      addr-gen-mode=stable-privacy
      method=auto

      [proxy]
    '';
    mode = "0600";
  };

  # Create NetworkManager connection file for Thunderbolt bridge
  environment.etc."NetworkManager/system-connections/thunderbolt-bridge.nmconnection" = {
    text = ''
      [connection]
      id=thunderbolt-bridge
      type=ethernet
      interface-name=thunderbolt0
      autoconnect=true
      autoconnect-priority=90

      [ethernet]

      [ipv4]
      address1=192.168.20.1/24
      address2=169.254.20.1/16
      method=manual

      [ipv6]
      addr-gen-mode=stable-privacy
      method=auto

      [proxy]
    '';
    mode = "0600";
  };

  # Load USB gadget module at boot
  systemd.services.usb-gadget-module = {
    description = "Load USB Gadget Module";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = "${pkgs.kmod}/bin/modprobe g_ether";
  };

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
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      PubkeyAuthentication = true;
    };
  };
}