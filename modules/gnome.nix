{
  username,
  pkgs,
  ...
}:
{
  programs.dconf.enable = true;
  services.xserver = {
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    desktopManager.gnome.enable = true;
  };
  systemd.services.logind.enable = false;
  services.gnome.core-utilities.enable = false;

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    gsettings-desktop-schemas
  ];
}
