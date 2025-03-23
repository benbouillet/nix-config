{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    obsidian
    spotify
    whatsie
    steam-unwrapped
    discord
    keepassxc
  ];
}
