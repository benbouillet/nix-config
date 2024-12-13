{
  username,
  ...
}:
{
  home.file.".config/wlogout/icons/" = {
    source = ./wlogout/icons;
    recursive = true;
  };

  programs.wlogout = {
    enable = true;
    layout = [
      {
        "label" = "lock";
        "action" = "hyprlock";
        "text" = "Lock (L)";
        "keybind" = "l";
      }
      {
        "label" = "logout";
        "action" = "hyprctl dispatch exit";
        "text" = "Logout (O)";
        "keybind" = "o";
      }
      {
        "label" = "shutdown";
        "action" = "systemctl poweroff";
        "text" = "Shutdown (S)";
        "keybind" = "s";
      }
      {
        "label" = "suspend";
        "action" = "systemctl suspend";
        "text" = "Suspend (U)";
        "keybind" = "u";
      }
      {
        "label" = "hibernate";
        "action" = "systemctl hibernate";
        "text" = "Hibernate (H)";
        "keybind" = "h";
      }
      {
        "label" = "reboot";
        "action" = "systemctl reboot";
        "text" = "Reboot (R)";
        "keybind" = "r";
      }
    ];
  };
}
