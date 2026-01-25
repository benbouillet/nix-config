{
  lib,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    nextcloud = 9040;
    authelia = 9091;
  };
  users = {
    nextcloud = {
      name = "nextcloud";
      UID = 940;
    };
  };
  groups = {
    containers = {
      name = "containers";
      GID = 993;
    };
    oidc = {
      name = "oidc";
      GID = 931;
    };
  };
  dataPath = "/srv/nextcloud";
  containersVolumesPath = "/srv/containers";
in
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${dataPath} 2770 root ${groups.containers.name} - -"
    "d ${containersVolumesPath}/nextcloud 2770 root ${groups.containers.name} - -"
  ];

  users.users."${users.nextcloud.name}" = {
    isSystemUser = true;
    createHome = false;
    uid = users.nextcloud.UID;
    group = groups.containers.name;
    extraGroups = [ groups.oidc.name ];
  };

  services.authelia.instances."raclette".settings = {
    access_control = {
      default_policy = "deny";
      rules = [
        {
          domain = "nextcloud.${domain}";
          policy = "one_factor";
          subject = "group:nextcloud";
        }
      ];
    };
    definitions.user_attributes.is_nextcloud_admin = {
      expression = ''"nextcloud-admins" in groups'';
    };
    identity_providers.oidc = {
      claims_policies.nextcloud_userinfo.custom_claims.is_nextcloud_admin = {
        attribute = "is_nextcloud_admin";
      };
      scopes.nextcloud_userinfo.claims = [ "is_nextcloud_admin" ];
      clients = [
        {
          client_id = "nextcloud";
          client_name = "Nextcloud";
          client_secret = "$pbkdf2-sha512$310000$eyITXRD6EHqMB0msWEqBNQ$V0D6V57a8NXZKj8HU3wLEjyU/XJJ5JxnFsMisO9vtdGAs.E.MX6z.HQWRl8Ik4c0zAse6MmrVlvLe8TQ53nbQg";
          public = false;

          authorization_policy = "two_factor";

          claims_policy = "nextcloud_userinfo";
          consent_mode = "implicit";

          redirect_uris = [
            "https://nextcloud.${domain}/apps/oidc_login/oidc"
          ];

          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
            "nextcloud_userinfo"
          ];
        }
      ];
    };
  };

  services.postgresql = {
    enable = lib.mkForce true;
    ensureDatabases = lib.mkAfter [
      "nextcloud"
    ];
    ensureUsers = lib.mkAfter [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
          connection_limit = 5;
          password = "SCRAM-SHA-256$4096:Cc/AgwrBKpl+BzAfjHoC3Q==$YvNfzHFoe5NkSAcwyqzZ1HYtpv6SS5alQNE0e9+ZKQg=:KCsAXDaEAyRmG8vcCzJMQm2LRz9QZS9n46NzPq5Pgc0=";
        };
      }
    ];
  };

  virtualisation.oci-containers.containers = {
    "nextcloud" = {
      image = "lscr.io/linuxserver/nextcloud:32.0.5-ls412";
      environment = {
        PUID = toString users.nextcloud.UID;
        PGID = toString groups.containers.GID;
        TZ = "Europe/Paris";
      };
      ports = [
        "127.0.0.1:${toString ports.nextcloud}:80"
      ];
      volumes = [
        "${containersVolumesPath}/nextcloud/:/config/:rw"
        "${dataPath}/:/data/:rw"
      ];
      extraOptions = [
        "--add-host=auth.r4clette.com:host-gateway"
      ];
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @nextcloud host nextcloud.${domain}
    handle @nextcloud {
      reverse_proxy 127.0.0.1:${toString ports.nextcloud}
    }
  '';
}
