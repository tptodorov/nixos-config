{ config, pkgs, lib, ... }:
{
  # SSH public keys for user authentication
  users.users.todor.openssh.authorizedKeys.keys = [
    config.sops.secrets.ssh_public_key
  ];
}