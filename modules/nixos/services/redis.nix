{
  pkgs,
  config,
  globals,
  ...
}:
{
  networking.firewall.interfaces."podman0".allowedTCPPorts = [ globals.ports.redis ];

  systemd.services.podman-bridge-ready = {
    description = "Ensure podman bridge network exists";
    after = [ "podman.service" ];
    requires = [ "podman.service" ];
    before = [ "redis-raclette.service" ];
    wantedBy = [ "redis-raclette.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.virtualisation.podman.package}/bin/podman network create --ignore podman";
    };
  };

  systemd.services.redis-raclette = {
    after = [ "podman-bridge-ready.service" ];
    requires = [ "podman-bridge-ready.service" ];
  };

  services.redis = {
    package = pkgs.valkey;
    servers."raclette" = {
      enable = true;
      port = globals.ports.redis;
      bind = "127.0.0.1 ${globals.podmanBridgeGateway}";
      settings = {
        "protected-mode" = "no";
      };
    };
  };
}
