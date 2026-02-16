{
  lib,
  config,
  globals,
  ...
}:
{
  sops.secrets."opencloud/env" = {
    mode = "0400";
    owner = globals.users.opencloud.name;
    group = globals.groups.opencloud.name;
  };

  users.users = {
    "${globals.users.opencloud.name}" = {
      isSystemUser = true;
      createHome = lib.mkForce false;
      uid = globals.users.opencloud.UID;
      group = globals.groups.opencloud.name;
    };
  };

  users.groups = {
    ${globals.groups.opencloud.name} = {
      gid = globals.groups.opencloud.GID;
    };
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.paths.opencloud} 2770 ${toString globals.users.opencloud.UID} ${toString globals.groups.opencloud.GID} - -"
  ];

  services.opencloud = {
    enable = true;
    url = "https://opencloud.${globals.domain}";
    address = "127.0.0.1";
    port = globals.ports.opencloud.proxy;
    settings = {
      api = {
        graph_assign_default_user_role = false;
        graph_username_match = "none";
      };
      proxy = {
        auto_provision_accounts = true;
        oidc.rewrite_well_known = true;
        oidc.access_token_verify_method = "none";

        role_assignment = {
          driver = "oidc";
          oidc_role_mapper = {
            role_claim = "groups";
            role_mapping = [
              {
                role_name = "admin";
                claim_value = "opencloud-admins";
              }
              {
                role_name = "user";
                claim_value = "opencloud-users";
              }
            ];
          };
        };
        csp_config_file_location = "/etc/opencloud/csp.yaml";
      };
      webdav = {
        http.addr = "127.0.0.1:${toString globals.ports.opencloud.webdav}";
      };
      csp = {
        directives = {
          connect-src = [
            "https://opencloud.${globals.domain}/"
            "https://auth.${globals.domain}/"
            "https://auth.${globals.domain}/.well-known/openid-configuration"
          ];
          frame-src = [
            "https://opencloud.${globals.domain}/"
            "https://auth.${globals.domain}/"
          ];
          script-src = [
            "'unsafe-eval'"
          ];
        };
      };
      web.web.config.oidc = {
        metadata_url = "https://auth.${globals.domain}/.well-known/openid-configuration";
        authority = "https://auth.${globals.domain}";
        client_id = "opencloud";
        scope = "openid profile email groups";
        response_type = "code";
      };
    };
    environment = {
      OC_INSECURE = "false";
      PROXY_TLS = "false";
      PROXY_INSECURE_BACKENDS = "true";
      OC_EXCLUDE_RUN_SERVICES = "idp";
      OC_OIDC_ISSUER = "https://auth.${globals.domain}";
    };
    environmentFile = config.sops.secrets."opencloud/env".path;
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "opencloud.${globals.domain}";
        policy = "one_factor";
        subject = [
          "group:opencloud-admins"
          "group:opencloud-users"
        ];
      }
    ];

    identity_providers.oidc.cors.allowed_origins = [
      "https://opencloud.${globals.domain}"
    ];

    identity_providers.oidc = {
      claims_policies.opencloud = {
        access_token = [ "groups" ];
        id_token = [ "groups" ];
      };
      clients = [
        {
          client_id = "opencloud";
          client_name = "Opencloud";
          public = true;
          authorization_policy = "one_factor";
          consent_mode = "implicit";
          redirect_uris = [
            "https://opencloud.${globals.domain}/"
            "https://opencloud.${globals.domain}/oidc-callback.html"
            "https://opencloud.${globals.domain}/oidc-silent-redirect.html"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          grant_types = [
            "authorization_code"
          ];
          claims_policy = "opencloud";
          userinfo_signed_response_alg = "none";
        }
        {
          client_id = "OpenCloudDesktop";
          client_name = "Opencloud Desktop";
          public = true;
          authorization_policy = "one_factor";
          consent_mode = "implicit";
          redirect_uris = [
            "http://localhost"
            "http://127.0.0.1"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
            "offline_access"
          ];
          grant_types = [
            "authorization_code"
            "refresh_token"
          ];
          claims_policy = "opencloud";
          userinfo_signed_response_alg = "none";
        }
        {
          client_id = "OpenCloudAndroid";
          client_name = "Opencloud Android";
          public = true;
          authorization_policy = "one_factor";
          consent_mode = "implicit";
          redirect_uris = [
            "oc://android.opencloud.eu"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
            "offline_access"
          ];
          grant_types = [
            "authorization_code"
            "refresh_token"
          ];
          claims_policy = "opencloud";
          userinfo_signed_response_alg = "none";
        }
      ];
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @opencloud host opencloud.${globals.domain}
    handle @opencloud {
      reverse_proxy 127.0.0.1:${toString globals.ports.opencloud.proxy}
    }
  '';
}
