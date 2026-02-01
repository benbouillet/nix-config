{
  ...
}:
{
  home.file.".config/wallpapers" = {
    source = ../../assets/wallpapers;
    recursive = true;
  };

  services = {
    hyprpaper = {
      enable = true;
      settings = {
        wallpaper = [
          {
            monitor = "";
            path = "~/.config/wallpapers/dnd_map.jpg";
            fit_mode = "cover";
          }
        ];
      };
    };
  };
}
