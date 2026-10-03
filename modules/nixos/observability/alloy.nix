{
  globals,
  config,
  pkgs,
  ...
}:
{
  services.alloy = {
    enable = true;
    configPath = pkgs.writeText "config.alloy" ''
      loki.source.journal "read" {
        forward_to    = [loki.write.local.receiver]
        relabel_rules = loki.relabel.journal.rules
        labels = {
          job  = "systemd-journal",
          host = "${config.networking.hostName}",
        }
      }

      // Rules-only export: this component is never sent entries,
      // it just exposes `.rules` for loki.source.journal to apply once.
      loki.relabel "journal" {
        forward_to = []

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
        rule {
          source_labels = ["__journal__hostname"]
          target_label  = "hostname"
        }
        rule {
          source_labels = ["__journal_priority_keyword"]
          target_label  = "level"
        }
        rule {
          source_labels = ["__journal_syslog_identifier"]
          target_label  = "syslog_identifier"
        }
      }

      loki.write "local" {
        endpoint {
          url = "http://${globals.hosts.leia.ipv4}:${toString globals.ports.loki-http}/loki/api/v1/push"
        }
      }
    '';
  };
}
