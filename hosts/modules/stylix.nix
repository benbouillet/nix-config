{
  pkgs,
  ...
}: 
{
  stylix = {
    enable = true;
    image = ../../files/wallpapers/${wallpaper_file};
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 24;
    fonts = {
      monospace = {
        package = pkgs.nerdfonts;
        name = "Fira Code";
      };
      sansSerif = {
        package = pkgs.roboto;
        name = "Roboto";
      };
      serif = {
        package = pkgs.roboto-serif;
        name = "Robot Serif";
      };
      emoji = {
        name = "Noto Emoji";
        package = pkgs.noto-fonts-monochrome-emoji;
      };
      sizes = {
        applications = 12;
        terminal = 13;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
