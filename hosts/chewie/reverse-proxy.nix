{
  pkgs,
  config,
  ...
}:
let
  caddyWithCloudflare = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
    hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
  };
in
{
  sops.secrets.caddy-cloudflare-api-token = {
    owner = "caddy";
    group = "caddy";
    mode = "0400";
  };

  services.caddy = {
    enable = true;
    package = caddyWithCloudflare;
    environmentFile = config.sops.secrets.caddy-cloudflare-api-token.path;
    virtualHosts."*.r4clette.com".extraConfig = ''
      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }

      @hello host hello.r4clette.com
      handle @hello {
        reverse_proxy 127.0.0.1:9000
      }

      @foo host foo.r4clette.com
      handle @foo {
        respond "bar"
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

  # debug
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.hello-world = {
    image = "ghcr.io/kljensen/hello-world-http@sha256:c47f2272676e251a31415462aa3d308aa3efc72dfbf336922546c400d8708595"; # renovate: datasource=docker depName=ghcr.io/kljensen/hello-world-http
    autoStart = true;

    ports = [
      "127.0.0.1:9000:80"
    ];

    environment = {
      HOST = "0.0.0.0";
      PORT = "80";
    };
  };
}
