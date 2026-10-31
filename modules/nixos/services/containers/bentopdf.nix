{
  globals,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "bentopdf" = {
      image = "ghcr.io/alam00000/bentopdf-simple:2.8.11@sha256:3bbab98791694b77bc70ab03bf1b2ea89e568a75ef172c27d95cbdbdf810038f";
      ports = [
        "${globals.hosts.chewie.tailscale}:${toString globals.ports.bentopdf}:8080"
      ];
      extraOptions = [
        "--memory=512m"
        "--pids-limit=64"
      ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "pdf.${globals.domain}";
        policy = "one_factor";
      }
    ];
  };
}
