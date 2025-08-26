{
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    hyprpicker
  ];

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    xwayland.enable = true;

    dconf.enable = true;
  };

  security = {
    polkit.enable = true;
    pam.services.hyprlock = {};
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  services = {
    xserver = {
      enable = true;
      displayManager.startx.enable = false;
    };
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.tuigreet}; '${pkgs.uwsm}/bin/uwsm start -- hyprland-uwsm.desktop'";
          user = "greeter";
        };
      };
    };
  };
}
