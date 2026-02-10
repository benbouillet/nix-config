{
  lib,
  globals,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "debug" = {
      image = "traefik/whoami:v1.11";
      ports = [
        "127.0.0.1:${toString globals.ports.debug}:80"
      ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "debug.${globals.domain}";
          policy = "one_factor";
          subject = "group:debug";
        }
      ];
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkAfter ''
    @debug host debug.${globals.domain}
    handle @debug {
      forward_auth http://127.0.0.1:${toString globals.ports.authelia} {
        uri /api/verify?rd=https://auth.${globals.domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }

      reverse_proxy 127.0.0.1:${toString globals.ports.debug}
    }
  '';
}
