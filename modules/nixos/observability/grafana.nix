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
    "grafana/admin_password" = {
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
        disable_login_form = false;
        disable_signout_menu = true;
      };
      security = {
        secret_key = "\$__file{${config.sops.secrets."grafana/secret_key".path}}";
        admin_password = "\$__file{${config.sops.secrets."grafana/admin_password".path}}";
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
      enable = true;
      datasources.settings = {
        deleteDatasources = [
          {
            name = "Prometheus";
            orgId = 1;
          }
          {
            name = "Loki";
            orgId = 1;
          }
        ];
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${toString globals.ports.prometheus}";
            editable = false;
            access = "proxy";
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://${globals.hosts.leia.ipv4}:${toString globals.ports.loki-http}";
            editable = false;
            access = "proxy";

            # optional niceties
            isDefault = false;
            jsonData = {
              maxLines = 2000;
              timeout = 60;
            };
          }
        ];
      };
      dashboards.settings.providers = [
        {
          name = "declarative-dashboards";
          disableDeletion = false;
          options = {
            path = "/etc/grafana-dashboards";
            foldersFromFilesStructure = true;
          };
        }
      ];
    };
  };

  environment.etc = {
    "grafana-dashboards/node.json".source = ./assets/grafana/node.json;
    "grafana-dashboards/zfs.json".source = ./assets/grafana/zfs.json;
  };
}
