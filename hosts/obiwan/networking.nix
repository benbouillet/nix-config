{
  config,
  ...
}:
{
  sops.secrets."wireless/home" = { };

  networking = {
    networkmanager = {
      ensureProfiles = {
        environmentFiles = [ config.sops.secrets."wireless/home".path ];
        profiles = {
          "home-ethernet" = {
            connection = {
              id = "home-ethernet";
              interface-name = "eth0";
              permissions = "user:ben:;";
              type = "ethernet";
              autoconnect = true;
              autoconnect-priority = 999;
            };
            ipv4 = {
              method = "auto";
              route-metric = "0";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
            proxy = { };
          };
          "home-wifi" = {
            connection = {
              id = "home-wifi";
              type = "wifi";
              interface-name = "wlp1s0";
              permissions = "user:ben:;";
              autoconnect = true;
              autoconnect-priority = 10;
            };
            ipv4 = {
              method = "auto";
              route-metric = "100";
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$HOME_UUID";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$HOME_PSK";
            };
          };
          "homelab-wifi" = {
            connection = {
              id = "homelab-wifi";
              type = "wifi";
              interface-name = "wlp1s0";
              permissions = "user:ben:;";
              autoconnect = true;
              autoconnect-priority = 20;
            };
            ipv4 = {
              method = "auto";
              route-metric = "50";
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$HOMELAB_UUID";
            };
            wifi-security = {
              key-mgmt = "sae";
              psk = "$HOME_PSK";
            };
          };
          "lacapelle-wifi" = {
            connection = {
              id = "lacapelle-wifi";
              type = "wifi";
              interface-name = "wlp1s0";
              permissions = "user:ben:;";
              autoconnect = true;
              autoconnect-priority = 10;
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
              ssid = "$CAPELLE_UUID";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$CAPELLE_PSK";
            };
          };
          "lebreuil-wifi" = {
            connection = {
              id = "lebreuil-wifi";
              type = "wifi";
              interface-name = "wlp1s0";
              permissions = "user:ben:;";
              autoconnect = true;
              autoconnect-priority = 10;
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
              ssid = "$BREUIL_UUID";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$BREUIL_PSK";
            };
          };
        };
      };
    };
  };
}
