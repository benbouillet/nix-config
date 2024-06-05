{pkgs, config, lib, ...}: {
  # add home-manager user settings here
  home.packages = with pkgs; [
    git
    neovim
    tree
    zsh-vi-mode
    nerdfonts
    ripgrep
    obsidian
  ];
  home.stateVersion = "23.11";

  programs = {
    alacritty = {
      enable = true;
      settings = builtins.fromTOML ( builtins.readFile ../config/alacritty.toml );
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      antidote.enable = true;
      antidote.plugins = [
          "jeffreytse/zsh-vi-mode"
          "davidde/git"
      ];
    };

    git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        user.email = "15980664+benbouillet@users.noreply.github.com";
        user.name = "Ben Bouillet";
      };
      aliases = {
        gst = "status";
      };
    };
  };
}
