{
  pkgs,
  lib,
  ...
}:
{
  dconf.settings = {
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
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      toggle-message-tray = ["<Super>t"];
      toggle-maximized = ["<Super>d"];
      minimize = ["<Super>h"];
      show-desktop = ["<Super>d"];

      cycle-group = ["<Alt>F6"];
      cycle-group-backward = ["<Shift><Alt>F6"];
      cycle-panels = ["<Control><Alt>Escape"];
      cycle-panels-backward = ["<Shift><Control><Alt>Escape"];
      cycle-windows = ["<Alt>Escape"];
      cycle-windows-backward = ["<Shift><Alt>Escape"];
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
    "org/gnome/desktop/wm/preferences" = {
      action-double-click-titlebar = "toggle-maximize";
      action-right-click-titlebar = "menu";
      focus-mode = "click";
      num-workspaces = 4;
    };
    "org/gnome/shell" = {
      allow-extension-installation = true;
      # enabled-extensions ["user-theme@gnome-shell-extensions.gcampax.github.com"]
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
    "org/gnome/desktop/input-sources" = {
      sources = [(lib.gvariant.mkTuple [ "xkb" "us" ])];
      xkb-options = [
        "compose:ralt"
        "caps:escape"
      ];
    };
  };
}
