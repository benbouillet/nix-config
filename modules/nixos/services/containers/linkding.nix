{
  lib,
  globals,
  ...
}:
{

  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.services.apps.mountPoint}/linkding 2770 1000 1000 - -"
  ];

  virtualisation.oci-containers.containers = {
    "linkding" = {
      image = "ghcr.io/sissbruecker/linkding:1.45.0";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.linkding}:9090"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/linkding:/etc/linkding/data"
      ];
      extraOptions = [
        "--memory=256m"
        "--pids-limit=8"
      ];
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "links.${globals.domain}";
        policy = "one_factor";
        subject = "group:linkding";
      }
    ];
  };

  
}
