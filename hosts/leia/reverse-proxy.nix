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
    hash = "sha256-VBmICI1wklu02jmgDRmmlfNc9ftK7a74uF280xzx8uc=";
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
  ];
}
