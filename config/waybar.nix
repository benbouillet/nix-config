{
  pkgs,
  lib,
  host,
  config,
  ...
}:

let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  inherit (import ../hosts/${host}/variables.nix) clock24h;
in
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
          "custom/ping"
        ];
        modules-center = [
          "clock"
          "custom/notification"
        ];
        modules-right = [
          "mpris"
          # "backlight"
          "pulseaudio"
          "bluetooth"
          "network"
          "battery"
          "custom/tailscale"
          "idle_inhibitor"
          # "custom/wlogout"
        ];

        ##### LEFT #####
        "hyprland/workspaces" = {
          all-outputs = true;
          disable-scroll = true;
          active-only = false;
          format = "{name}";
          on-click = "activate";
          show-special = false;
          sort-by-number = true;
        };
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
        "custom/ping" = {
          format = "{}";
          interval = 5;
          return-type = "json";
          exec = "waybar-ping";
          tooltip = true;
          on-click = "waybar-ping";
        };

        ##### CENTER #####
        clock = {
          format = "{:%b %d  %H:%M}";
          format-alt = " {:%H:%M   %Y, %d %B, %A}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };
        # "custom/notification" = {
        #   tooltip = false;
        #   format = "{icon}";
        #   format-icons = {
        #     notification = "<span foreground='red'><sup></sup></span>";
        #     none = "";
        #     dnd-notification = "<span foreground='red'><sup></sup></span>";
        #     dnd-none = "";
        #     inhibited-notification = "<span foreground='red'><sup></sup></span>";
        #     inhibited-none = "";
        #     dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        #     dnd-inhibited-none = "";
        #   };
        #   return-type = "json";
        #   exec-if = "which swaync-client";
        #   exec = "swaync-client -swb";
        #   on-click = "swaync-client -t -sw";
        #   on-click-right = "swaync-client -d -sw";
        #   escape = true;
        # };

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
        "backlight" = {
            "format" = "{icon} {percent}%";
            "format-icons" = [
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                "󰽢"
            ];
        };
        "pulseaudio" = {
          format = "{icon}   {volume}% {format_source}";
          format-bluetooth = " {volume}% {format_source}";
          format-bluetooth-muted = "󰗿  {format_source}";
          format-muted = "  {format_source}";
          format-source = " {volume}%";
          format-source-muted = " ";
          format-icons = {
            headphone = "";
            hands-free = "󰥰";
            headset = "";
            phone = "󰏳";
            portable = "󰏳";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "sleep 0.1 && pavucontrol";
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
          format-wifi = "{icon}  {signalStrength}%";
          format-disconnected = "󰤫 ";
          tooltip = "{ifname}\n{essid}\n{ipaddr}";
          on-click = "sleep 0.1 && kitty nmtui";
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

      window#waybar {
        background-color: rgba(0, 0, 0, 0);
        border-radius: 8px;
        transition-property: background-color;
        transition-duration: .5s;
      }

      button {
        /* Use box-shadow instead of border so the text isn't offset */
        box-shadow: inset 0 -3px transparent;
        /* Avoid rounded borders under each button name */
        border: none;
        border-radius: 0;
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
        padding: 2px;
        color: #6e6a86;
        margin-right: 5px;
      }

      #workspaces button.active {
        color: #dfdfdf;
        border-radius: 3px 3px 3px 3px;
      }

      #workspaces button.focused {
        color: #d8dee9;
      }

      #workspaces button.urgent {
        color: #ed8796;
        border-radius: 8px;
      }

      #workspaces button:hover {
        color: #dfdfdf;
        border-radius: 3px;
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

      #window {
        color: @rosewater;
      }

      .modules-right,
      .modules-left,
      .modules-center {
        background-color: @base;
        border-radius: 8px;
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
