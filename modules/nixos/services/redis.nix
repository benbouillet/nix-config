{
  pkgs,
  globals,
  ...
}:
{
  services.redis = {
    package = pkgs.valkey;
    servers."raclette" = {
      enable = true;
      port = globals.ports.redis;
    };
  };
}
