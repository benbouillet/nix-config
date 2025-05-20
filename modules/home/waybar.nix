{
  pkgs,
  lib,
  host,
  config,
  ...
}:
with lib;
{
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        position = "top";
        margin-top = 0;
        margin-left = 0;
        margin-right = 0;
        height = 35;
        modules-left = [
          "hyprland/workspaces"
          "cpu"
          "memory"
          "disk"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "bluetooth"
          "network"
          "battery"
          "custom/tailscale"
          "custom/swaync"
        ];

        "cpu" = {
          interval = 5;
          format = "  {usage:2}%";
          tooltip = true;
        };
        "memory" = {
          interval = 5;
          format = "  {}%";
          tooltip = true;
          tooltip-format = "Memory used: {used:0.1f}GiB/{total:0.1f}GiB\nSwap used: {swapUsed:0.1f}GiB/{swapTotal:0.1f}GiB";
        };
        "disk" = {
          format = "  {free}";
          tooltip = true;
        };
        "hyprland/workspaces" = {
          disable-scroll = true;
        };

        "bluetooth" = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "sleep 0.1 && blueman-manager";
        };
        "network" = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤢"
            "󰤨"
          ];
          format-ethernet = " ";
          format-wifi = "{icon} ";
          format-disconnected = "󰤫 ";
          tooltip-format = "{ifname}\n{essid}\n{ipaddr}";
          on-click = "sleep 0.1 && nm-connection-editor";
        };
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          on-click = "";
          tooltip = true;
          tooltip-format = "{power} - {timeTo}";
        };
        "clock" = {
          format = ''{:%a  %b  %d  %H:%M %p}'';
          tooltip = false;
        };
        "custom/tailscale" = {
          format = "{}";
          interval = 1;
          return-type = "json";
          exec = "waybar-tailscale-status";
          tooltip = true;
          on-click = "waybar-tailscale-updown";
        };
        "custom/swaync" = {
          format = " ";
          on-click = "swaync-client -t";
        };
      }
    ];
    style = concatStrings [
      ''
      * {
        font-family: ${config.stylix.fonts.sansSerif.name};
        font-size: 18px;
      }

      window#waybar {
        background: #${config.lib.stylix.colors.base01};
      }

      button {
        /* Avoid rounded borders under each button name */
        border: none;
        border-radius: 0;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #bluetooth,
      #backlight,
      #custom-wlogout,
      #custom-tailscale,
      #custom-swaync,
      #pulseaudio {
        padding: 0 10px;
      }

      @keyframes blink {
        to {
          color: #000000;
        }
      }

      /* Using steps() instead of linear as a timing function to limit cpu usage */
      #battery.critical:not(.charging) {
        background-color: #f53c3c;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: steps(12);
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      ''
    ];
  };
}
