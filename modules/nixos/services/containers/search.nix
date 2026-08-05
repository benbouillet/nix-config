{
  config,
  globals,
  ...
}:
{
  sops.secrets."services/degoog/settings_password" = {
    mode = "0400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/degoog 0755 1000 1000 -"
  ];

  virtualisation.oci-containers.containers = {
    "degoog" = {
      image = "ghcr.io/degoog-org/degoog:0.23.0@sha256:675f858d1a0264d32f867352d6cf0ad387fd2573cca0cbf597cf672ff869ce9e";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.degoog}:4444"
      ];
      volumes = [
        "/var/lib/degoog:/app/data"
      ];
      extraOptions = [
        "--memory=1g"
        "--memory-swap=2g"
        "--pids-limit=256"
      ];
      environment = {
        DEGOOG_PUBLIC_INSTANCE = "true";
        DEGOOG_DISTRUST_PROXY = "0";
        PUID = "1000";
        PGID = "1000";
      };
      environmentFiles = [
        config.sops.secrets."services/degoog/settings_password".path
      ];
    };
  };
}
