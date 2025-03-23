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
          home-wifi = {
            connection.id = "home-wifi";
            connection.type = "wifi";
            wifi.ssid = "$HOME_UUID";
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$HOME_PSK";
            };
          };
        };
      };
    };
  };
}
