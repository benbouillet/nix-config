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
    yq # yaml processer https://github.com/mikefarah/yq
    gh
    entr

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
    hello-unfree
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

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
