{
  lib,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    searxng = 9030;
  };
in
{
  virtualisation.oci-containers.containers = {
    "searxng" = {
      image = "docker.io/searxng/searxng:2026.1.11-cf74e1d9e";
      ports = [
        "127.0.0.1:${toString ports.searxng}:8080"
      ];
      volumes = [
        "searxng-config:/etc/searxng:rw"
        "searxng-cache:/var/cache/searxng:rw"
      ];
      environment = {
        SEARXNG_BASE_URL = "https://search.${domain}/";
        SEARXNG_VALKEY_URL = "valkey://valkey:6379";
      };
    };
    "valkey" = {
      image = "docker.io/valkey/valkey:9.0.1-alpine3.23";
      volumes = [
        "valkey:/data"
      ];
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @searxng host search.${domain}
    handle @searxng {
      reverse_proxy 127.0.0.1:${toString ports.searxng}
    }
  '';
}
