{
  pkgs,
  theme,
  username,
  wallpaper_file,
  ...
}: 
{
  stylix = {
    enable = true;
    image = ../assets/${wallpaper_file};
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "Fira Code";
      };
      sansSerif = {
        package = pkgs.fira-sans;
        name = "Fira Sans";
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
    opacity = {
      applications = 1.0;
      terminal = 0.8;
      desktop = 1;
      popups = 0.9;
    };
  };

}
