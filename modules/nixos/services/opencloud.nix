{
  lib,
  config,
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
      };
      csp = {
        directives = {
          connect-src = [
            "https://opencloud.${domain}/"
            "https://auth.${domain}/"
          ];
          frame-src = [
            "https://opencloud.${domain}/"
            "https://auth.${domain}/"
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

  # services.opencloud = {
  #   enable = true;
  #   stateDir = dataPath;
  #   user = users.opencloud.name;
  #   url = "https://opencloud.${domain}";
  #   address = "127.0.0.1";
  #   port = ports.opencloud;
  #   environment = {
  #     OC_OIDC_ISSUER = "https://auth.${domain}";
  #     OC_EXCLUDE_RUN_SERVICES = "idp,auth-basic,auth-bearer";
  #   };
  #
  #   settings = {
  #     proxy = {
  #       http.tls = false;
  #       auto_provision_accounts = true;
  #       oidc = {
  #         issuer = "https://auth.${domain}";
  #         insecure = false;
  #         rewrite_well_known = true;
  #         access_token_verify_method = "none";
  #         skip_user_info = false;
  #       };
  #       insecure_backends = false;
  #       csp_config_file_location = "/etc/opencloud/csp.yaml";
  #       user_oidc_claim = "preferred_username";
  #       user_cs3_claim = "username";
  #       role_assignment = {
  #         driver = "default";
  #       };
  #       auto_provision_claims = {
  #         username = "preferred_username";
  #         email = "email";
  #         display_name = "name";
  #         groups = "groups";
  #       };
  #     };
  #     graph = {
  #       events.tls_insecure = false;
  #       spaces.insecure = false;
  #       api.graph_username_match = "none";
  #     };
  #     frontend = {
  #       app_handler.insecure = false;
  #       archiver.insecure = false;
  #     };
  #     auth_bearer.auth_providers.oidc.insecure = false;
  #     ocdav.insecure = false;
  #     thumbnails.thumbnail = {
  #       webdav_allow_insecure = false;
  #       cs3_allow_insecure = false;
  #     };
  #     search.events.tls_insecure = false;
  #     audit.events.tls_insecure = false;
  #     sharing.events.tls_insecure = false;
  #     storage_users.events.tls_insecure = false;
  #     notifications.notifications.events.tls_insecure = false;
  #     nats.nats.tls_skip_verify_client_cert = false;
  #     web = {
  #       web = {
  #         config = {
  #           oidc = {
  #             metadata_url = "https://auth.${domain}/.well-known/openid-configuration";
  #             authority = "https://auth.${domain}";
  #             client_id = "opencloud";
  #             scope = "openid profile email groups offline_access";
  #           };
  #         };
  #       };
  #     };
  #     csp = {
  #       directives = {
  #         script-src = [
  #           "'self'"
  #           "'unsafe-inline'"
  #           "'unsafe-eval'"
  #         ];
  #         connect-src = [
  #           "'self'"
  #           "blob:"
  #           "https://auth.${domain}/"
  #           "https://opencloud.${domain}/"
  #         ];
  #         frame-src = [
  #           "'self'"
  #           "https://auth.${domain}/"
  #           "https://opencloud.${domain}/"
  #         ];
  #       };
  #     };
  #   };
  #   environmentFile = config.sops.secrets."opencloud/env".path;
  # };

  services.authelia.instances."raclette".settings = {
    access_control = {
      default_policy = "deny";
      rules = [
        {
          domain = "opencloud.${domain}";
          policy = "one_factor";
          subject = "group:opencloud";
        }
      ];
    };

    identity_providers.oidc = {
      # cors = {
      #   endpoints = [
      #     "authorization"
      #     "token"
      #     "revocation"
      #     "introspection"
      #     "userinfo"
      #   ];
      #   # This automatically allows origins derived from your clients'
      #   # redirect_uris (so https://opencloud.${domain} gets allowed).
      #   allowed_origins_from_client_redirect_uris = true;
      # };

      clients = [
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
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @opencloud host opencloud.${domain}
    handle @opencloud {
      reverse_proxy 127.0.0.1:${toString ports.opencloud}
    }
  '';
}
