{
  globals,
  config,
  pkgs,
  ...
}:
{
  systemd.tmpfiles.rules = [
    "d /var/lib/alloy 0750 alloy alloy - -"
  ];

  services.alloy = {
    enable = true;
    configPath = pkgs.writeText "config.alloy" ''
      loki.source.journal "read" {
        forward_to = [loki.relabel.journal.receiver]
        relabel_rules = loki.relabel.journal.rules
        labels = {
          job  = "systemd-journal",
          host = "${config.networking.hostName}",
        }
      }

      loki.relabel "journal" {
        forward_to = [loki.write.local.receiver]

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
        rule {
          source_labels = ["__journal__hostname"]
          target_label  = "hostname"
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
