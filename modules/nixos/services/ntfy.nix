{
  globals,
  lib,
  ...
}:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = "127.0.0.1:${toString globals.ports.ntfy}";
      base-url = "https://ntfy.${globals.domain}";
    };
  };

  services.caddy.virtualHosts."*.${globals.domain}".extraConfig = lib.mkBefore ''
    @ntfy host ntfy.${globals.domain}
    handle @ntfy
      reverse_proxy 127.0.0.1:${toString globals.ports.ntfy}
  '';
}
