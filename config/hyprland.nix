{
  lib,
  username,
  host,
  config,
  ...
}:
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
        bind = ${modifier},Return,exec,kitty
      '';
  };
}
