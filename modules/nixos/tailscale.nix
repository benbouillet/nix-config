{
  username,
  config,
  host,
  ...
}:
{
  sops.secrets."tailscale/${host}" = {};

  services = {
    tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=${username}" ];
      extraUpFlags = [ "--operator=${username}" ];
      authKeyFile = config.sops.secrets."tailscale/${host}".path ;
    };
  };
}
