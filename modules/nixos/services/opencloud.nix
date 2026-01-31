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
  sops.secrets."opencloud/env" = {
    mode = "0400";
    owner = users.opencloud.name;
    group = groups.opencloud.name;
  };

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
    url = "https://opencloud.${domain}";
    address = "127.0.0.1";
    port = ports.opencloud;
    settings = {
      api = {
        graph_assign_default_user_role = true;
        graph_username_match = "none";
      };
      proxy = {
        auto_provision_accounts = true;
        oidc.rewrite_well_known = true;
        oidc.access_token_verify_method = "none";
        role_assignment = {
          # driver = "oidc"; # HINT currently broken for Android & Desktop app
          driver = "default";
          oidc_role_mapper.role_claim = "groups";
        };
        csp_config_file_location = "/etc/opencloud/csp.yaml";
      };
      csp = {
        directives = {
          connect-src = [
            "https://opencloud.${domain}/"
            "https://auth.${domain}/"
            "https://auth.${domain}/.well-known/openid-configuration"
          ];
          frame-src = [
            "https://opencloud.${domain}/"
            "https://auth.${domain}/"
          ];
          script-src = [
            "'unsafe-eval'"
          ];
        };
      };
      web.web.config.oidc.client_id = "opencloud";
      web.web.config.oidc.scope = "openid profile email groups";
    };
    environment = {
      OC_INSECURE = "false";
      PROXY_TLS = "false";
      PROXY_INSECURE_BACKENDS = "true";
      OC_EXCLUDE_RUN_SERVICES = "idp";
      OC_OIDC_ISSUER = "https://auth.${domain}";
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "opencloud.${domain}";
        policy = "one_factor";
        subject = "group:opencloud";
      }
    ];

    identity_providers.oidc.clients = [
      {
        client_id = "opencloud";
        client_name = "Opencloud";
        public = true;
        redirect_uris = [
          "https://opencloud.${domain}/"
          "https://opencloud.${domain}/oidc-callback.html"
          "https://opencloud.${domain}/oidc-silent-redirect.html"
        ];
        scopes = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
        grant_types = [
          "authorization_code"
          "refresh_token"
        ];
        userinfo_signed_response_alg = "none";
      }
    ];
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @opencloud host opencloud.${domain}
    handle @opencloud {
      reverse_proxy 127.0.0.1:${toString ports.opencloud}
    }
  '';
}
