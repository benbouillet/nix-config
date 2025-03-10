{
  pkgs,
  lib,
  ...
}:
with lib.hm.gvariant;
{
  home.packages = with pkgs.gnomeExtensions; [
    blur-my-shell
    search-light
    tailscale-status
    caffeine
    vitals
    openweather-refined
    media-controls
    quick-settings-tweaker
    sound-output-device-chooser
    pop-shell
    sound-output-device-chooser
  ];
  dconf.settings = {
    "org/gnome/shell/extensions/pop-shell" = {
      activate-launcher = [ ];
      active-hint-border-radius = mkUint32 12;
      active-hint = true;
      column-size = mkUint32 64;
    };
    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };
    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      clock-show-date = true;
      clock-show-seconds = false;
      clock-show-weekday = true;
      enable-animations = true;
      enable-hot-corners = false;
      show-battery-percentage = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      disable-while-typing = true;
      edge-scrolling-enabled = false;
      tap-and-drag = true;
      two-finger-scrolling-enabled = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      action-double-click-titlebar = "toggle-maximize";
      action-right-click-titlebar = "menu";
      focus-mode = "click";
      num-workspaces = 4;
    };
    "org/gnome/shell" = {
      allow-extension-installation = true;
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        blur-my-shell.extensionUuid
        tailscale-status.extensionUuid
        caffeine.extensionUuid
        vitals.extensionUuid
        openweather-refined.extensionUuid
        media-controls.extensionUuid
        quick-settings-tweaker.extensionUuid
        sound-output-device-chooser.extensionUuid
        pop-shell.extensionUuid
      ];
    };
    "org/gnome/desktop/input-sources" = {
      sources = [(mkTuple [ "xkb" "us" ])];
      xkb-options = [
        "compose:ralt"
        "caps:escape"
      ];
    };
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "${lib.getExe pkgs.ghostty}";
    };
  };
}
