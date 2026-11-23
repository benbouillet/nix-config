{
  globals,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "bentopdf" = {
      image = "ghcr.io/alam00000/bentopdf-simple:2.8.12@sha256:f96da8c4a347880b891d66aa2ebfa6b63f76277dafcfcdfa40c8e6b92c59ef44";
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
