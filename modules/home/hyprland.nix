{
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix)
    keyboardLayout
    keyboardVariant
    ;
in
with lib;
{
  home.packages = with pkgs; [
    hyprpolkitagent
    hyprshot
    playerctl
    pavucontrol
  ];

  services = {
    playerctld.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.file.".config/uwsm/env".text = ''
    # QT
    export QT_QPA_PLATFORM=wayland;xcb
    export QT_QPA_PLATFORMTHEME=qt6ct
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export QT_STYLE_OVERRIDE=kvantum

    # Toolkit Backend Variables
    export GDK_BACKEND=wayland,x11,*
    export SDL_VIDEODRIVER=wayland
    export CLUTTER_BACKEND=wayland

    # XDG Specifications
    export XDG_CURRENT_DESKTOP=Hyprland
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=Hyprland
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = false;
    configType = "lua";
    settings = {
      config = {
        input = {
          kb_layout = keyboardLayout;
          kb_variant = keyboardVariant;
          kb_options = "caps:escape, compose:ralt";
          follow_mouse = 2;
          mouse_refocus = false;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            scroll_factor = 0.8;
          };
          sensitivity = 0.4;
          accel_profile = "adaptative";
          repeat_rate = 20;
          repeat_delay = 400;
        };
        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          resize_on_border = true;
        };
        dwindle = {
          preserve_split = true;
          force_split = 2;
        };
        decoration = {
          rounding = 10;
          shadow = {
            enabled = true;
            range = 4;
          };
          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            new_optimizations = true;
            ignore_opacity = false;
          };
        };
        animations = {
          enabled = true;
        };
        debug = {
          disable_logs = true;
        };
        misc = {
          initial_workspace_tracking = 0;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
        };
      };
      device = {
        name = "expert-wireless-tb-mouse";
        sensitivity = -0.3;
      };
      curve = [
        {
          _args = [
            "wind"
            {
              type = "bezier";
              points = [
                [
                  0.05
                  0.9
                ]
                [
                  0.1
                  1.05
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "winIn"
            {
              type = "bezier";
              points = [
                [
                  0.1
                  1.1
                ]
                [
                  0.1
                  1.1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "winOut"
            {
              type = "bezier";
              points = [
                [
                  0.3
                  (-0.3)
                ]
                [
                  0
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "liner"
            {
              type = "bezier";
              points = [
                [
                  1
                  1
                ]
                [
                  1
                  1
                ]
              ];
            }
          ];
        }
      ];
      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 6;
          bezier = "wind";
          style = "slide";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 6;
          bezier = "winIn";
          style = "slide";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 5;
          bezier = "winOut";
          style = "slide";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 5;
          bezier = "wind";
          style = "slide";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 1;
          bezier = "liner";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 5;
          bezier = "wind";
        }
      ];
      window_rule = [
        {
          match.class = "gamescope";
          fullscreen = true;
        }
        {
          match.class = "gamescope";
          workspace = "10";
        }
        {
          match.class = "^(tofi)$";
          center = true;
        }
        {
          match.class = "^(tofi)$";
          center = true;
        }
        {
          match.class = "^(chromium-browser)$";
          workspace = "1";
        }
        {
          match.class = "^(chromium-browser)$";
          fullscreen = true;
        }
        {
          match.class = "^(Slack)$";
          workspace = "2";
        }
        {
          match.class = "^(Slack)$";
          fullscreen = true;
        }
        {
          match.class = "^(Altus)$";
          workspace = "3";
        }
        {
          match.class = "^(Altus)$";
          fullscreen = true;
        }
      ];
      gesture = [
        {
          fingers = 4;
          direction = "horizontal";
          action = "workspace";
        }
      ];
      workspace_rule = [
        {
          workspace = "1";
          monitor = "eDP-1";
          default = true;
        }
        {
          workspace = "2";
          monitor = "eDP-1";
        }
        {
          workspace = "3";
          monitor = "eDP-1";
        }
        {
          workspace = "4";
          monitor = "eDP-1";
        }
        {
          workspace = "5";
          monitor = "desc:LG Electronics LG HDR WQHD 312NTWG9Z889";
          default = true;
        }
        {
          workspace = "6";
          monitor = "desc:LG Electronics LG HDR WQHD 312NTWG9Z889";
        }
        {
          workspace = "7";
          monitor = "desc:LG Electronics LG HDR WQHD 312NTWG9Z889";
        }
        {
          workspace = "8";
          monitor = "desc:LG Electronics LG HDR WQHD 312NTWG9Z889";
        }
        {
          workspace = "9";
          monitor = "desc:Invalid Vendor Codename - RTK 0x1920 demoset-1";
          default = true;
        }
        {
          workspace = "10";
          monitor = "desc:Invalid Vendor Codename - RTK 0x1920 demoset-1";
        }
      ];
      on = {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("uwsm app -- dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
              hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS")
              hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service")
              hl.exec_cmd("uwsm app -- nm-applet --indicator")
              hl.exec_cmd("uwsm app -- blueman-applet")
            end
          '')
        ];
      };
    };
  };
}
