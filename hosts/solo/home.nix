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
    (import ../../scripts/list-hyprland-bindings.nix {inherit pkgs; })
    (import ../../scripts/emoji-picker.nix {inherit pkgs; })
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
    ../../home/hyprland.nix
    ../../home/hyprland-keybindings.nix
    ../../home/hyprlock.nix
    ../../home/hypridle.nix
    ../../home/tofi.nix
    ../../home/waybar.nix
    ../../home/swaync.nix
    ../../home/wlogout.nix
    ../../home/sre.nix
    ../../home/personal.nix
  ];

  home.file."Pictures/Wallpapers" = {
    source = ../../assets;
    recursive = true;
  };

  programs = {
    home-manager.enable = true;
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installVimSyntax = true;
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
