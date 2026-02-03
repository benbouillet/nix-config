{ ... }:
let
  globals = {
    domain = "r4clette.com";
    ports = {
      steam = 8083;
      authelia = 9091;
      ollama = 9020;
      open-webui = 9021;
      bazarr = 9010;
      prowlarr = 9011;
      radarr = 9012;
      sonarr = 9013;
      jellyseerr = 9014;
      jellyfin = 9015;
      qbittorrent = 9016;
      nzbget = 9017;
      debug = 9999;
      searxng = 9030;
      perplexica = 9031;
      postgres = 5432;
      lldapWebUi = 17170;
      lldapLdap = 3890;
      redis = 6379;
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
    gamesVolumePath = "/srv/games";
    containersVolumesPath = "/srv/containers";
    modelsPath = "/srv/models";
    mediaVolumePath = "/srv/arrdata";
    dbPath = "/srv/postgres";
  };
in
{
  _module.args.globals = globals;
}
