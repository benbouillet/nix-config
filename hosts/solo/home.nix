{
  pkgs,
  username,
  host,
  ...
}:
{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  imports = [
    ../../config/hyprland.nix
    ../../config/zsh.nix
    ../../config/waybar.nix
    ../../config/tmux.nix
    ../../config/nvim.nix
  ];

  home.file."Pictures/Wallpapers" = {
    source = ../../config/wallpapers;
    recursive = true;
  };

  programs = {
    kitty.enable = true;
    firefox.enable = true;
    wofi = {
      enable = true;
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];
    };
  };
}
