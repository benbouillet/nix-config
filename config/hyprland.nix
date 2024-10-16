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
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    extraConfig =
      let
        modifier = "SUPER";
      in
      ''
        monitor=,preferred,auto,1
        bind = ${modifier},Return,exec,${terminal}
        bind = ${modifier},W,exec,${browser}
      '';
  };
}
