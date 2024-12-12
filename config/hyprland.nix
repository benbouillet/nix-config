{
# pkgs,
  lib,
  username,
  host,
  config,
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
        follow_mouse = 1;
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
      bind = [
        "${modifier},Return,exec,${terminal}"
        "${modifier},W,exec,${browser}"
        "${modifier},T,exec,thunar"
        "${modifier},SPACE,exec,wofi --show drun"
        ",XF86MonBrightnessDown,exec,brightnessctl set 10%-"
        ",XF86MonBrightnessUp,exec,brightnessctl set +10%"
        "${modifier},Q,killactive"
        "${modifier},P,exec,hyprpicker -a"
        "${modifier}SHIFT,I,togglesplit"
        "${modifier},F,fullscreen"
        "${modifier}SHIFT,F,togglefloating"
        "${modifier}SHIFT,C,exit"
        "${modifier}SHIFT,left,movewindow,l"
        "${modifier}SHIFT,right,movewindow,r"
        "${modifier}SHIFT,up,movewindow,u"
        "${modifier}SHIFT,down,movewindow,d"
        "${modifier}SHIFT,H,movewindow,l"
        "${modifier}SHIFT,L,movewindow,r"
        "${modifier}SHIFT,K,movewindow,u"
        "${modifier}SHIFT,J,movewindow,d"
        "${modifier},left,movefocus,l"
        "${modifier},right,movefocus,r"
        "${modifier},up,movefocus,u"
        "${modifier},down,movefocus,d"
        "${modifier},H,movefocus,l"
        "${modifier},L,movefocus,r"
        "${modifier},K,movefocus,u"
        "${modifier},J,movefocus,d"
        "${modifier},1,workspace,1"
        "${modifier},2,workspace,2"
        "${modifier},3,workspace,3"
        "${modifier},4,workspace,4"
        "${modifier},5,workspace,5"
        "${modifier},6,workspace,6"
        "${modifier},7,workspace,7"
        "${modifier},8,workspace,8"
        "${modifier},9,workspace,9"
        "${modifier},0,workspace,10"
        "${modifier},1,workspace,1"
        "${modifier}SHIFT,S,movetoworkspace,special"
        "${modifier},S,togglespecialworkspace"
        "${modifier}SHIFT,1,movetoworkspace,1"
        "${modifier}SHIFT,2,movetoworkspace,2"
        "${modifier}SHIFT,3,movetoworkspace,3"
        "${modifier}SHIFT,4,movetoworkspace,4"
        "${modifier}SHIFT,5,movetoworkspace,5"
        "${modifier}SHIFT,6,movetoworkspace,6"
        "${modifier}SHIFT,7,movetoworkspace,7"
        "${modifier}SHIFT,8,movetoworkspace,8"
        "${modifier}SHIFT,9,movetoworkspace,9"
        "${modifier}SHIFT,0,movetoworkspace,10"
        "${modifier}CONTROL,L,workspace,e+1"
        "${modifier}CONTROL,H,workspace,e-1"
        "ALT,Tab,cyclenext"
        "ALT,Tab,bringactivetotop"
        ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
      bindm = [
        "${modifier},mouse:272,movewindow"
        "${modifier},mouse:273,resizewindow"
      ];
      binde = [
        "${modifier}ALT,H,resizeactive,-30 0"
        "${modifier}ALT,L,resizeactive,30 0"
        "${modifier}ALT,K,resizeactive,0 -30"
        "${modifier}ALT,J,resizeactive,0 30"
      ];
      # plugin = {
      #   hyprtrails = {
      #     color = "rgba(a6e3a1aa)";
      #     bezier_step = 0.025; #0.025
      #     points_per_step = 2; #2
      #     history_points = 12; #20
      #     history_step = 2;    #2
      #   };
      # };
    };
  };
}
