{
  pkgs,
  globals,
  ...
}:
{
  networking.firewall.interfaces."podman0".allowedTCPPorts = [ globals.ports.redis ];

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
