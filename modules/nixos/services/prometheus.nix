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

  rulesYml = pkgs.writeText "services-alerts.yml" ''
    groups:
      - name: services-basics
        rules:
          - alert: serviceDown
            expr: probe_success == 0
            for: 1m
            labels:
              severity: info
              type: web-services
              team: platform
            annotations:
              summary: "Service down: {{ $labels.instance }}"
              description: "Prometheus has not been able to reach this services for 5 minutes."

      - name: infra-basics
        rules:
          - alert: OomKills
            expr: |
              increase(node_vmstat_oom_kill[5m]) > 0
            labels:
              severity: warning
              team: platform
            annotations:
              summary: "OOM on: {{ $labels.instance }}"
              description: "OOM kill detected on {{ $labels.instance }}."
          - alert: HostMemoryPressure
            expr: |
              (
                node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.10
              )
              and
              (
                rate(node_vmstat_pswpout[5m]) > 0
              )
            for: 10m
            labels:
              severity: warning
              team: platform
            annotations:
              summary: "High memory pressure on {{ $labels.instance }}"
              description: "MemAvailable < 10% for 10 minutes with kernel actively pushing pages to swap."

      - name: prometheus-self
        rules:
          - alert: PrometheusScrapeFailures
            expr: |
              increase(prometheus_target_scrapes_exceeded_sample_limit_total[10m]) > 0
              or increase(prometheus_target_scrapes_sample_duplicate_timestamp_total[10m]) > 0
              or increase(prometheus_target_scrapes_sample_out_of_order_total[10m]) > 0
              or increase(prometheus_target_scrapes_sample_out_of_bounds_total[10m]) > 0
            for: 5m
            labels:
              severity: info
              team: platform
            annotations:
              summary: "Prometheus scrape quality issues"
              description: "Samples are being rejected (limit/duplicate/out-of-order/out-of-bounds)."
              runbook_url: "https://runbooks.example.com/prom-scrape-issues"

          - alert: PrometheusRuleEvaluationFailures
            expr: increase(prometheus_rule_evaluation_failures_total[10m]) > 0
            for: 5m
            labels:
              severity: info
              team: platform
            annotations:
              summary: "Prometheus rule evaluation failures"
              description: "Some rules failed to evaluate in the last 10 minutes."
              runbook_url: "https://runbooks.example.com/prom-rule-fail"
  '';
in
{
  services.prometheus = {
    enable = true;
    port = globals.ports.prometheus;
    globalConfig.scrape_interval = "10s";
    webExternalUrl = "https://prometheus.${globals.domain}";
    ruleFiles = [ rulesYml ];
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
    alertmanagers = [
      {
        static_configs = [
          { targets = [ "127.0.0.1:${toString config.services.prometheus.alertmanager.port}" ]; }
        ];
      }
    ];

    # Blackbox exporter - should be moved to another host
    exporters = {
      blackbox = {
        enable = true;
        port = globals.ports.prometheus_exporters.blackbox;
        listenAddress = "0.0.0.0";
        configFile = pkgs.writeText "blackbox.yml" (builtins.toJSON blackboxConfig);
      };
    };

    # Alert manager
    alertmanager = {
      enable = true;
      webExternalUrl = "https://alerts.${globals.domain}";
      port = globals.ports.prometheus-alertmanager;
      listenAddress = "127.0.0.1";
      extraFlags = [ "--cluster.listen-address=" ];

      configuration = {
        global = {
          resolve_timeout = "5m";
        };

        route = {
          receiver = "ntfy";
          group_by = [
            "alertname"
            "job"
          ];
          group_wait = "10s";
          group_interval = "30s";
          repeat_interval = "1h";
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

    alertmanager-ntfy = {
      enable = true;
      settings = {
        http.addr = "127.0.0.1:${toString globals.ports.prometheus-alertmanager-ntfy}";
        ntfy = {
          baseurl = "https://ntfy.${globals.domain}";
          notification = {
            topic = "chewie";
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
