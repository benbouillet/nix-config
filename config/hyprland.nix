{
  lib,
  host,
  ...
}:
let
  inherit (import ../hosts/${host}/variables.nix)
    browser
    terminal
    keyboardLayout
    keyboardVariant
    ;
in
with lib;
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    # plugins = with pkgs; [ hyprlandPlugins.hyprtrails ];
    settings =
      let
        modifier = "SUPER";
      in
      {
      env = [
        "QT_QPA_PLATFORM,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
      ];
      exec-once = [
        "dbus-update-activation-environment --systemd --all"
        "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "waybar"
        "nm-applet --indicator"
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
      debug.disable_logs = true;
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
        resize_on_border = true;
      };
      decoration  = {
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
      animations  = {
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
        "noborder, class:^(wofi)$"
        "center, class:^(wofi)$"
        "workspace emptym, class:^(firefox)$"
        "float, class:^(org.pulseaudio.pavucontrol|.blueman-manager-wrapped|nm-connection-editor)$"
        "stayfocused, class:^(org.pulseaudio.pavucontrol|.blueman-manager-wrapped|nm-connection-editor)$"
        "pin, class:^(org.pulseaudio.pavucontrol|.blueman-manager-wrapped|nm-connection-editor)$"
        "stayfocused, class:^(steam)$"
        "opacity 0.9 0.7, class:^(kitty)$"
      ];
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 4;
      };
      misc = {
        initial_workspace_tracking = 2;
        mouse_move_enables_dpms = false;
        key_press_enables_dpms = true;
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      monitor = ",preferred,auto,1";
      bindd = [
        "${modifier},Return,Open ${terminal},exec,${terminal}"
        "${modifier},W,Open ${browser}, exec,${browser}"
        "${modifier},T,Open file manager Thunar,exec,thunar"
        "${modifier},SPACE,Launch Wofi,exec,wofi --show drun"
        ",XF86MonBrightnessDown,Increase Brightness,exec,brightnessctl set 10%-"
        ",XF86MonBrightnessUp,Decrease Brightness,exec,brightnessctl set +10%"
        "${modifier},Q,Kill Active Window,killactive"
        "${modifier},P,Play/Pause Player,exec,playerctl play-pause"
        "${modifier},C,Color Picker,exec,hyprpicker -a"
        "${modifier}SHIFT,I,Toggle Window Split,togglesplit"
        "${modifier},F,Fullscreen,fullscreen"
        "${modifier},E,Emoji Picker,exec,wofi-emoji"
        "${modifier}SHIFT,W,Web Search,exec,web-search"
        "${modifier},U,Logout,exec,wlogout"
        "${modifier}SHIFT,F,Toggle Floating Windows,togglefloating"
        "${modifier}SHIFT,C,Logout,exit"
        "${modifier}SHIFT,left,Move Active Window Left,movewindow,l"
        "${modifier}SHIFT,right,Move Active Window Right,movewindow,r"
        "${modifier}SHIFT,up,Move Active Window Up,movewindow,u"
        "${modifier}SHIFT,down,Move Active Window Down,movewindow,d"
        "${modifier}SHIFT,H,Move Active Window Left,movewindow,l"
        "${modifier}SHIFT,L,Move Active Window Right,movewindow,r"
        "${modifier}SHIFT,K,Move Active Window Up,movewindow,u"
        "${modifier}SHIFT,J,Move Active Window Down,movewindow,d"
        "${modifier},left,Move Focus Left,movefocus,l"
        "${modifier},right,Move Focus Right,movefocus,r"
        "${modifier},up,Move Focus Up,movefocus,u"
        "${modifier},down,Move Focus Down,movefocus,d"
        "${modifier},H,Move Focus Left,movefocus,l"
        "${modifier},L,Move Focus Right,movefocus,r"
        "${modifier},K,Move Focus Up,movefocus,u"
        "${modifier},J,Move Focus Left,movefocus,d"
        "${modifier},1,Switch to Workspace 1,workspace,1"
        "${modifier},2,Switch to Workspace 2,workspace,2"
        "${modifier},3,Switch to Workspace 3,workspace,3"
        "${modifier},4,Switch to Workspace 4,workspace,4"
        "${modifier},5,Switch to Workspace 5,workspace,5"
        "${modifier},6,Switch to Workspace 6,workspace,6"
        "${modifier},7,Switch to Workspace 7,workspace,7"
        "${modifier},8,Switch to Workspace 8,workspace,8"
        "${modifier},9,Switch to Workspace 9,workspace,9"
        "${modifier},0,Switch to Workspace 10,workspace,10"
        "${modifier},S,Switch to Special Workspace,togglespecialworkspace"
        "${modifier}SHIFT,1,Move Active Window to Workspace 1,movetoworkspace,1"
        "${modifier}SHIFT,2,Move Active Window to Workspace 2,movetoworkspace,2"
        "${modifier}SHIFT,3,Move Active Window to Workspace 3,movetoworkspace,3"
        "${modifier}SHIFT,4,Move Active Window to Workspace 4,movetoworkspace,4"
        "${modifier}SHIFT,5,Move Active Window to Workspace 5,movetoworkspace,5"
        "${modifier}SHIFT,6,Move Active Window to Workspace 6,movetoworkspace,6"
        "${modifier}SHIFT,7,Move Active Window to Workspace 7,movetoworkspace,7"
        "${modifier}SHIFT,8,Move Active Window to Workspace 8,movetoworkspace,8"
        "${modifier}SHIFT,9,Move Active Window to Workspace 9,movetoworkspace,9"
        "${modifier}SHIFT,0,Move Active Window to Workspace 10,movetoworkspace,10"
        "${modifier}CONTROL,L,Switch to Next Workspace,workspace,e+1"
        "${modifier}CONTROL,H,Switch to Previous Workspace,workspace,e-1"
        "ALT,Tab,Cycle On Windows,cyclenext"
        "ALT,Tab,Cycle On Windows,bringactivetotop"
        ",XF86AudioRaiseVolume,Increase Volume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1"
        ",XF86AudioLowerVolume,Decrease Volume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,Mute Volume,exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute,Mute Mic,exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86Keyboard,Cycle Keyboard Backlight,exec,brightnessctl --device='tpacpi::kbd_backlight' set $((($(brightnessctl --device='tpacpi::kbd_backlight' get) + 1) % 3))"
      ];
      bindmd = [
        "${modifier},mouse:272,Move Window,movewindow"
        "${modifier},mouse:273,Resize Window,resizewindow"
      ];
      binded = [
        "${modifier}ALT,H,Resize Active Window Left,resizeactive,-30 0"
        "${modifier}ALT,L,Resize Active Window Right,resizeactive,30 0"
        "${modifier}ALT,K,Resize Active Window Down,resizeactive,0 -30"
        "${modifier}ALT,J,Resize Active Window Up,resizeactive,0 30"
        ",XF86AudioRaiseVolume,Increase Volume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1"
        ",XF86AudioLowerVolume,Decrease Volume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
    };
  };
}
