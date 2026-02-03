{
  pkgs,
  config,
  lib,
  globals,
  ...
}:
let
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
      formats:
        - html
        - json
    ui:
      hotkeys: vim
    engines:
      - name: wikidata
        disabled: false
      - name: ahmia
        disabled: false
      - name: torch
        disabled: false
      - name: wolframalpha
        disabled: false
  '';
in
{
  sops.secrets."services/searxng/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.containersVolumesPath}/perplexica 2770 root ${globals.groups.containers.name} - -"
  ];

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
        "127.0.0.1:${toString globals.ports.searxng}:8080"
      ];
      volumes = [
        "${searxngSettings}:/etc/searxng/settings.yml:ro"
        "searxng-cache:/var/cache/searxng:rw"
      ];
      environment = {
        SEARXNG_BASE_URL = "https://search.${globals.domain}/";
        SEARXNG_VALKEY_URL = "valkey://valkey:6379";
      };
      environmentFiles = [
        config.sops.secrets."services/searxng/env".path
      ];
    };
    "perplexica" = {
      image = "itzcrazykns1337/perplexica:slim-v1.11.2";
      ports = [
        "127.0.0.1:${toString globals.ports.perplexica}:3000"
      ];
      volumes = [
        "${globals.containersVolumesPath}/perplexica:/home/perplexica/data:rw"
      ];
      environment = {
        SEARXNG_API_URL = "http://searxng:8080";
      };
    };
    "valkey" = {
      image = "docker.io/valkey/valkey:9.0.2-alpine3.23";
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @searxng host search.${globals.domain}
    handle @searxng {
      reverse_proxy 127.0.0.1:${toString globals.ports.searxng}
    }

    @perplexica host perplexica.${globals.domain}
    handle @perplexica {
      reverse_proxy 127.0.0.1:${toString globals.ports.perplexica}
    }
  '';
}
