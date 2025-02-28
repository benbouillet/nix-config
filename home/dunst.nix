{
  config,
  ...
}:
{
  services.dunst = {
    enable = true;
    iconTheme = with config.gtk.iconTheme; {
      inherit name package;
    };
    settings = {
      global = {
        follow = "keyboard";
        enable_posix_regex = true;
        width = 400;
        height = 100;
        origin = "top-right";
        offset = "20x20";
        corner_radius = 10;
        transparency = 10;
        gap_size = 5;
        notification_limit = 5;
        format = "<b>%s</b>\n%b";
      };

      urgency_low = {
        timeout = 5;
      };

      urgency_normal = {
        timeout = 10;
      };

      urgency_critical = {
        timeout = 0;
      };
    };
  };
}
