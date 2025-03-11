{
  config,
  ...
}:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general  = {
        disable_loading_bar = true;
        hide_cursor = true;
      };

      # BACKGROUND
      background = {
        monitor = "";
        blur_passes = 1;
      };

      label = [
        {
          monitor = "";
          text = "Layout: $LAYOUT";
          font_size = 12;
          position = "-30, 30";
          halign = "right";
          valign = "bottom";
        }
        {
          monitor = "";
          text = "$TIME";
          color = config.lib.stylix.colors.base05;
          font_size = 90;
          font_family = config.stylix.fonts.sansSerif.name;
          position = "0, 0";
          halign = "center";
          valign = "top";
        }
        {
          monitor = "";
          text = "cmd[update:43200000] date +\"%A, %d %B %Y\"";
          color = config.lib.stylix.colors.base05;
          font_size = 25;
          # font_family = $font
          position = "0, -150";
          halign = "center";
          valign = "top";
        }
      ];

      input-field = {
        monitor = "";
        size = "300, 60";
        outline_thickness = 3;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        fade_on_empty = false;
        placeholder_text = "<span foreground=\"##${config.lib.stylix.colors.base0D}\"><i>󰌾 Logged in as </i><span foreground=\"##${config.lib.stylix.colors.base0E}\">$USER</span></span>";
        hide_input = false;
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "$yellow";
        position = "0, -55";
        halign = "center";
        valign = "center";
      };
    };
  };
}
