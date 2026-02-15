{
  pkgs,
  config,
  lib,
  globals,
  ...
}:
let
  searxngSettings = pkgs.writeText "settings.yml" ''
    use_default_settings:
      engines:
        keep_only:
          - arch linux wiki
          - nixos wiki
          - bandcamp
          - wikipedia
          - openverse
          - docker hub
          - ebay
          - findthatmeme
          - free software directory
          - gitlab
          - github
          - github code
          - codeberg
          - goodreads
          - hackernews
          - ollama
          - openstreetmap
          - podcastindex
          - radio browser
          - reddit
          - duckduckgo
          - duckduckgo images
          - duckduckgo videos
          - stackoverflow
          - steam
          - senscritique
          - ahmia
          - torch
          - wolframalpha

    general:
      debug: false
      instance_name: "Raclette's SearXNG"

    search:
      safe_search: 0
      autocomplete: duckduckgo
      autocomplete_min: 4
      favicon_resolver: duckduckgo
      default_lang: auto
      languages:
        - all
        - en
        - de
        - fr
        - nl
      formats:
        - html
        - json

    ui:
      hotkeys: vim

    engines:
      - name: arch linux wiki
        engine: archlinux
        shortcut: al
      - name: nixos wiki
        engine: mediawiki
        shortcut: nixw
        base_url: https://wiki.nixos.org/
        search_type: text
        categories: [it, software wikis]
      - name: bandcamp
        engine: bandcamp
        shortcut: bc
        categories: music
      - name: wikipedia
        engine: wikipedia
        shortcut: wp
        # add "list" to the array to get results in the results list
        display_type: ["infobox"]
        categories: [general]
      - name: openverse
        engine: openverse
        categories: images
        shortcut: opv
      - name: docker hub
        engine: docker_hub
        shortcut: dh
        categories: [it, packages]
      - name: ebay
        engine: ebay
        shortcut: eb
        base_url: 'https://www.ebay.fr'
        inactive: true
        timeout: 5
      - name: findthatmeme
        engine: findthatmeme
        shortcut: ftm
      - name: free software directory
        engine: mediawiki
        shortcut: fsd
        categories: [it, software wikis]
        base_url: https://directory.fsf.org/
        search_type: title
        timeout: 5.0
        about:
          website: https://directory.fsf.org/
          wikidata_id: Q2470288
      - name: gitlab
        engine: gitlab
        base_url: https://gitlab.com
        shortcut: gl
        about:
          website: https://gitlab.com/
          wikidata_id: Q16639197
      - name: github
        engine: github
        shortcut: gh
      - name: github code
        engine: github_code
        shortcut: ghc
        ghc_auth:
          # type is one of:
          # * none
          # * personal_access_token
          # * bearer
          # When none is passed, the token is not requried.
          type: none
          token: token
        # specify whether to highlight the matching lines to the query
        ghc_highlight_matching_lines: true
        ghc_strip_new_lines: true
        ghc_strip_whitespace: false
        timeout: 10.0
      - name: codeberg
        # https://docs.searxng.org/dev/engines/online/gitea.html
        engine: gitea
        base_url: https://codeberg.org
        shortcut: cb
      - name: goodreads
        engine: goodreads
        shortcut: good
        timeout: 4.0
      - name: hackernews
        engine: hackernews
        shortcut: hn
      - name: ollama
        engine: ollama
        shortcut: ollama
      - name: openstreetmap
        engine: openstreetmap
        shortcut: osm
      - name: podcastindex
        engine: podcastindex
        shortcut: podcast
      - name: radio browser
        engine: radio_browser
        shortcut: rb
      - name: reddit
        engine: reddit
        shortcut: re
        page_size: 25
      - name: stackoverflow
        engine: stackexchange
        shortcut: st
        api_site: 'stackoverflow'
        categories: [it, q&a]
      - name: duckduckgo
        engine: duckduckgo
        shortcut: ddg
      - name: duckduckgo images
        engine: duckduckgo_extra
        categories: [images, web]
        ddg_category: images
        shortcut: ddi
      - name: duckduckgo videos
        engine: duckduckgo_extra
        categories: [videos, web]
        ddg_category: videos
        shortcut: ddv
      - name: duckduckgo news
        engine: duckduckgo_extra
        categories: [news, web]
        ddg_category: news
        shortcut: ddn
        disabled: true
      - name: steam
        engine: steam
        shortcut: stm
      - name: senscritique
        engine: senscritique
        shortcut: scr
        timeout: 4.0

    doi_resolvers:
      oadoi.org: 'https://oadoi.org/'
      doi.org: 'https://doi.org/'
      sci-hub.se: 'https://sci-hub.se/'
      sci-hub.st: 'https://sci-hub.st/'
      sci-hub.ru: 'https://sci-hub.ru/'

    default_doi_resolver: 'doi.org'
  '';
in
{
  sops.secrets."services/searxng/env" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.paths.containersVolumes}/perplexica 2770 root ${globals.groups.containers.name} - -"
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
        SEARXNG_VALKEY_URL = "valkey://host.containers.internal:${
          toString config.services.redis.servers."raclette".port
        }";
        FORCE_OWNERSHIP = "false";
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
        "${globals.paths.containersVolumes}/perplexica:/home/perplexica/data:rw"
      ];
      environment = {
        SEARXNG_API_URL = "http://searxng:8080";
      };
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
