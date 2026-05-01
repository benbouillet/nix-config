{
  globals,
  ...
}:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = "127.0.0.1:${toString globals.ports.ntfy}";
      base-url = "https://ntfy.${globals.domain}";
    };
  };
}
