{
  lib,
  ...
}:
let
  domain = "r4clette.com";
  ports = {
    debug = 9999;
    authelia = 9091;
  };
in
{
  services.authelia.instances."raclette".settings = {
    access_control = {
      rules = [
        {
          domain = "debug.${domain}";
          policy = "one_factor";
          subject = "group:debug";
        }
      ];
    };
  };

  virtualisation.oci-containers.containers = {
    "debug" = {
      image = "traefik/whoami:v1.11";
      ports = [
        "127.0.0.1:${toString ports.debug}:80"
      ];
    };
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @debug host debug.${domain}
    handle @debug {
      forward_auth http://127.0.0.1:${toString ports.authelia} {
        uri /api/verify?rd=https://auth.${domain}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }

      reverse_proxy 127.0.0.1:${toString ports.debug}
    }
  '';
}
