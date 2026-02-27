{
  globals,
  config,
  lib,
  ...
}:
{
  services.grafana = {
    enable = true;
    settings = {
      http_addr = "127.0.0.1";
      http_port = globals.ports.grafana;
      enforce_domain = true;
      enable_gzip = true;
      domain = "grafana.${globals.domain}";
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
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @grafana host grafana.${globals.domain}
    handle @grafana {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString config.services.grafana.port}
    }
  '';
}
