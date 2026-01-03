{
  pkgs,
  config,
  ...
}:
let
  domain = "r4clette.com";
  caddyWithCloudflare = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
    hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
  };
in
{
  sops.secrets."caddy/chewie" = {
    owner = "caddy";
    group = "caddy";
    mode = "0400";
  };

  services.caddy = {
    enable = true;
    package = caddyWithCloudflare;
    environmentFile = config.sops.secrets."caddy/chewie".path;
    virtualHosts."*.${domain}".extraConfig = ''
      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }

      @hello host hello.${domain}
      handle @hello {
        respond "Hello, World!"
      }

      # default / catch-all
      handle {
        respond "Unknown subdomain"
      }
    '';
  };

  # Only allow access via Tailscale interface
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 80 443 ];
}
