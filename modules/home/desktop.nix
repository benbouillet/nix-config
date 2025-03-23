{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    fastfetch
    obsidian
    spotify
    whatsie
    steam-unwrapped
    discord
    keepassxc
  ];

  xdg.desktopEntries = {
    spotify = {
      name = "Spotify";
      genericName = "Music Player";
      exec = "spotify";
      terminal = false;
    };
  };
}
