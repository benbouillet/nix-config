{
  lib,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    opencloud = 9050;
  };
  users = {
    opencloud = {
      name = "opencloud";
      UID = 960;
    };
  };
  groups = {
    opencloud = {
      name = "opencloud";
      GID = 960;
    };
  };
  dataPath = "/srv/opencloud";
in
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${dataPath} 2770 ${users.opencloud.name} ${groups.opencloud.name} - -"
  ];

  users.users."${users.opencloud.name}" = {
    isSystemUser = true;
    uid = users.opencloud.UID;
    group = groups.opencloud.name;
  };

  services.opencloud = {
    enable = true;
    stateDir = dataPath;
    user = users.opencloud.name;
    url = "https://opencloud.${domain}";
    address = "127.0.0.1";
    port = ports.opencloud;
    environment = {
      PROXY_TLS = "false";
    };
  };
  # services.opencloud = {
  #   enable = true;
  #   environment = {
  #     OC_INSECURE = "true";
  #     OC_LOG_LEVEL = "error";
  #     PROXY_TLS = "false";
  #   };
  #   settings = {
  #     # /etc/opencloud/proxy.yaml
  #     proxy = {
  #       # Per-service log level (still keep OC_LOG_LEVEL for global default)
  #       log_level = "info";
  #
  #       # OIDC behaviour – harmless now, useful once you plug in an external IdP.
  #       oidc = {
  #         # Makes OpenCloud rewrite the .well-known URL when sitting behind a proxy.
  #         rewrite_well_known = true;
  #       };
  #
  #       # When you later use an external OIDC IdP, this will auto-create users.
  #       auto_provision_accounts = true;
  #       auto_provision_claims = {
  #         username = "preferred_username";
  #         email = "email";
  #         display_name = "name";
  #         groups = "groups";
  #       };
  #
  #       # Optional role mapping from an OIDC claim → OpenCloud roles.
  #       # This doesn’t do anything until you actually have such a claim.
  #       role_assignment = {
  #         driver = "oidc";
  #         oidc_role_mapper = {
  #           # Name of the claim in your IdP token that contains roles
  #           role_claim = "opencloud_roles";
  #
  #           # Uncomment & adapt once you have real roles in your IdP:
  #           # role_mapping = [
  #           #   { role_name = "admin";      claim_value = "admin"; }
  #           #   { role_name = "spaceadmin"; claim_value = "spaceadmin"; }
  #           #   { role_name = "user";       claim_value = "user"; }
  #           #   { role_name = "guest";      claim_value = "guest"; }
  #           # ];
  #         };
  #       };
  #     };
  #
  #     # /etc/opencloud/web.yaml
  #     web = {
  #       web = {
  #         config = {
  #           oidc = {
  #             # Good default scope if/when you enable external OIDC
  #             scope = "openid profile email opencloud_roles";
  #           };
  #         };
  #       };
  #     };
  #   };
  # };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @opencloud host opencloud.${domain}
    handle @opencloud {
      reverse_proxy 127.0.0.1:${toString ports.opencloud}
    }
  '';
}
