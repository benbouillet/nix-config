{
  config,
  lib,
  ...
}:
{
  sops.secrets."wireless/home" = {};

  networking = {
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = lib.mkDefault true;

    networkmanager = {
      enable = true;

      wifi.powersave = true;

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
              autoconnect-priority = 100;
            };
            ipv4 = {
              method = "auto";
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
              autoconnect-priority = 50;
            };
            ipv4 = {
              method = "auto";
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
          "lacapelle-wifi" = {
            connection = {
              id = "lacapelle-wifi";
              type = "wifi";
              interface-name = "wlp1s0";
              permissions = "user:ben:;";
              autoconnect = true;
              autoconnect-priority = 30;
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
              autoconnect-priority = 30;
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
