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
    file-roller
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
