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
}
