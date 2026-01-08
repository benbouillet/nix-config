{
  lib,
  ...
}:
let
  domain = "r4clette.com";
in
{
  virtualisation.oci-containers.containers."debug" = {
    image = "alexwhen/docker-2048:latest";
    ports = [
      "127.0.0.1:8999:80"
    ];
  };

  services.caddy.virtualHosts."*.${domain}".extraConfig = lib.mkAfter ''
    @debug host debug.${domain}
    handle @debug {
      reverse_proxy 127.0.0.1:8999
    }
  '';
}
