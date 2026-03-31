{
  lib,
  globals,
  ...
}:
{
  services.caddy.virtualHosts."leia.${globals.domain}".extraConfig = lib.mkAfter ''
    @debug host leia.${globals.domain}
    handle @debug {
      forward_auth https://auth.r4clette.com {
        uri /api/verify?rd=https://auth.r4clette.com
        header_up X-Original-URL {scheme}://{host}{uri}
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      respond "Hello from leia, authenticated!"
    }
  '';
}
