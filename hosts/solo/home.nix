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

  home.packages = with pkgs; [
    hyprshot
    hyprpicker
    pavucontrol
    playerctl
    libnotify
    wofi-emoji
    (import ../../scripts/web-search.nix {inherit pkgs; })
    (import ../../scripts/list-hyprland-bindings.nix {inherit pkgs; })
  ];

  stylix.targets = {
    waybar.enable = false;
  };

  imports = [
    ../../config/hyprland.nix
    ../../config/hyprlock.nix
    ../../config/hypridle.nix
    ../../config/zsh.nix
    ../../config/waybar.nix
    ../../config/tmux.nix
    ../../config/nvim.nix
    ../../config/dunst.nix
    ../../config/wlogout.nix
  ];

  home.file."Pictures/Wallpapers" = {
    source = ../../config/wallpapers;
    recursive = true;
  };

  programs = {
    home-manager.enable = true;
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
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  gtk = {
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };
}
