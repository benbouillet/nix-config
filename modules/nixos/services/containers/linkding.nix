{
  lib,
  globals,
  ...
}:
{

  systemd.tmpfiles.rules = lib.mkAfter [
    # linkding runs uwsgi as www-data = 33:33
    "d ${globals.zfs.services.apps.mountPoint}/linkding 2770 33 33 - -"
  ];

  virtualisation.oci-containers.containers = {
    "linkding" = {
      image = "ghcr.io/sissbruecker/linkding:1.45.0@sha256:61b2eb9eed8e5772a473fb7f1f8923e046cb8cbbeb50e88150afd5ff287d4060";
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
