{
  config,
  host,
  modulesPath,
  ...
}:
{
  imports = [
    ../../modules/nixos/nebula-lighthouse.nix
    "${modulesPath}/virtualisation/amazon-image.nix"
  ];

  networking.hostName = host;
  nixpkgs.hostPlatform = "aarch64-linux";
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };
  system.stateVersion = "26.05";

  sops.defaultSopsFile = ../../secrets/tarkin.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/run/tarkin/age-key.txt";
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
    isLighthouse = true;
    ca = config.sops.secrets."nebula/ca-cert".path;
    cert = config.sops.secrets."nebula/host-cert".path;
    key = config.sops.secrets."nebula/host-key".path;
    listen = {
      host = "0.0.0.0";
      port = 4242;
    };
    settings = {
      lighthouse = {
        interval = 60;
        hosts = [ ];
      };
      punchy = {
        punch = true;
        respond = true;
      };
      local_range = "10.202.0.0/16";
    };
  };
}
