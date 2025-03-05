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
    nixos-icons
    (import ../../scripts/web-search.nix {inherit pkgs; })
    (import ../../scripts/list-hyprland-bindings.nix {inherit pkgs; })
    (import ../../scripts/waybar-tailscale-updown.nix {inherit pkgs; })
    (import ../../scripts/waybar-tailscale-status.nix {inherit pkgs; })
    (import ../../scripts/waybar-ping.nix {inherit pkgs; })
  ];

  stylix.targets = {
    qt.enable = false;
  };

  imports = [
    nixvim.homeManagerModules.nixvim
    ../../home/firefox.nix
    ../../home/nvim.nix
    ../../home/tmux.nix
    ../../home/zsh.nix
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
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installVimSyntax = true;
    };
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
}
