{
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
    extraConfig =
      let
        modifier = "SUPER";
      in
      concatStrings [
        ''
          env = QT_QPA_PLATFORM=wayland;xcb
          env = XDG_CURRENT_DESKTOP, Hyprland
          exec-once = dbus-update-activation-environment --systemd --all
          exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
          exec-once = killall -q swww;sleep .5 && swww init
          exec-once = killall -q waybar;sleep .5 && waybar
          exec-once = nm-applet --indicator
          input {
            kb_layout = ${keyboardLayout}
            kb_variant = ${keyboardVariant}
            kb_options = caps:escape
            follow_mouse = 1
            touchpad {
              natural_scroll = true
              disable_while_typing = true
              scroll_factor = 0.8
            }
            sensitivity = 0.5
            accel_profile = adaptative
            repeat_rate = 20
            repeat_delay = 400
          }
          debug {
            disable_logs = false
          }
          general {
            gaps_in = 4
            gaps_out = 8
            border_size = 2
            layout = dwindle
            resize_on_border = true
            col.active_border = rgb(${config.lib.stylix.colors.base08}) rg(${config.lib.stylix.colors.base0C}) 45deg
            col.inactive_border = rgb(${config.lib.stylix.colors.base01})
          }
          decoration {
            rounding = 10
            drop_shadow = true
            shadow_range = 4
            col.shadow = rgba(1a1a1aee)
            blur {
              enabled = true
              size = 5
              passes = 3
              new_optimizations = on
              ignore_opacity = off
            }
          }
          animations {
            enabled = yes
            bezier = wind, 0.05, 0.9, 0.1, 1.05
            bezier = winIn, 0.1, 1.1, 0.1, 1.1
            bezier = winOut, 0.3, -0.3, 0, 1
            bezier = liner, 1, 1, 1, 1
            animation = windows, 1, 6, wind, slide
            animation = windowsIn, 1, 6, winIn, slide
            animation = windowsOut, 1, 5, winOut, slide
            animation = windowsMove, 1, 5, wind, slide
            animation = border, 1, 1, liner
            animation = fade, 1, 10, default
            animation = workspaces, 1, 5, wind
          }
          windowrulev2 = noborder, class:^(rofi)$
          windowrulev2 = center, class:^(rofi)$
          windowrulev2 = workspace emptym, class:^(firefox)$
          windowrulev2 = float, class:^(nm-connection-editor|blueman-manager)$
          windowrulev2 = stayfocused, class:^(steam)$
          windowrulev2 = opacity 0.9 0.7, class:^(kitty)$
          gestures {
            workspace_swipe = true
            workspace_swipe_fingers = 4
          }
          plugins {
            hyprtrails {
            }
          }
          misc {
            initial_workspace_tracking = 2
            mouse_move_enables_dpms = false
            key_press_enables_dpms = true
          }
          dwindle {
            pseudotile = true
            preserve_split = true
          }
          monitor=,preferred,auto,1
          bind = ${modifier},Return,exec,${terminal}
          bind = ${modifier},W,exec,${browser}
          bind = ${modifier},T,exec,thunar
          bind = ${modifier}SHIFT,F,exec,${browser}
          bind = ${modifier},SPACE,exec,rofi -show drun
          bind = ,XF86MonBrightnessDown,exec,brightnessctl set 10%-
          bind = ,XF86MonBrightnessUp,exec,brightnessctl set +10%
          bindm = ${modifier},mouse:272,movewindow
          bindm = ${modifier},mouse:273,resizewindow
          bind = ${modifier},Q,killactive
          bind = ${modifier},P,pseudo
          bind = ${modifier}SHIFT,I,togglesplit
          bind = ${modifier},F,fullscreen
          bind = ${modifier}SHIFT,F,togglefloating
          bind = ${modifier}SHIFT,C,exit
          bind = ${modifier}SHIFT,left,movewindow,l
          bind = ${modifier}SHIFT,right,movewindow,r
          bind = ${modifier}SHIFT,up,movewindow,u
          bind = ${modifier}SHIFT,down,movewindow,d
          bind = ${modifier}ALT,H,resizeactive,-30 0
          bind = ${modifier}ALT,L,resizeactive,30 0
          bind = ${modifier}ALT,K,resizeactive,0 -30
          bind = ${modifier}ALT,J,resizeactive,0 30
          bind = ${modifier}SHIFT,H,movewindow,l
          bind = ${modifier}SHIFT,L,movewindow,r
          bind = ${modifier}SHIFT,K,movewindow,u
          bind = ${modifier}SHIFT,J,movewindow,d
          bind = ${modifier},left,movefocus,l
          bind = ${modifier},right,movefocus,r
          bind = ${modifier},up,movefocus,u
          bind = ${modifier},down,movefocus,d
          bind = ${modifier},H,movefocus,l
          bind = ${modifier},L,movefocus,r
          bind = ${modifier},K,movefocus,u
          bind = ${modifier},J,movefocus,d
          bind = ${modifier},1,workspace,1
          bind = ${modifier},2,workspace,2
          bind = ${modifier},3,workspace,3
          bind = ${modifier},4,workspace,4
          bind = ${modifier},5,workspace,5
          bind = ${modifier},6,workspace,6
          bind = ${modifier},7,workspace,7
          bind = ${modifier},8,workspace,8
          bind = ${modifier},9,workspace,9
          bind = ${modifier},0,workspace,10
          bind = ${modifier},1,workspace,1
          bind = ${modifier}SHIFT,S,movetoworkspace,special
          bind = ${modifier},S,togglespecialworkspace
          bind = ${modifier}SHIFT,1,movetoworkspace,1
          bind = ${modifier}SHIFT,2,movetoworkspace,2
          bind = ${modifier}SHIFT,3,movetoworkspace,3
          bind = ${modifier}SHIFT,4,movetoworkspace,4
          bind = ${modifier}SHIFT,5,movetoworkspace,5
          bind = ${modifier}SHIFT,6,movetoworkspace,6
          bind = ${modifier}SHIFT,7,movetoworkspace,7
          bind = ${modifier}SHIFT,8,movetoworkspace,8
          bind = ${modifier}SHIFT,9,movetoworkspace,9
          bind = ${modifier}SHIFT,0,movetoworkspace,10
          bind = ${modifier}CONTROL,L,workspace,e+1
          bind = ${modifier}CONTROL,H,workspace,e-1
          bind = ALT,Tab,cyclenext
          bind = ALT,Tab,bringactivetotop
          bind = ,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
          bind = ,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
          bind = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ''
      ];
  };
}
