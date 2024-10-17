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
            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
            accel_profile = flat
          }
          gestures {
            workspace_swipe = true
            workspace_swipe_fingers = 3
          }
          monitor=,preferred,auto,1
          bind = ${modifier},Return,exec,${terminal}
          bind = ${modifier},W,exec,${browser}
          bind = ${modifier}SHIFT,Return,exec,rofi -show drun
        ''
      ];
  };
}
