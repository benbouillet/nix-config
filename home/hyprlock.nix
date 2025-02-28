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
        blur_passes = 0;
        blur_size = 2;
        noise = 0;
        contrast = 0;
        brightness = 0;
        vibrancy = 0;
        vibrancy_darkness = 0.0;
      };

      label = [
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%A, %B %d\")\"";
          font_size = 20;
          position = "0, 405";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%k:%M\")\"";
          font_size = 93;
          position = "0, 310";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = {
        size = "275, 30";
        outline_thickness = 0;
        dots_size = 0.25;
        dots_spacing = 0.55;
        dots_center = true;
        dots_rounding = -1;
        fade_on_empty = false;
        placeholder_text = "";
        hide_input = false;
        fail_text = "$FAIL <b>($ATTEMPTS)</b>";
        fail_transition = 300;
        capslock_color = -1;
        numlock_color = -1;
        bothlock_color = -1;
        invert_numlock = false;
        swap_font_color = false;
        position = "0, -468";
        halign = "center";
        valign = "center";
      };
    };
  };
}
