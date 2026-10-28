{
  globals,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "bentopdf" = {
      image = "ghcr.io/alam00000/bentopdf-simple:2.8.10@sha256:b5227a308e796d2bd00d2eb6da9d7296093107a8be7efef38a006d06506dc3c0";
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
