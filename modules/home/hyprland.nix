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
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
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
    systemd.enable = true;
    settings = {
      exec-once = [
        "uwsm app -- dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user enable --now hyprpolkitagent.service"
        "uwsm app -- waybar"
        "uwsm app -- nm-applet --indicator"
        "uwsm app -- blueman-applet"
      ];
      input = {
        kb_layout = keyboardLayout;
        kb_variant = keyboardVariant;
        kb_options = "caps:escape";
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
      device = {
        name = "expert-wireless-tb-mouse";
        sensitivity = -0.3;
      };
      debug.disable_logs = true;
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        resize_on_border = true;
      };
      dwindle = {
        pseudotile = true;
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
          new_optimizations = "on";
          ignore_opacity = "off";
        };
      };
      animations = {
        enabled = "yes";
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };
      windowrulev2 = [
        "noborder, class:^(tofi)$"
        "center, class:^(tofi)$"
        "fullscreen,class:gamescope"
        "workspace 10,class:gamescope"
      ];
      gesture = [
        "4,horizontal,workspace"
      ];
      misc = {
        initial_workspace_tracking = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
      };
      workspace = [
        "1,monitor:eDP-1,default:true"
        "2,monitor:eDP-1"
        "3,monitor:eDP-1"
        "4,monitor:eDP-1"
        "5,monitor:desc:LG Electronics LG HDR WQHD 312NTWG9Z889,default:true"
        "6,monitor:desc:LG Electronics LG HDR WQHD 312NTWG9Z889"
        "7,monitor:desc:LG Electronics LG HDR WQHD 312NTWG9Z889"
        "8,monitor:desc:LG Electronics LG HDR WQHD 312NTWG9Z889"
        "9,monitor:desc:Invalid Vendor Codename - RTK 0x1920 demoset-1,default:true"
        "10,monitor:desc:Invalid Vendor Codename - RTK 0x1920 demoset-1"
      ];
    };
  };
}
