{
  globals,
  config,
  ...
}:
{
  services.prometheus = {
    # Prometheus server
    enable = true;
    port = globals.ports.prometheus;
    globalConfig.scrape_interval = "10s";
    webExternalUrl = "https://prometheus.${globals.domain}";
    ruleFiles = [ ./configuration/alerts.yml ];

    # Scrape targets
    scrapeConfigs = [
      # Host metrics via node_exporter
      {
        job_name = "node";
        metrics_path = "/metrics";
        static_configs = [
          {
            targets = [ "${globals.hosts.chewie.ipv4}:${toString globals.ports.prometheus_exporters.node}" ];
            labels.hostname = "chewie";
          }
          {
            targets = [ "${globals.hosts.leia.ipv4}:${toString globals.ports.prometheus_exporters.node}" ];
            labels.hostname = "leia";
          }
          {
            targets = [ "${globals.hosts.yoda.ipv4}:${toString globals.ports.prometheus_exporters.node}" ];
            labels.hostname = "yoda";
          }
        ];
      }
      # Web service liveness probe (expects HTTP 200)
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
            replacement = "${globals.hosts.leia.ipv4}:${toString globals.ports.prometheus_exporters.blackbox}";
          }
        ];
      }
      # Web service probe validating a JSON health payload
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
            replacement = "${globals.hosts.leia.ipv4}:${toString globals.ports.prometheus_exporters.blackbox}";
          }
        ];
      }
      # Web service probe hitting an API version endpoint
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
            replacement = "${globals.hosts.leia.ipv4}:${toString globals.ports.prometheus_exporters.blackbox}";
          }
        ];
      }
      # ZFS pool and dataset metrics
      {
        job_name = "zfs";
        metrics_path = "/metrics";
        static_configs = [
          {
            targets = [ "${globals.hosts.chewie.ipv4}:${toString globals.ports.prometheus_exporters.zfs}" ];
            labels.hostname = "chewie";
          }
          {
            targets = [ "${globals.hosts.leia.ipv4}:${toString globals.ports.prometheus_exporters.zfs}" ];
            labels.hostname = "leia";
          }
          {
            targets = [ "${globals.hosts.yoda.ipv4}:${toString globals.ports.prometheus_exporters.zfs}" ];
            labels.hostname = "yoda";
          }
        ];
      }
    ];
    # Alertmanager discovery — Prometheus forwards firing alerts here
    alertmanagers = [
      {
        static_configs = [
          { targets = [ "127.0.0.1:${toString config.services.prometheus.alertmanager.port}" ]; }
        ];
      }
    ];

    # Blackbox exporter — synthetic HTTP probes (should be moved to another host)
    exporters = {
      blackbox = {
        enable = true;
        port = globals.ports.prometheus_exporters.blackbox;
        listenAddress = "${globals.hosts.leia.ipv4}";
        configFile = ./configuration/blackbox.yml;
      };
    };

    # Alertmanager — routes and groups alerts, fans them out to receivers
    alertmanager = {
      enable = true;
      webExternalUrl = "https://alerts.${globals.domain}";
      port = globals.ports.prometheus-alertmanager;
      listenAddress = "${globals.hosts.leia.ipv4}";
      extraFlags = [ "--cluster.listen-address=" ];

      configuration = {
        global = {
          resolve_timeout = "5m";
        };

        time_intervals = [
          {
            name = "night";
            time_intervals = [
              {
                times = [
                  {
                    start_time = "23:00";
                    end_time = "24:00";
                  }
                ];
                location = "Europe/Paris";
              }
              {
                times = [
                  {
                    start_time = "00:00";
                    end_time = "08:00";
                  }
                ];
                location = "Europe/Paris";
              }
            ];
          }
        ];

        route = {
          receiver = "ntfy";
          group_by = [
            "alertname"
            "job"
          ];
          group_wait = "10s";
          group_interval = "30s";
          repeat_interval = "1h";

          # Mute non-critical alerts overnight; critical alerts fall through
          # to the root route and notify immediately.
          routes = [
            {
              receiver = "ntfy";
              matchers = [ "severity!=critical" ];
              mute_time_intervals = [ "night" ];
            }
          ];
        };

        receivers = [
          {
            name = "ntfy";
            webhook_configs = [
              {
                url = "http://${toString config.services.prometheus.alertmanager-ntfy.settings.http.addr}/hook";
                send_resolved = true;
              }
            ];
          }
        ];
      };
    };

    # Alertmanager → ntfy bridge — turns webhook alerts into push notifications
    alertmanager-ntfy = {
      enable = true;
      settings = {
        http.addr = "127.0.0.1:${toString globals.ports.prometheus-alertmanager-ntfy}";
        ntfy = {
          baseurl = "https://ntfy.${globals.domain}";
          notification = {
            topic = "homelab";
            priority = ''
              status == "resolved"
                ? "default"
                : labels["severity"] == "critical"
                  ? "urgent"
                  : labels["severity"] == "warning"
                    ? "high"
                    : labels["severity"] == "info"
                      ? "default"
                      : "default"
            '';
            tags = [
              {
                tag = "+1";
                condition = "status == \"resolved\"";
              }
              {
                tag = "rotating_light";
                condition = "status == \"firing\"";
              }
              {
                tag = "{{ index .Labels \"severity\" }}";
              }
            ];
            templates = {
              title = ''
                {{ if eq .Status "resolved" }}Resolved: {{ end }}{{ index .Annotations "summary" }}
              '';
              description = ''
                {{ index .Annotations "description" }}
              '';
              headers = {
                "X-Click" = "{{ .GeneratorURL }}";
              };
            };
          };
          async = false;
        };
      };
    };
  };

}
