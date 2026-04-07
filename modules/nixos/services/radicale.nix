{
  lib,
  config,
  globals,
  ...
}:
{

  sops.secrets."radicale/htpasswd" = {
    owner = "radicale";
    group = "radicale";
    mode = "0400";
  };

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.data.radicale.mountPoint} 0750 radicale radicale - -"
    "d ${globals.zfs.data.radicale.mountPoint}/collections 0750 radicale radicale - -"
  ];

  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "${globals.hosts.chewie.ipv4}:${toString globals.ports.radicale}" ];
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.sops.secrets."radicale/htpasswd".path;
        htpasswd_encryption = "plain";
      };
      storage = {
        filesystem_folder = "${globals.zfs.data.radicale.mountPoint}/collections";
      };
      logging = {
        level = "warning";
      };
    };
  };

  
}
