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
          "hyprland/window"
          "cpu"
          "memory"
          "disk"
        ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [
          "custom/logout"
          "custom/lock"
          "idle_inhibitor"
          "backlight"
          "pulseaudio"
          "bluetooth"
          "network"
          "battery"
          "clock"
        ];

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
        "clock" = {
          format = if clock24h == true then ''  {:L%H:%M}'' else ''  {:L%I:%M %p}'';
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
        "hyprland/window" = {
          max-length = 22;
          separate-outputs = false;
          rewrite = {
            "" = "  No Window ";
          };
        };
        "memory" = {
          interval = 5;
          format = "  {}%";
          tooltip = true;
          tooltip-format = "Memory used: {used:0.1f}GiB/{total:0.1f}GiB\nSwap used: {swapUsed:0.1f}GiB/{swapTotal:0.1f}GiB";
        };
        "custom/lock" = {
          "format" = "";
          "on-click" = "hyprlock";
        };
        "custom/logout" = {
          "format" = "󰍃";
          "on-click" = "hyprctl dispatch exit";
        };
        "cpu" = {
          interval = 5;
          format = "  {usage:2}%";
          tooltip = true;
        };
        "disk" = {
          format = "  {free}";
          tooltip = true;
        };
        "bluetooth" = {
          format = "󰂯 {status}";
          format-disabled = "";
          format-connected = "󰂯 {num_connections} connected";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
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
          format-disconnected = "󰤫";
          tooltip = false;
        };
        "pulseaudio" = {
          format = "{icon}   {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = "󰗿 {icon} {format_source}";
          format-muted = " {format_source}";
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
    #     "custom/exit" = {
    #       tooltip = false;
    #       format = "";
    #       on-click = "sleep 0.1 && wlogout";
    #     };
    #     "custom/hyprbindings" = {
    #       tooltip = false;
    #       format = "󱕴";
    #       on-click = "sleep 0.1 && list-hypr-bindings";
    #     };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "󰒳";
            deactivated = "󰒲";
          };
          tooltip = "true";
        };
    #     "custom/notification" = {
    #       tooltip = false;
    #       format = "{icon} {}";
    #       format-icons = {
    #         notification = "<span foreground='red'><sup></sup></span>";
    #         none = "";
    #         dnd-notification = "<span foreground='red'><sup></sup></span>";
    #         dnd-none = "";
    #         inhibited-notification = "<span foreground='red'><sup></sup></span>";
    #         inhibited-none = "";
    #         dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
    #         dnd-inhibited-none = "";
    #       };
    #       return-type = "json";
    #       exec-if = "which swaync-client";
    #       exec = "swaync-client -swb";
    #       on-click = "sleep 0.1 && task-waybar";
    #       escape = true;
    #     };
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
        border-radius: 11px;
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

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover {
        background: inherit;
        box-shadow: inset 0 -3px #ffffff;
      }

      /* you can set a style on hover for any module like this */
      #battery:hover,
      #bluetooth:hover,
      #network:hover,
      #idle_inhibitor:hover,
      #backlight:hover,
      #custom-lock:hover,
      #custom-logout:hover,
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
      #custom-lock,
      #custom-logout,
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
