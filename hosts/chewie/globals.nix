{ ... }:
let
  globals = {
    domain = "r4clette.com";
    ports = {
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
      authelia = 9091;
      debug = 9999;
      lldapWebUi = 17170;
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
    };
    groups = {
      steam = {
        name = "steam";
        GID = 950;
      };
      containers = {
        name = "containers";
        GID = 993;
      };
      authentication = {
        name = "authent";
        GID = 930;
      };
      oidc = {
        name = "oidc";
        GID = 931;
      };
    };
    paths = {
      paperlessMedia = "/srv/documents";
      games = "/srv/games";
      containersVolumes = "/srv/containers";
      models = "/srv/models";
      mediaVolume = "/srv/arrdata";
      postgres = "/srv/postgres";
    };
    podmanBridgeCIDR = "10.88.0.0/16";
  };
in
{
  _module.args.globals = globals;
}
