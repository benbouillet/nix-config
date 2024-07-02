{ inputs, pkgs, hostConfig,... }:

{
  home.packages = with pkgs; [
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
    go-task
    coreutils

    # productivity
    glow # markdown previewer in terminal
    obsidian
  ] ++ hostConfig.pkgs;

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
