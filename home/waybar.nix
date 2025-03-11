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
        margin-top = 5;
        margin-left = 5;
        margin-right = 5;
        height = 30;
        modules-left = [
          "hyprland/workspaces"
          "cpu"
          "memory"
          "disk"
          "temperature"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "mpris"
          "bluetooth"
          "network"
          "battery"
          "custom/tailscale"
          "idle_inhibitor"
          "custom/wlogout"
        ];

        ##### LEFT #####
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
        "temperature" = {
          format = " {temperatureC}°C";
          hwmon-path = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon6/temp1_input";
          interval = 5;
        };

        ##### CENTER #####
        "hyprland/workspaces" = {
          on-click = "activate";
          all-outputs = true;
          disable-scroll = true;
          active-only = false;
          format = "{name}";
          format-icons = {
            default = " ";
            active = " ";
            urgent = " ";
          };
        };

        ##### RIGHT #####
        "mpris" = {
          format = "{player_icon}{status_icon}";
          format-stopped = "";
          tooltip-format = "{dynamic}";
          status-icons = {
            playing = "󰐊";
            paused = "󰏤";
            stopped = "󰓛";
          };
          player-icons = {
            spotify = " ";
            mpv = "󰐹 ";
            vlc = "󰕼 ";
            firefox = "󰈹 ";
            chromium = " ";
          };
          on-click = "playerctl play-pause";
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
          format-ethernet = " {bandwidthDownBytes}  {bandwidthUpBytes}";
          format-wifi = "{icon} ";
          format-disconnected = "󰤫 ";
          tooltip = "{ifname}\n{essid}\n{ipaddr}";
          on-click = "sleep 0.1 && ghostty nmtui";
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
          format = ''  {:L%H:%M}'';
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "󰒳 ";
            deactivated = "󰒲 ";
          };
          tooltip = "true";
          tooltip-format-activated = "Idle Inhibitor Activated";
          tooltip-format-deactivated = "Idle Inhibitor Deactivated";
        };
        "custom/tailscale" = {
          format = "{}";
          interval = 1;
          return-type = "json";
          exec = "waybar-tailscale-status";
          tooltip = true;
          on-click = "waybar-tailscale-updown";
        };
        "custom/wlogout" = {
          format = " ";
          on-click = "wlogout";
        };
      }
    ];
    style = concatStrings [
      ''
      @define-color rosewater #f4dbd6;
      @define-color flamingo #f0c6c6;
      @define-color pink #f5bde6;
      @define-color mauve #c6a0f6;
      @define-color red #ed8796;
      @define-color maroon #ee99a0;
      @define-color peach #f5a97f;
      @define-color yellow #eed49f;
      @define-color green #a6da95;
      @define-color teal #8bd5ca;
      @define-color sky #91d7e3;
      @define-color sapphire #7dc4e4;
      @define-color blue #8aadf4;
      @define-color lavender #b7bdf8;
      @define-color text #cad3f5;
      @define-color subtext1 #b8c0e0;
      @define-color subtext0 #a5adcb;
      @define-color overlay2 #939ab7;
      @define-color overlay1 #8087a2;
      @define-color overlay0 #6e738d;
      @define-color surface2 #5b6078;
      @define-color surface1 #494d64;
      @define-color surface0 #363a4f;
      @define-color base #24273a;
      @define-color mantle #1e2030;
      @define-color crust #181926;

      * {
        font-family: ${config.stylix.fonts.sansSerif.name};
        font-size: 16px;
      }

      button {
        /* Use box-shadow instead of border so the text isn't offset */
        box-shadow: inset 0 -3px transparent;
        /* Avoid rounded borders under each button name */
        border: none;
        border-radius: 0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover {
        background: inherit;
        box-shadow: inset 0 -3px #ffffff;
      }

      /* you can set a style on hover for any module like this */
      #bluetooth:hover,
      #network:hover,
      #idle_inhibitor:hover,
      #backlight:hover,
      #custom-wlogout:hover,
      #custom-tailscale:hover,
      #mpris:hover,
      #pulseaudio:hover {
        background-color: @surface2;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ffffff;
      }

      #workspaces button:hover {
        background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.focused {
        background-color: @lavender;
        box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.active {
        box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.urgent {
        background-color: #eb4d4b;
      }

      #mode {
        background-color: #64727D;
        box-shadow: inset 0 -3px #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #network,
      #bluetooth,
      #backlight,
      #idle_inhibitor,
      #custom-wlogout,
      #custom-tailscale,
      #mpris,
      #pulseaudio {
        padding: 0 10px;
      }

      #pulseaudio {
        color: @maroon;
      }

      #network {
        color: @yellow;
      }

      #temperature {
        color: @sky;
      }

      #battery {
        color: @green;
      }

      #clock {
        color: @flamingo;
      }

      .modules-right,
      .modules-left,
      .modules-center {
        background-color: @base;
        border-radius: 15px;
      }

      .modules-right {
        padding: 0 10px;
      }

      .modules-left {
        padding: 0 20px;
      }

      .modules-center {
        padding: 0 10px;
      }

      #battery.charging,
      #battery.plugged {
        color: @sapphire;
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

      label:focus {
        background-color: #000000;
      }
      ''
    ];
  };
}
