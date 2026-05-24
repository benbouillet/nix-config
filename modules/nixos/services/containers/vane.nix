{
  lib,
  globals,
  ...
}:
{
  systemd.tmpfiles.rules = lib.mkAfter [
    "d ${globals.zfs.services.apps.mountPoint}/vane 0755 0 0 - -"
  ];

  virtualisation.oci-containers.containers = {
    "vane" = {
      image = "docker.io/itzcrazykns1337/vane:slim-v1.12.2@sha256:0111e0ea460b2edb2bdc777699cdfe20e8bba62caf96f074f1193367b115bc71";
      ports = [
        "${globals.hosts.chewie.ipv4}:${toString globals.ports.vane}:3000"
      ];
      volumes = [
        "${globals.zfs.services.apps.mountPoint}/vane:/home/vane/data"
      ];
      extraOptions = [
        "--memory=1g"
        "--memory-swap=2g"
        "--pids-limit=256"
      ];
      environment = {
        SEARXNG_API_URL = "http://searxng:8080";
        OPENAI_BASE_URL = "http://host.containers.internal:${toString globals.ports.llama-swap}/v1";
        OPENAI_API_KEY = "dummy";
      };
    };
  };

  services.authelia.instances."raclette".settings = {
    access_control.rules = [
      {
        domain = "vane.${globals.domain}";
        policy = "one_factor";
        subject = "group:vane";
      }
    ];
  };
}
