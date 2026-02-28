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
      seerr = 9014;
      jellyfin = 9015;
      qbittorrent = 9016;
      nzbget = 9017;
      ollama = 9020;
      open-webui = 9021;
      searxng = 9030;
      perplexica = 9031;
      paperless = 9040;
      nextcloud = 9050;
      seafile = 9054;
      seafile-notification-server = 9055;
      mealie = 9060;
      prometheus = 9090;
      authelia = 9091;
      prometheus-alertmanager = 9092;
      prometheus-alertmanager-ntfy = 9093;
      ntfy = 9094;
      grafana = 9095;
      loki-http = 9096;
      loki-grpc = 9097;
      promtail-http = 9098;
      promtail-grpc = 9099;
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
      seafile = "/srv/seafile";
      postgres = "/srv/postgres";
    };
    zfs = {
      databases = {
        postgres = {
          name = "ssd/db/postgres";
          mountPoint = "/srv/db/postgres";
        };
        mysql = {
          name = "ssd/db/mysql";
          mountPoint = "/srv/db/mysql";
        };
      };
      services = {
        infra = {
          name = "ssd/services/infra";
          mountPoint = "/srv/services/infra";
        };
        apps = {
          name = "ssd/services/apps";
          mountPoint = "/srv/services/apps";
        };
      };
      data = {
        vaultwarden = {
          name = "ssd/data/vaultwarden";
          mountPoint = "/srv/data/vaultwarden";
        };
        loki = {
          name = "ssd/data/loki";
          mountPoint = "/srv/data/loki";
        };
        media = {
          name = "hdd/data/media";
          mountPoint = "/srv/data/media";
        };
        seafile = {
          name = "hdd/data/seafile";
          mountPoint = "/srv/data/seafile";
        };
        paperless = {
          name = "hdd/data/paperless";
          mountPoint = "/srv/data/paperless";
        };
        immich = {
          name = "hdd/data/immich";
          mountPoint = "/srv/data/immich";
        };
      };
    };
    podmanBridgeCIDR = "10.88.0.0/16";
  };
in
{
  _module.args.globals = globals;
}
