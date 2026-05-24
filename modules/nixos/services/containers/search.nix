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
      instance_name: "Raclette's SearXNG"

    search:
      safe_search: 0
      autocomplete: brave
      autocomplete_min: 4
      favicon_resolver: yandex
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

    server:
      image_proxy: true

    outgoing:
      request_timeout: 6.0
      max_request_timeout: 15.0
      pool_connections: 200
      pool_maxsize: 50
      keepalive_expiry: 30.0
      enable_http2: true
      retries: 1

    ui:
      hotkeys: vim

    engines:
      # Disable unreliable engines
      - name: duckduckgo
        engine: duckduckgo
        disabled: true
      - name: duckduckgo images
        engine: duckduckgo_extra
        disabled: true
      - name: duckduckgo videos
        engine: duckduckgo_extra
        disabled: true
      - name: duckduckgo news
        engine: duckduckgo_extra
        disabled: true

      # Privacy-friendly general engines disabled by default upstream
      - name: mojeek
        engine: mojeek
        shortcut: mjk
        categories: [general, web]
        disabled: false
      - name: qwant
        engine: qwant
        qwant_categ: web
        shortcut: qw
        categories: [general, web]
        disabled: false
      - name: wiby
        engine: json_engine
        paging: true
        search_url: https://wiby.me/json/?q={query}&p={pageno}
        url_query: URL
        title_query: Title
        content_query: Snippet
        categories: [general, web]
        shortcut: wib
        disabled: false

      # Custom engine instances not in defaults
      - name: nixos wiki
        engine: mediawiki
        shortcut: nixw
        base_url: https://wiki.nixos.org/
        search_type: text
        categories: [it, software wikis]
      - name: codeberg
        engine: gitea
        base_url: https://codeberg.org
        shortcut: cb
      - name: senscritique
        engine: senscritique
        shortcut: scr
        timeout: 6.0
      - name: ollama
        engine: ollama
        shortcut: ollama
      - name: ebay
        engine: ebay
        shortcut: eb
        base_url: 'https://www.ebay.fr'
        inactive: true

      # Overrides for default engines
      - name: reddit
        engine: reddit
        shortcut: re
        page_size: 25
      - name: wikipedia
        engine: wikipedia
        shortcut: wp
        display_type: ["infobox"]
        categories: [general]
      - name: github code
        engine: github_code
        shortcut: ghc
        ghc_auth:
          type: none
          token: token
        ghc_highlight_matching_lines: true
        ghc_strip_new_lines: true
        timeout: 10.0

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
      image = "docker.io/searxng/searxng:2026.1.11-cf74e1d9e@sha256:35e3520e53621e22566330d876d2a36e4a556628b6567bf2706ceb211c6d9c07";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.searxng}:8080"
      ];
      volumes = [
        "${searxngSettings}:/etc/searxng/settings.yml:ro"
      ];
      extraOptions = [
        "--memory=1g"
        "--memory-swap=2g"
        "--pids-limit=256"
      ];
      environment = {
        SEARXNG_BASE_URL = "https://search.${globals.domain}/";
        SEARXNG_VALKEY_URL = "valkey://host.containers.internal:${
          toString config.services.redis.servers."raclette".port
        }";
        FORCE_OWNERSHIP = "false";
        UWSGI_WORKERS = "4";
        UWSGI_THREADS = "4";
      };
      environmentFiles = [
        config.sops.secrets."services/searxng/env".path
      ];
    };
    # "perplexica" = {
    #   image = "itzcrazykns1337/perplexica:slim-v1.11.2@sha256:eb8893a33e4afc686ba0dbc46e2292d030313e01a4621ea5a0779a522ce9c7e0";
    #   ports = [
    #     "${globals.hosts.chewie.ipv4}:${toString globals.ports.perplexica}:3000"
    #   ];
    #   volumes = [
    #     "${?????}/perplexica:/home/perplexica/data:rw"
    #   ];
    #   environment = {
    #     SEARXNG_API_URL = "http://searxng:8080";
    #   };
    # };
  };

}
