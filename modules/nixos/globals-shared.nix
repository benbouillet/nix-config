{ ... }:
let
  globals = {
    domain = "r4clette.com";
    hosts = {
      chewie = {
        ipv4 = "100.93.247.22";
      };
      leia = {
        ipv4 = "100.115.146.98";
      };
      yoda = {
        ipv4 = "100.77.229.105";
      };
    };
    ports = {
      mysql = 3306;
      postgres = 5432;
      redis = 6379;
      bazarr = 9010;
      prowlarr = 9011;
      radarr = 9012;
      sonarr = 9013;
      seerr = 9014;
      jellyfin = 9015;
      qbittorrent = 9016;
      nzbget = 9017;
      foundryvtt = 9021;
      linkding = 9022;
      searxng = 9030;
      perplexica = 9031;
      paperless = 9040;
      seafile = 9054;
      seafile-notification-server = 9055;
      mealie = 9060;
      immich = 9061;
      lubelogger = 9062;
      radicale = 9063;
      vaultwarden = 9070;
      llama-swap = 9080;
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
      prometheus_exporters = {
        node = 9000;
        blackbox = 9115;
        zfs = 9116;
      };
    };
    users = {
      arr = {
        name = "arr";
        UID = 920;
      };
      authelia = {
        name = "authelia";
        UID = 930;
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
      containers = {
        name = "containers";
        GID = 993;
      };
      seafile = {
        name = "seafile";
        GID = 950;
      };
    };
  };
in
{
  _module.args.globals = globals;
}
