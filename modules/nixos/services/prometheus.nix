{
  globals,
  lib,
  config,
  ...
}:
{
  services.prometheus = {
    enable = true;
    port = globals.ports.prometheus;
    globalConfig.scrape_interval = "10s";
    webExternalUrl = "https://prometheus.${globals.domain}";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "chewie:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
    ];
  };

  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "prometheus.${globals.domain}";
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
  '';
}
