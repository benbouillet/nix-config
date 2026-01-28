{
  username,
  ...
}:
{
  services = {
    tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=${username}" ];
      extraUpFlags = [ "--operator=${username}" ];
    };
  };
}
