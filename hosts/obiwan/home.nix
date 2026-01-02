{
  pkgs,
  username,
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
    ../../modules/home/neovim
    ../../modules/home/firefox.nix
    ../../modules/home/tmux.nix
    ../../modules/home/zsh.nix
    ../../modules/home/git.nix
    ../../modules/home/hyprland.nix
    ../../modules/home/hyprland-keybindings.nix
    ../../modules/home/hyprlock.nix
    ../../modules/home/hypridle.nix
    ../../modules/home/tofi.nix
    ../../modules/home/waybar.nix
    ../../modules/home/swaync.nix
    ../../modules/home/wlogout.nix
    ../../modules/home/sre.nix
    ../../modules/home/desktop.nix
    ../../modules/home/sunday.nix
    ../../modules/home/2d.nix
    ../../modules/home/3d.nix
    ../../modules/home/productivity.nix
    ../../modules/home/music.nix
    ./syncthing.nix
    ./monitors.nix
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      serverAliveInterval = 30;
      serverAliveCountMax = 3;
      compression = true;
    };
    extraConfig = ''
      Include ~/.ssh/chewie.conf
      Include ~/.ssh/jellybox.conf
    '';
  };

  home.file."Pictures/Wallpapers" = {
    source = ../../assets;
    recursive = true;
  };

  programs = {
    home-manager.enable = true;
  };
}
