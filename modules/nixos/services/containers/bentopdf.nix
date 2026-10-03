{
  globals,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "bentopdf" = {
      image = "ghcr.io/alam00000/bentopdf-simple:v2.8.8@sha256:3d62b8f8eece5fe947026ac3925ff08fda245b3d6ba2c3916b94da91e0010c74";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.bentopdf}:8080"
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
