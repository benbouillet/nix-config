{
  globals,
  config,
  lib,
  ...
}:
{
  sops.secrets = {
    "grafana/secret_key" = {
      mode = "0400";
      owner = "grafana";
      group = "grafana";
    };
    "grafana/oidc_secret" = {
      mode = "0400";
      owner = "grafana";
      group = "grafana";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = globals.ports.grafana;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.${globals.domain}";
        root_url = "https://grafana.${globals.domain}/";
        serve_from_sub_path = false;
      };
      auth = {
        disable_login_form = true;
        disable_signout_menu = true;
      };
      security = {
        secret_key = "\$__file{${config.sops.secrets."grafana/secret_key".path}}";
      };

      "auth.generic_oauth" = {
        enabled = true;
        name = "Authelia";
        icon = "signin";

        client_id = "grafana";
        client_secret = "\$__file{${config.sops.secrets."grafana/oidc_secret".path}}";

        scopes = [
          "openid"
          "profile"
          "email"
          "groups"
        ];

        empty_scopes = false;
        auth_url = "https://auth.${globals.domain}/api/oidc/authorization";
        token_url = "https://auth.${globals.domain}/api/oidc/token";
        api_url = "https://auth.${globals.domain}/api/oidc/userinfo";
        login_attribute_path = "preferred_username";
        groups_attribute_path = "groups";
        name_attribute_path = "name";
        use_pkce = true;
        role_attribute_path = "contains(groups[*], 'monitoring') && 'GrafanaAdmin'";
        auth_style = "InHeader";
      };
    };
    provision = {
      datasources.settings = {
        deleteDatasources = [
          {
            name = "Prometheus";
            orgId = 1;
          }
        ];
        datasources = [
          {
            url = "http://localhost:${toString globals.ports.prometheus}";
            type = "prometheus";
            name = "Prometheus";
            editable = false;
            access = "proxy";
          }
        ];
      };
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "grafana.${globals.domain}";
          policy = "one_factor";
          subject = "group:monitoring";
        }
      ];
    };

    identity_providers.oidc.cors.allowed_origins = [
      "https://grafana.${globals.domain}"
    ];

    identity_providers.oidc.clients = [
      {
        client_id = "grafana";
        client_name = "Grafana";
        client_secret = "$pbkdf2-sha512$310000$cGFjKBm6mN9N0HMB2MzVwA$WDcbkc8LQI6lt8pZAMt9EYvnlH7uA0LpydmW0.YqlZR3LW9j8XcWuuXzCTv84pxDTNzqGFf5CvSn2muabC.1iA";
        public = false;
        authorization_policy = "one_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [ "https://grafana.${globals.domain}/login/generic_oauth" ];
        scopes = [
          "openid"
          "profile"
          "groups"
          "email"
        ];
        response_types = [
          "code"
        ];
        grant_types = [
          "authorization_code"
        ];
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_basic";
      }
    ];
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @grafana host grafana.${globals.domain}
    handle @grafana {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString config.services.grafana.settings.server.http_port}
    }
  '';
}
