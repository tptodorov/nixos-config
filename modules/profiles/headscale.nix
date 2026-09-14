# Headscale (self-hosted, open-source Tailscale control server) + Tailscale client.
# https://headscale.net/stable/
#
# Every host that imports this profile joins the tailnet as a Tailscale
# client. Pass `headscaleServer = true` via specialArgs (see flake.nix) on
# exactly one host to additionally run the headscale control server there.
{
  pkgs,
  lib,
  headscaleServer ? false,
  ...
}:
let
  # TODO: point this at the real, publicly resolvable hostname for the
  # headscale server (DNS record + port-forward/reverse-proxy to that host).
  # Must match on every client.
  serverDomain = "headscale.example.com";
  serverUrl = "https://${serverDomain}";
in
{
  # --- Tailscale client (all hosts) ---
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--login-server=${serverUrl}" ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  environment.systemPackages = [ pkgs.tailscale ] ++ lib.optionals headscaleServer [ pkgs.headscale ];

  # --- Headscale control server (only the host with headscaleServer = true) ---
  services.headscale = lib.mkIf headscaleServer {
    enable = true;
    settings = {
      server_url = serverUrl;
      listen_addr = "127.0.0.1:8080";
      metrics_listen_addr = "127.0.0.1:9090";

      database.type = "sqlite";

      dns = {
        magic_dns = true;
        base_domain = "ts.${serverDomain}";
      };
    };
  };

  # Reverse proxy with automatic Let's Encrypt TLS for the headscale API.
  # Requires ${serverDomain} to resolve to this machine and ports 80/443
  # forwarded to it.
  services.nginx = lib.mkIf headscaleServer {
    enable = true;
    virtualHosts.${serverDomain} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
    };
  };

  security.acme = lib.mkIf headscaleServer {
    acceptTerms = true;
    defaults.email = "you@example.com"; # TODO: set your personal ACME contact email
  };

  networking.firewall.allowedTCPPorts = lib.mkIf headscaleServer [
    80
    443
  ];
}
