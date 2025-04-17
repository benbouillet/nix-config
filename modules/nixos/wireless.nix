{
  config,
  ...
}:
{
  sops.secrets."wireless/home" = {

  };

  networking = {
    networkmanager = {
      ensureProfiles = {
        environmentFiles = [ config.sops.secrets."wireless/home".path ];
        profiles = {
          "home-wifi" = {
            connection = {
              id = "home-wifi";
              permissions = "user:ben:;";
              type = "wifi";
              uuid = "$HOME_UUID";
            };
            ipv4 = {
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "default";
              method = "auto";
            };
            proxy = { };
            wifi = {
              mode = "infrastructure";
              ssid = "$HOME_UUID";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$HOME_PSK";
            };
          };
        };
      };
    };
  };
}
