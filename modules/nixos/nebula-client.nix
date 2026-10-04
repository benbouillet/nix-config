{
  config,
  globals,
  host,
  lib,
  ...
}:
let
  hostIp = globals.hosts.${host}.nebula;
  lighthouseIp = globals.hosts.tarkin.nebula;
in
{
  assertions = [
    {
      assertion = hostIp != null;
      message = "Nebula client host ${host} must have a Nebula address in globals.hosts.";
    }
  ];

  sops.secrets = {
    "nebula/host-key" = {
      mode = "0400";
      owner = "nebula-tarkin";
      group = "nebula-tarkin";
    };
    "nebula/host-cert" = {
      mode = "0440";
      owner = "nebula-tarkin";
      group = "nebula-tarkin";
    };
    "nebula/ca-cert" = {
      mode = "0440";
      owner = "nebula-tarkin";
      group = "nebula-tarkin";
    };
  };

  services.nebula.networks.tarkin = {
    enable = true;
    isLighthouse = false;
    lighthouses = [ lighthouseIp ];
    staticHostMap.${lighthouseIp} = [ "${globals.hosts.tarkin.publicIpv4}:4242" ];
    ca = config.sops.secrets."nebula/ca-cert".path;
    cert = config.sops.secrets."nebula/host-cert".path;
    key = config.sops.secrets."nebula/host-key".path;
    listen.port = 4242;
    settings = {
      punchy = {
        punch = true;
        respond = true;
      };
      lighthouse.local_allow_list = {
        "0.0.0.0/0" = true;
        "10.88.0.0/16" = false;
        "::/0" = false;
      };
    };
    tun.device = "nebula1";
    firewall = {
      inbound = [
        {
          cidr = globals.nebulaCidr;
          port = "any";
          proto = "any";
        }
      ];
      outbound = [
        {
          host = "any";
          port = "any";
          proto = "any";
        }
      ];
    };
  };

  networking.firewall.trustedInterfaces = lib.mkIf (host == "chewie") [ "nebula1" ];
}
