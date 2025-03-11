{
  pkgs,
  lib,
  ...
}:
with lib.hm.gvariant;
{
  dconf.settings = {
    "org/gnome/shell/extensions/pop-shell" = {
      focus-down = [ "<Super>j" ];
      focus-left = [ "<Super>h" ];
      focus-right = [ "<Super>l" ];
      focus-up = [ "<Super>k" ];
      tile-resize-down = [ "<Shift><Super>j" ];
      tile-resize-left = [ "<Shift><Super>h" ];
      tile-resize-right = [ "<Shift><Super>l" ];
      tile-resize-up = [ "<Shift><Super>k" ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      # toggle-message-tray = ["<Super>t"];
      # toggle-maximized = ["<Super>d"];
      # minimize = ["<Super>m"];
      # show-desktop = ["<Super>d"];
      cycle-windows = ["<Alt>Tab"];
      cycle-windows-backward = ["<Shift><Alt>Tab"];
      # move-to-center = [];
      # move-to-corner-ne = [];
      # move-to-corner-nw = [];
      # move-to-corner-se = [];
      # move-to-corner-sw = [];
      # move-to-monitor-down = ["<Super><Shift>Down"];
      # move-to-monitor-left = ["<Super><Shift>Left"];
      # move-to-monitor-right = ["<Super><Shift>Right"];
      # move-to-monitor-up = ["<Super><Shift>Up"];
      # move-to-side-e = [];
      # move-to-side-n = [];
      # move-to-side-s = [];
      # move-to-side-w = [];
      # move-to-workspace-1 = ["<Shift><Super>1"];
      # move-to-workspace-10 = [];
      # move-to-workspace-11 = [];
      # move-to-workspace-12 = [];
      # move-to-workspace-2 = [];
      # move-to-workspace-3 = [];
      # move-to-workspace-4 = [];
      # move-to-workspace-5 = [];
      # move-to-workspace-6 = [];
      # move-to-workspace-7 = [];
      # move-to-workspace-8 = [];
      # move-to-workspace-9 = [];
      # move-to-workspace-down = ["<Control><Shift><Alt>Down"];
      # move-to-workspace-last = ["<Super><Shift>End"];
      # move-to-workspace-left = ["<Super><Shift>Page_Up', '<Super><Shift><Alt>Left', '<Control><Shift><Alt>Left"];
      # move-to-workspace-right = ["<Super><Shift>Page_Down', '<Super><Shift><Alt>Right', '<Control><Shift><Alt>Right"];
      # move-to-workspace-up = ["<Control><Shift><Alt>Up"];
      switch-applications = ["<Super>Tab', '<Alt>Tab"];
      switch-applications-backward = ["<Shift><Super>Tab', '<Shift><Alt>Tab"];
      switch-group = ["<Super>Above_Tab', '<Alt>Above_Tab"];
      switch-group-backward = ["<Shift><Super>Above_Tab', '<Shift><Alt>Above_Tab"];
      switch-input-source = ["<Super>space', 'XF86Keyboard"];
      switch-input-source-backward = ["<Shift><Super>space', '<Shift>XF86Keyboard"];
      switch-panels = ["<Control><Alt>Tab"];
      switch-panels-backward = ["<Shift><Control><Alt>Tab"];
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      switch-to-workspace-5 = ["<Super>5"];
      switch-to-workspace-6 = ["<Super>6"];
      switch-to-workspace-7 = ["<Super>7"];
      switch-to-workspace-8 = ["<Super>8"];
      switch-to-workspace-9 = ["<Super>9"];
      switch-to-workspace-down = ["<Control><Alt>Down"];
      switch-to-workspace-last = ["<Super>0"];
      switch-to-workspace-left = ["<Shift><Super>h"];
      switch-to-workspace-right = ["<Shift><Super>l"];
      switch-to-workspace-up = ["<Control><Alt>Up"];
      switch-windows = [];
      switch-windows-backward = [];
      toggle-fullscreen = ["<Super>f"];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "lock";
      command = "xdg-screensaver lock";
      binding = "<Shift><Super>q";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "logout";
      command = "gnome-sessin-quit";
      binding = "<Shift><Super>x";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "ghostty";
      command = "ghostty}";
      binding = "<Super>Return";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      name = "thunar";
      command = "${lib.getExe pkgs.xfce.thunar}";
      binding = "<Super>u";
    };
    "org/gnome/shell/keybindings" = {
      focus-active-notification = ["<Super>n"];
      screenshot = ["<Shift>Print"];
      screenshot-window = ["<Alt>Print"];
      show-screen-recording-ui = ["<Ctrl><Shift><Alt>R"];
      show-screenshot-ui = ["Print"];
      toggle-application-view = ["<Super>a"];
      toggle-message-tray = ["<Super>v', '<Super>m"];
      toggle-overview = ["<Super>"];
      toggle-quick-settings = ["<Super>s"];
    };
  };
}
