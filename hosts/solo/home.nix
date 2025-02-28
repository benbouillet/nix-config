{
  pkgs,
  username,
  host,
  nixvim,
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
    (import ../../scripts/waybar-tailscale-updown.nix {inherit pkgs; })
    (import ../../scripts/waybar-tailscale-status.nix {inherit pkgs; })
    (import ../../scripts/waybar-ping.nix {inherit pkgs; })
  ];

  stylix.targets = {
    waybar.enable = false;
  };

  imports = [
    nixvim.homeManagerModules.nixvim
    ../../config/brave.nix
    ../../config/dunst.nix
    # ../../config/swaync.nix
    ../../config/hypridle.nix
    ../../config/hyprland.nix
    ../../config/hyprlock.nix
    ../../config/nvim.nix
    ../../config/tmux.nix
    ../../config/waybar.nix
    ../../config/wlogout.nix
    ../../config/wlsunset.nix
    ../../config/zsh.nix
  ];

  home.file."Pictures/Wallpapers" = {
    source = ../../assets;
    recursive = true;
  };

  # DEBUG
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      toggle-maximized = ["<Super>m"];
      toggle-message-tray = ["<Super>t"];
      foo = ["<Super>f"];
    };
  };
  # END OF DEBUG

  programs = {
    home-manager.enable = true;
    kitty.enable = true;
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

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
      config.common.default = "*";
    };
  };
}
