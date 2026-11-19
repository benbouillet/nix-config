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
    hash = "sha256-nVNQBiT5CsTBz8cVf5OCXBEwc7oD693DX2CClZCegTc=";
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

  networking.firewall = {
    allowedTCPPorts = [ ];
    interfaces = {
      tailscale0.allowedTCPPorts = [
        80
        443
        globals.ports.loki-http
      ];
      enp1s0.allowedTCPPorts = [
        80
        443
      ];
    };
  };
}
