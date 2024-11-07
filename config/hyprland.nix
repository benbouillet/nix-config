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
            kb_options = grp:alt_shift_toggle
            kb_options = caps:super
            follow_mouse = 1
            touchpad {
              natural_scroll = true
              disable_while_typing = true
              scroll_factor = 0.8
            }
            sensitivity = 0.5
            accel_profile = adaptative
          }
          debug {
            disable_logs = false
          }
          general {
            gaps_in = 4
            gaps_out = 8
            border_size = 2
            layout = master
            resize_on_border = true
            col.active_border = rgb(${config.lib.stylix.colors.base08}) rg(${config.lib.stylix.colors.base0C}) 45deg
            col.inactive_border = rgb(${config.lib.stylix.colors.base01})
          }
          gestures {
            workspace_swipe = true
            workspace_swipe_fingers = 3
          }
          misc {
            initial_workspace_tracking = 2
            mouse_move_enables_dpms = false
            key_press_enables_dpms = true
          }
          monitor=,preferred,auto,1
          bind = ${modifier},Return,exec,${terminal}
          bind = ${modifier},W,exec,${browser}
          bind = ${modifier}SHIFT,Return,exec,rofi -show drun
          bind = ,XF86MonBrightnessDown,exec,brightnessctl set 10%-
          bind = ,XF86MonBrightnessUp,exec,brightnessctl set +10%
        ''
      ];
  };
}
