{ config, ... }:

{
  services.swaync = {
    enable = true;

    settings = {
      "$schema" = "/etc/xdg/swaync/configSchema.json";
      positionX = "right";
      positionY = "top";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 10;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = false;
      control-center-width = 500;
      control-center-height = 1025;
      notification-window-width = 500;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      widgets = [
        "title"
        "mpris"
        "volume"
        "backlight"
        "dnd"
        "notifications"
      ];
      widget-config = {
        title = {
          text = "Notification Center2";
          clear-all-button = true;
          button-text = "󰆴 Clear All";
        };
        dnd = {
          text = "Do Not Disturb2";
        };
        label = {
          max-lines = 1;
          text = "Notification Center2";
        };
        mpris = {
          image-size = 96;
          image-radius = 7;
        };
        volume = {
          label = "󰕾";
        };
        backlight = {
          label = "󰃟";
        };
      };
    };
  };

    # style = ''
    #   * {
    #     all: unset;
    #     font-size: 14px;
    #     font-family: FiraCode Nerd Font;
    #     transition: 200ms;
    #   }

    #   trough highlight {
    #     background: #c6d0f5;
    #   }

    #   scale trough {
    #     margin: 0rem 1rem;
    #     background-color: #414559;
    #     min-height: 8px;
    #     min-width: 70px;
    #   }

    #   slider {
    #     background-color: #8caaee;
    #   }

    #   .floating-notifications.background .notification-row .notification-background {
    #     box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px #414559;
    #     border-radius: 12.6px;
    #     margin: 18px;
    #     background-color: #303446;
    #     color: #c6d0f5;
    #     padding: 0;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .notification {
    #     padding: 7px;
    #     border-radius: 12.6px;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .notification.critical {
    #     box-shadow: inset 0 0 7px 0 #e78284;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .notification .notification-content {
    #     margin: 7px;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
    #     color: #c6d0f5;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
    #     color: #a5adce;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
    #     color: #c6d0f5;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
    #     min-height: 3.4em;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
    #     border-radius: 7px;
    #     color: #c6d0f5;
    #     background-color: #414559;
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     margin: 7px;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     background-color: #414559;
    #     color: #c6d0f5;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     background-color: #85c1dc;
    #     color: #c6d0f5;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .close-button {
    #     margin: 7px;
    #     padding: 2px;
    #     border-radius: 6.3px;
    #     color: #303446;
    #     background-color: #e78284;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .close-button:hover {
    #     background-color: #ea999c;
    #     color: #303446;
    #   }

    #   .floating-notifications.background .notification-row .notification-background .close-button:active {
    #     background-color: #e78284;
    #     color: #303446;
    #   }

    #   .control-center {
    #     box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px #414559;
    #     border-radius: 12.6px;
    #     margin: 18px;
    #     background-color: #303446;
    #     color: #c6d0f5;
    #     padding: 14px;
    #   }

    #   .control-center .widget-title > label {
    #     color: #c6d0f5;
    #     font-size: 1.3em;
    #   }

    #   .control-center .widget-title button {
    #     border-radius: 7px;
    #     color: #c6d0f5;
    #     background-color: #414559;
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     padding: 8px;
    #   }

    #   .control-center .widget-title button:hover {
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     background-color: #626880;
    #     color: #c6d0f5;
    #   }

    #   .control-center .widget-title button:active {
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     background-color: #85c1dc;
    #     color: #303446;
    #   }

    #   .control-center .notification-row .notification-background {
    #     border-radius: 7px;
    #     color: #c6d0f5;
    #     background-color: #414559;
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     margin-top: 14px;
    #   }

    #   .control-center .notification-row .notification-background .notification {
    #     padding: 7px;
    #     border-radius: 7px;
    #   }

    #   .control-center .notification-row .notification-background .notification.critical {
    #     box-shadow: inset 0 0 7px 0 #e78284;
    #   }

    #   .control-center .notification-row .notification-background .notification .notification-content {
    #     margin: 7px;
    #   }

    #   .control-center .notification-row .notification-background .notification .notification-content .summary {
    #     color: #c6d0f5;
    #   }

    #   .control-center .notification-row .notification-background .notification .notification-content .time {
    #     color: #a5adce;
    #   }

    #   .control-center .notification-row .notification-background .notification .notification-content .body {
    #     color: #c6d0f5;
    #   }

    #   .control-center .notification-row .notification-background .notification > *:last-child > * {
    #     min-height: 3.4em;
    #   }

    #   .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
    #     border-radius: 7px;
    #     color: #c6d0f5;
    #     background-color: #232634;
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     margin: 7px;
    #   }

    #   .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     background-color: #414559;
    #     color: #c6d0f5;
    #   }

    #   .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     background-color: #85c1dc;
    #     color: #c6d0f5;
    #   }

    #   .control-center .notification-row .notification-background .close-button {
    #     margin: 7px;
    #     padding: 2px;
    #     border-radius: 6.3px;
    #     color: #303446;
    #     background-color: #ea999c;
    #   }

    #   .close-button {
    #     border-radius: 6.3px;
    #   }

    #   .control-center .notification-row .notification-background .close-button:hover {
    #     background-color: #e78284;
    #     color: #303446;
    #   }

    #   .control-center .notification-row .notification-background .close-button:active {
    #     background-color: #e78284;
    #     color: #303446;
    #   }

    #   .control-center .notification-row .notification-background:hover {
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     background-color: #838ba7;
    #     color: #c6d0f5;
    #   }

    #   .control-center .notification-row .notification-background:active {
    #     box-shadow: inset 0 0 0 1px #51576d;
    #     background-color: #85c1dc;
    #     color: #c6d0f5;
    #   }

    #   .notification.critical progress {
    #     background-color: #e78284;
    #   }

    #   .notification.low progress,
    #   .notification.normal progress {
    #     background-color: #8caaee;
    #   }

    #   .control-center-dnd {
    #     margin-top: 5px;
    #     border-radius: 8px;
    #     background: #414559;
    #     border: 1px solid #51576d;
    #     box-shadow: none;
    #   }

    #   .control-center-dnd:checked {
    #     background: #414559;
    #   }

    #   .control-center-dnd slider {
    #     background: #51576d;
    #     border-radius: 8px;
    #   }

    #   .widget-dnd {
    #     margin: 0px;
    #     font-size: 1.1rem;
    #   }

    #   .widget-dnd > switch {
    #     font-size: initial;
    #     border-radius: 8px;
    #     background: #414559;
    #     border: 1px solid #51576d;
    #     box-shadow: none;
    #   }

    #   .widget-dnd > switch:checked {
    #     background: #414559;
    #   }

    #   .widget-dnd > switch slider {
    #     background: #51576d;
    #     border-radius: 8px;
    #     border: 1px solid #737994;
    #   }

    #   .widget-mpris .widget-mpris-player {
    #     background: #414559;
    #     padding: 7px;
    #   }

    #   .widget-mpris .widget-mpris-title {
    #     font-size: 1.2rem;
    #   }

    #   .widget-mpris .widget-mpris-subtitle {
    #     font-size: 0.8rem;
    #   }

    #   .widget-menubar > box > .menu-button-bar > button > label {
    #     font-size: 3rem;
    #     padding: 0.5rem 2rem;
    #   }

    #   .widget-menubar > box > .menu-button-bar > :last-child {
    #     color: #e78284;
    #   }

    #   .power-buttons button:hover,
    #   .powermode-buttons button:hover,
    #   .screenshot-buttons button:hover {
    #     background: #414559;
    #   }

    #   .control-center .widget-label > label {
    #     color: #c6d0f5;
    #     font-size: 2rem;
    #   }

    #   .widget-buttons-grid {
    #     padding-top: 1rem;
    #   }

    #   .widget-buttons-grid > flowbox > flowboxchild > button label {
    #     font-size: 2.5rem;
    #   }

    #   .widget-volume {
    #     padding-top: 1rem;
    #   }

    #   .widget-volume label {
    #     font-size: 1.5rem;
    #     color: #85c1dc;
    #   }

    #   .widget-volume trough highlight {
    #     background: #85c1dc;
    #   }

    #   .widget-backlight trough highlight {
    #     background: #e5c890;
    #   }

    #   .widget-backlight label {
    #     font-size: 1.5rem;
    #     color: #e5c890;
    #   }

    #   .widget-backlight .KB {
    #     padding-bottom: 1rem;
    #   }

    #   .image {
    #     padding-right: 0.5rem;
    #   }
    # '';
  # };

  # home.file.".config/swaync/style.css".text = ''
  #   * {
  #     font-family: FiraCode Nerd Font;
  #     font-weight: bold;
  #   }
  #   .control-center .notification-row:focus,
  #   .control-center .notification-row:hover {
  #     opacity: 0.9;
  #     background: #${config.lib.stylix.colors.base00};
  #   }
  #   .notification-row {
  #     outline: none;
  #     margin: 10px;
  #     padding: 0;
  #   }
  #   .notification {
  #     background: transparent;
  #     padding: 0;
  #     margin: 0px;
  #   }
  #   .notification-content {
  #     background: #${config.lib.stylix.colors.base00};
  #     padding: 10px;
  #     border-radius: 5px;
  #     border: 2px solid #${config.lib.stylix.colors.base0D};
  #     margin: 0;
  #   }
  #   .notification-default-action {
  #     margin: 0;
  #     padding: 0;
  #     border-radius: 5px;
  #   }
  #   .close-button {
  #     background: #${config.lib.stylix.colors.base08};
  #     color: #${config.lib.stylix.colors.base00};
  #     text-shadow: none;
  #     padding: 0;
  #     border-radius: 5px;
  #     margin-top: 5px;
  #     margin-right: 5px;
  #   }
  #   .close-button:hover {
  #     box-shadow: none;
  #     background: #${config.lib.stylix.colors.base0D};
  #     transition: all .15s ease-in-out;
  #     border: none
  #   }
  #   .notification-action {
  #     border: 2px solid #${config.lib.stylix.colors.base0D};
  #     border-top: none;
  #     border-radius: 5px;
  #   }
  #   .notification-default-action:hover,
  #   .notification-action:hover {
  #     color: #${config.lib.stylix.colors.base0B};
  #     background: #${config.lib.stylix.colors.base0B};
  #   }
  #   .notification-default-action {
  #     border-radius: 5px;
  #     margin: 0px;
  #   }
  #   .notification-default-action:not(:only-child) {
  #     border-bottom-left-radius: 7px;
  #     border-bottom-right-radius: 7px
  #   }
  #   .notification-action:first-child {
  #     border-bottom-left-radius: 10px;
  #     background: #${config.lib.stylix.colors.base00};
  #   }
  #   .notification-action:last-child {
  #     border-bottom-right-radius: 10px;
  #     background: #${config.lib.stylix.colors.base00};
  #   }
  #   .inline-reply {
  #     margin-top: 8px
  #   }
  #   .inline-reply-entry {
  #     background: #${config.lib.stylix.colors.base00};
  #     color: #${config.lib.stylix.colors.base05};
  #     caret-color: #${config.lib.stylix.colors.base05};
  #     border: 1px solid #${config.lib.stylix.colors.base09};
  #     border-radius: 5px
  #   }
  #   .inline-reply-button {
  #     margin-left: 4px;
  #     background: #${config.lib.stylix.colors.base00};
  #     border: 1px solid #${config.lib.stylix.colors.base09};
  #     border-radius: 5px;
  #     color: #${config.lib.stylix.colors.base05};
  #   }
  #   .inline-reply-button:disabled {
  #     background: initial;
  #     color: #${config.lib.stylix.colors.base03};
  #     border: 1px solid transparent
  #   }
  #   .inline-reply-button:hover {
  #     background: #${config.lib.stylix.colors.base00};
  #   }
  #   .body-image {
  #     margin-top: 6px;
  #     background-color: #${config.lib.stylix.colors.base05};
  #     border-radius: 5px
  #   }
  #   .summary {
  #     font-size: 16px;
  #     font-weight: 700;
  #     background: transparent;
  #     color: rgba(158, 206, 106, 1);
  #     text-shadow: none
  #   }
  #   .time {
  #     font-size: 16px;
  #     font-weight: 700;
  #     background: transparent;
  #     color: #${config.lib.stylix.colors.base05};
  #     text-shadow: none;
  #     margin-right: 18px
  #   }
  #   .body {
  #     font-size: 15px;
  #     font-weight: 400;
  #     background: transparent;
  #     color: #${config.lib.stylix.colors.base05};
  #     text-shadow: none
  #   }
  #   .control-center {
  #     background: #${config.lib.stylix.colors.base00};
  #     border: 2px solid #${config.lib.stylix.colors.base0C};
  #     border-radius: 5px;
  #   }
  #   .control-center-list {
  #     background: transparent
  #   }
  #   .control-center-list-placeholder {
  #     opacity: .5
  #   }
  #   .floating-notifications {
  #     background: transparent
  #   }
  #   .blank-window {
  #     background: alpha(black, 0)
  #   }
  #   .widget-title {
  #     color: #${config.lib.stylix.colors.base0B};
  #     background: #${config.lib.stylix.colors.base00};
  #     padding: 5px 10px;
  #     margin: 10px 10px 5px 10px;
  #     font-size: 1.5rem;
  #     border-radius: 5px;
  #   }
  #   .widget-title>button {
  #     font-size: 1rem;
  #     color: #${config.lib.stylix.colors.base05};
  #     text-shadow: none;
  #     background: #${config.lib.stylix.colors.base00};
  #     box-shadow: none;
  #     border-radius: 5px;
  #   }
  #   .widget-title>button:hover {
  #     background: #${config.lib.stylix.colors.base08};
  #     color: #${config.lib.stylix.colors.base00};
  #   }
  #   .widget-dnd {
  #     background: #${config.lib.stylix.colors.base00};
  #     padding: 5px 10px;
  #     margin: 10px 10px 5px 10px;
  #     border-radius: 5px;
  #     font-size: large;
  #     color: #${config.lib.stylix.colors.base0B};
  #   }
  #   .widget-dnd>switch {
  #     border-radius: 5px;
  #     /* border: 1px solid #${config.lib.stylix.colors.base0B}; */
  #     background: #${config.lib.stylix.colors.base0B};
  #   }
  #   .widget-dnd>switch:checked {
  #     background: #${config.lib.stylix.colors.base08};
  #     border: 1px solid #${config.lib.stylix.colors.base08};
  #   }
  #   .widget-dnd>switch slider {
  #     background: #${config.lib.stylix.colors.base00};
  #     border-radius: 5px
  #   }
  #   .widget-dnd>switch:checked slider {
  #     background: #${config.lib.stylix.colors.base00};
  #     border-radius: 5px
  #   }
  #   .widget-label {
  #       margin: 10px 10px 5px 10px;
  #   }
  #   .widget-label>label {
  #     font-size: 1rem;
  #     color: #${config.lib.stylix.colors.base05};
  #   }
  #   .widget-mpris {
  #     color: #${config.lib.stylix.colors.base05};
  #     padding: 5px 10px;
  #     margin: 10px 10px 5px 10px;
  #     border-radius: 5px;
  #   }
  #   .widget-mpris > box > button {
  #     border-radius: 5px;
  #   }
  #   .widget-mpris-player {
  #     padding: 5px 10px;
  #     margin: 10px
  #   }
  #   .widget-mpris-title {
  #     font-weight: 700;
  #     font-size: 1.25rem
  #   }
  #   .widget-mpris-subtitle {
  #     font-size: 1.1rem
  #   }
  #   .widget-menubar>box>.menu-button-bar>button {
  #     border: none;
  #     background: transparent
  #   }
  #   .topbar-buttons>button {
  #     border: none;
  #     background: transparent
  #   }
  #   .widget-volume {
  #     background: #${config.lib.stylix.colors.base01};
  #     padding: 5px;
  #     margin: 10px 10px 5px 10px;
  #     border-radius: 5px;
  #     font-size: x-large;
  #     color: #${config.lib.stylix.colors.base05};
  #   }
  #   .widget-volume>box>button {
  #     background: #${config.lib.stylix.colors.base0B};
  #     border: none
  #   }
  #   .per-app-volume {
  #     background-color: #${config.lib.stylix.colors.base00};
  #     padding: 4px 8px 8px;
  #     margin: 0 8px 8px;
  #     border-radius: 5px;
  #   }
  #   .widget-backlight {
  #     background: #${config.lib.stylix.colors.base01};
  #     padding: 5px;
  #     margin: 10px 10px 5px 10px;
  #     border-radius: 5px;
  #     font-size: x-large;
  #     color: #${config.lib.stylix.colors.base05};
  #   }
  # '';
}
