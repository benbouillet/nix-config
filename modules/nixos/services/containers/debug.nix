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
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.debug}:80"
      ];
      extraOptions = [
        "--memory=64m"
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

  
}
