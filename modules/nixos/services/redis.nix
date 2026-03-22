{
  pkgs,
  globals,
  ...
}:
{
  networking.firewall.interfaces."podman0".allowedTCPPorts = [ globals.ports.redis ];

  systemd.services.redis-raclette = {
    after = [ "podman.service" ];
    requires = [ "podman.service" ];
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
