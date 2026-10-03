{
  pkgs,
  lib,
  config,
  globals,
  ...
}:
let
  caddyWithCloudflare = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
    hash = "sha256-xAw+kBA+rdhzABdogwNCo9zEtNMPG7zj5rgPpFxvpDo=";
  };
in
{
  sops.secrets."caddy/env" = {
    owner = "caddy";
    group = "caddy";
    mode = "0400";
  };

  services.caddy = {
    enable = true;
    package = caddyWithCloudflare;
    environmentFile = config.sops.secrets."caddy/env".path;
    virtualHosts."*.${globals.domain}".extraConfig = lib.mkOrder 9999 ''
      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }

      @hello host test.${globals.domain}
      handle @hello {
        respond "Hello, World from leia!"
      }

      # default / catch-all
      handle {
        respond "Unknown subdomain" 404
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    80
    443
    globals.ports.loki-http
  ];
  networking.firewall.interfaces.enp1s0.allowedTCPPorts = [
    80
    443
  ];

  # Add nebula1 and globals.ports.loki-http here when Nebula (${globals.nebulaCidr}) is deployed on leia.
  # networking.firewall.interfaces.nebula1.allowedTCPPorts = [ globals.ports.loki-http ];
}
