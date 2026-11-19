{
  globals,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    "bentopdf" = {
      image = "ghcr.io/alam00000/bentopdf-simple:2.8.11@sha256:4a501ea221007bc938f231d12b63261a2a9cdd8d6747b236fd709ef30e5fe7bc";
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
