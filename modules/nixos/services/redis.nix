{
  pkgs,
  ...
}:
let
  ports = {
    redis = 6379;
  };
in
{
  services.redis = {
    package = pkgs.valkey;
    servers."raclette" = {
      enable = true;
      port = ports.redis;
    };
  };
}
