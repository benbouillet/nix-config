{
  globals,
  ...
}:
{
  systemd.tmpfiles.rules = [
    "d ${globals.zfs.data.loki.mountPoint} 0750 loki loki - -"
  ];

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;

      server = {
        http_listen_address = "0.0.0.0";
        http_listen_port = globals.ports.loki-http;

        grpc_listen_address = "127.0.0.1";
        grpc_listen_port = globals.ports.loki-grpc;
      };

      common = {
        path_prefix = globals.zfs.data.loki.mountPoint;
        instance_addr = "127.0.0.1";
        instance_interface_names = [ "lo" ];
        storage = {
          filesystem = {
            chunks_directory = "${globals.zfs.data.loki.mountPoint}/chunks";
            rules_directory = "${globals.zfs.data.loki.mountPoint}/rules";
          };
        };
        replication_factor = 1;
        ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };

      schema_config = {
        configs = [
          {
            from = "2024-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      compactor = {
        working_directory = "${globals.zfs.data.loki.mountPoint}/compactor";
        compaction_interval = "10m";
        retention_enabled = true;
        delete_request_store = "filesystem";
      };

      limits_config = {
        retention_period = "14d";
      };

      ruler = {
        storage = {
          type = "local";
          local = {
            directory = "${globals.zfs.data.loki.mountPoint}/rules";
          };
        };
        rule_path = "${globals.zfs.data.loki.mountPoint}/rules-temp";
        alertmanager_url = "http://127.0.0.1:${toString globals.ports.prometheus-alertmanager}";
      };
    };
  };
}
