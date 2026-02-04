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
      bind = "0.0.0.0";
      settings = {
        "protected-mode" = "no";
      };
    };
  };
}
