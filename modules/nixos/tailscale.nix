{
  username,
  host,
  ...
}:
{
  sops.secrets."tailscale/${host}" = { };

  services = {
    tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=${username}" ];
      extraUpFlags = [ "--operator=${username}" ];
    };
  };
}
