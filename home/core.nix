{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    # fonts
    # nerdfonts

    # archives
    zip
    xz
    unzip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq

    nmap # A utility for network discovery and security auditing

    # misc
    which
    tree
    gnupg

    # productivity
    glow # markdown previewer in terminal
    obsidian
  ];

  programs = {
    alacritty = {
      enable = true;
      settings = builtins.fromTOML ( builtins.readFile ../config/alacritty.toml );
    };

    fzf.enable = true;

    nnn = {
      enable = true;
    };

  };
}
