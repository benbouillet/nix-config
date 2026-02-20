{ ... }:
let
  globals = {
    domain = "r4clette.com";
    ports = {
      mysql = 3306;
      lldapLdap = 3890;
      postgres = 5432;
      redis = 6379;
      steam = 8083;
      bazarr = 9010;
      prowlarr = 9011;
      radarr = 9012;
      sonarr = 9013;
      jellyseerr = 9014;
      jellyfin = 9015;
      qbittorrent = 9016;
      nzbget = 9017;
      ollama = 9020;
      open-webui = 9021;
      searxng = 9030;
      perplexica = 9031;
      paperless = 9040;
      nextcloud = 9050;
      opencloud = {
        proxy = 9051;
        webdav = 9052;
        debug = 9053;
      };
      seafile = 9054;
      prometheus = 9090;
      authelia = 9091;
      prometheus-alertmanager = 9093;
      prometheus-alertmanager-ntfy = 9095;
      ntfy = 9094;
      debug = 9999;
      lldapWebUi = 17170;
      prometheus_exporters = {
        node = 9000;
        blackbox = 9115;
        zfs = 9116;
      };
    };
    users = {
      steam = {
        name = "steam";
        UID = 950;
      };
      arr = {
        name = "arr";
        UID = 920;
      };
      authelia = {
        name = "authelia";
        UID = 930;
      };
      lldap = {
        name = "lldap";
        UID = 931;
      };
      opencloud = {
        name = "opencloud";
        UID = 940;
      };
      seafile = {
        name = "seafile";
        UID = 950;
      };
    };
    groups = {
      authentication = {
        name = "authent";
        GID = 930;
      };
      oidc = {
        name = "oidc";
        GID = 931;
      };
      steam = {
        name = "steam";
        GID = 950;
      };
      containers = {
        name = "containers";
        GID = 993;
      };
      opencloud = {
        name = "opencloud";
        GID = 940;
      };
      seafile = {
        name = "seafile";
        GID = 950;
      };
    };
    paths = {
      paperlessMedia = "/srv/documents";
      games = "/srv/games";
      containersVolumes = "/srv/containers";
      models = "/srv/models";
      mediaVolume = "/srv/arrdata";
      nextcloud = "/srv/nextcloud";
      opencloud = "/srv/opencloud";
      postgres = "/srv/postgres";
    };
    podmanBridgeCIDR = "10.88.0.0/16";
  };
in
{
  _module.args.globals = globals;
}
