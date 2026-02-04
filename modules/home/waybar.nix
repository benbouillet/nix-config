{
  pkgs,
  lib,
  config,
  ...
}:
{
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
          "tray"
          "custom/tailscale"
          "backlight"
          "pulseaudio#source"
          "pulseaudio"
          "battery"
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
        "backlight" = {
          device = "intel_backlight";
          format = "{icon}  {percent}%";
          format-icons = [
            "󰃞"
            "󰃟"
            "󰃠"
          ];
        };
        "tray" = {
          icon-size = 16;
          spacing = 20;
        };
        "custom/tailscale" = {
          return-type = "json";
          exec = ''
            if tailscale status --peers=false >/dev/null 2>&1; then
              ip=$(tailscale status --peers=false | awk 'NR==1 {print $1}')
              printf '{"text":" 󰱓","tooltip":"Tailscale connected: %s","class":"running"}\n' "$ip"
            else
              printf '{"text":" 󰅛","tooltip":"Tailscale - not connected","class":"stopped"}\n'
            fi
          '';
          interval = 5;
          on-click = "tailscale status --peers=false && tailscale down || tailscale up";
        };
        "pulseaudio" = {
          format = "{icon}   {volume}%";
          format-bluetooth = "󰥰  {volume}%";
          format-muted = "   {volume}%";
          format-icons = {
            "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
            "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
            headphone = "";
            phone = "";
            phone-muted = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
            ];
          };
          scroll-step = 1;
          on-click = "pavucontrol";
          ignored-sinks = [ "Easy Effects Sink" ];
        };
        "pulseaudio#source" = {
          format = "{format_source}";
          format-source = "  {volume}%";
          format-source-muted = "  {volume}%";
          on-click = "pavucontrol";
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
          format = "{:%a  %b  %d  %H:%M %p}";
          tooltip = false;
        };
      }
    ];
    style = lib.concatStrings [
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
        #custom-opencloud,
        #pulseaudio-source,
        #pulseaudio {
          padding: 0 12px;
        }

        @keyframes blink {
          to {
            color: #000000;
          }
        }

        #custom-tailscale.stopped,
        #custom-opencloud.stopped,
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
