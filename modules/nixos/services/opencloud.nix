{
  lib,
  config,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    opencloud = 9050;
    opencloudDebug = 9143;
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
    stateDir = dataPath;
    settings = {
      api = {
        graph_assign_default_user_role = false;
        graph_username_match = "none";
      };
      gateway.debug = {
        addr = "127.0.0.1:${toString ports.opencloudDebug}";
        token = "";
      };
      proxy = {
        auto_provision_accounts = true;
        oidc.rewrite_well_known = true;
        oidc.access_token_verify_method = "none";

        role_assignment = {
          driver = "default";
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
      web.web.config.oidc = {
        metadata_url = "https://opencloud.${domain}/.well-known/openid-configuration";
        authority = "https://auth.${domain}";

        client_id = "web";
        scope = "openid profile email groups";
        response_type = "code";
      };
    };
    environment = {
      OC_INSECURE = "false";
      PROXY_TLS = "false";
      PROXY_INSECURE_BACKENDS = "true";
      OC_EXCLUDE_RUN_SERVICES = "idp";
      OC_OIDC_ISSUER = "https://auth.${domain}";
    };
    environmentFile = config.sops.secrets."opencloud/env".path;
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "opencloud.${domain}";
        policy = "one_factor";
        subject = "group:opencloud";
      }
    ];

    identity_providers.oidc.cors.allowed_origins = [
      "https://opencloud.${domain}"
    ];

    identity_providers.oidc = {
      claims_policies.opencloud = {
        access_token = [ "groups" ];
        id_token = [ "groups" ];
      };
      clients = [
        {
          client_id = "web";
          client_name = "Opencloud";
          public = true;
          authorization_policy = "one_factor";
          consent_mode = "implicit";
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
          response_types = [ "code" ];
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
          response_types = [ "code" ];
          claims_policy = "opencloud";
          userinfo_signed_response_alg = "none";
        }
      ];
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @opencloud_health {
      host opencloud.${domain}
      path /healthz
    }

    handle @opencloud_health {
      reverse_proxy 127.0.0.1:${toString ports.opencloudDebug}
    }

    @opencloud host opencloud.${domain}

    handle @opencloud {
      reverse_proxy 127.0.0.1:${toString ports.opencloud}
    }
  '';
}
