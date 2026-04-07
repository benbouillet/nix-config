{
  globals,
  lib,
  ...
}:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = "${globals.hosts.chewie.ipv4}:${toString globals.ports.ntfy}";
      base-url = "https://ntfy.${globals.domain}";
    };
  };

  
}
