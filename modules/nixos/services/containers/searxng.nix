{
  pkgs,
  config,
  lib,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    searxng = 9030;
  };
  searxngSettings = pkgs.writeText "settings.yml" ''
    use_default_settings: true
    general:
      debug: false
      instance_name: "SearXNG"
    search:
      safe_search: 0
      autocomplete: "duckduckgo"
      autocomplete_min: 4
      favicon_resolver: "allesedv"
      default_lang: "en"
      languages:
        - all
        - en
        - en-US
        - de
        - de-BE
        - de-CH
        - de-DE
        - it-IT
        - fr
        - fr-BE
        - nl
        - nl-BE
        - nl-NL
    ui:
      hotkeys: vim
  '';
in
{
  sops.secrets."services/searxng" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  fileSystems."/var/cache/searxng" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "size=256M"
      "mode=0755"
    ];
  };

  virtualisation.oci-containers.containers = {
    "searxng" = {
      image = "docker.io/searxng/searxng:2026.1.11-cf74e1d9e";
      ports = [
        "127.0.0.1:${toString ports.searxng}:8080"
      ];
      volumes = [
        "${searxngSettings}:/etc/searxng/settings.yml:ro"
        "searxng-cache:/var/cache/searxng:rw"
      ];
      environment = {
        SEARXNG_BASE_URL = "https://search.${domain}/";
        SEARXNG_VALKEY_URL = "valkey://valkey:6379";
      };
      environmentFiles = [
        config.sops.secrets."services/searxng".path
      ];
    };
    "valkey" = {
      image = "docker.io/valkey/valkey:9.0.1-alpine3.23";
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @searxng host search.${domain}
    handle @searxng {
      reverse_proxy 127.0.0.1:${toString ports.searxng}
    }
  '';
}
