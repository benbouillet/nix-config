{
  globals,
  pkgs,
  lib,
  config,
  ...
}:
let
  blackboxConfig = {
    modules = {
      http_health_healthy = {
        prober = "http";
        timeout = "5s";
        http = {
          valid_status_codes = [ 200 ];
          method = "GET";
          fail_if_body_not_matches_regexp = [ "^Healthy$" ];
        };
      };
      http_health_version = {
        prober = "http";
        timeout = "5s";
        http = {
          valid_status_codes = [ 200 ];
          method = "GET";
          fail_if_body_not_matches_regexp = [ "(?m)^v\\d+\\.\\d+.\\d+(-[0-9A-Za-z-]+)?$" ];
        };
      };
      http_health_json = {
        prober = "http";
        timeout = "5s";
        http = {
          valid_status_codes = [ 200 ];
          method = "GET";
          fail_if_header_not_matches = [
            {
              header = "content-type";
              regexp = "application/json";
            }
          ];
          fail_if_body_not_matches_regexp = [ "\"status\": \"OK\"" ];
        };
      };
    };
  };
in
{
  services.prometheus = {
    enable = true;
    port = globals.ports.prometheus;
    globalConfig.scrape_interval = "10s";
    webExternalUrl = "https://prometheus.${globals.domain}";
    scrapeConfigs = [
      {
        job_name = "node";
        metrics_path = "/metrics";
        static_configs = [
          {
            targets = [
              "chewie:${toString globals.ports.prometheus_exporters.node}"
            ];
          }
        ];
      }
      {
        job_name = "blackbox-healthy";
        metrics_path = "/probe";
        params = {
          module = [ "http_health_healthy" ];
        };
        static_configs = [
          {
            targets = [
              "https://jellyfin.${globals.domain}/health"
            ];
            labels = {
              type = "web-services";
            };
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "chewie:${toString globals.ports.prometheus_exporters.blackbox}";
          }
        ];
      }
      {
        job_name = "blackbox-json";
        metrics_path = "/probe";
        params = {
          module = [ "http_health_json" ];
        };
        static_configs = [
          {
            targets = [
              "https://sonarr.${globals.domain}/ping"
            ];
            labels = {
              type = "web-services";
            };
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "chewie:${toString globals.ports.prometheus_exporters.blackbox}";
          }
        ];
      }
      {
        job_name = "blackbox-version";
        metrics_path = "/probe";
        params = {
          module = [ "http_health_version" ];
        };
        static_configs = [
          {
            targets = [
              "https://qbittorrent.${globals.domain}/api/v2/app/version"
            ];
            labels = {
              type = "web-services";
            };
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "chewie:${toString globals.ports.prometheus_exporters.blackbox}";
          }
        ];
      }
    ];
    exporters = {
      blackbox = {
        enable = true;
        port = globals.ports.prometheus_exporters.blackbox;
        listenAddress = "0.0.0.0";
        configFile = pkgs.writeText "blackbox.yml" (builtins.toJSON blackboxConfig);
      };
    };
    alertmanager = {
      enable = true;
      webExternalUrl = "https://alerts.${globals.domain}";
      port = globals.ports.prometheus-alertmanager;
      listenAddress = "0.0.0.0";
      extraFlags = [ "--cluster.listen-address=''" ];

      configuration = {
        global = {
          # How long to wait before marking an alert as resolved
          resolve_timeout = "5m";
        };

        # Top-level routing tree: "what receiver gets what"
        route = {
          receiver = "default"; # must match one of receivers[].name
          group_by = [ "alertname" "job" ];
          group_wait = "30s";
          group_interval = "5m";
          repeat_interval = "4h";
        };

        receivers = [
          {
            name = "default";
            # With no integrations, this just "blackholes" alerts
            # (useful as a starting point / for local testing)
          }
        ];
      };
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "prometheus.${globals.domain}";
          policy = "one_factor";
          subject = "group:monitoring";
        }
        {
          domain = "alerts.${globals.domain}";
          policy = "one_factor";
          subject = "group:monitoring";
        }
      ];
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @prometheus host prometheus.${globals.domain}
    handle @prometheus {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString config.services.prometheus.port}
    }

    @alertmanager host alerts.${globals.domain}
    handle @alertmanager {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString config.services.prometheus.alertmanager.port}
    }
  '';
}
