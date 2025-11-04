{
  pkgs,
  username,
  ...
}:
{
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  services.pcscd.enable = true; # yubikey management
  services.udev.packages = with pkgs; [ libfido2 ];

  users.users.${username} = {
    extraGroups = [
      "podman"
    ];
  };
}
