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
      sessionVariables = {
        LC_ALL="en_US.UTF-8";
        LANG="en_US.UTF-8";
        TERM="alacritty";
        EDITOR="nvim";
        COMPLETION_WAITING_DOTS="true";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "vi-mode"
          "git"
          "docker"
          "docker-compose"
          "dotenv"
          "aws"
          "gcloud"
          "colored-man-pages"
          "fzf"
          "gitfast"
          "gitignore"
          "isodate"
          "kubectx"
          "kubectl"
          "terraform"
          "tmux"
        ];
      };
      plugins = [
        {
          name = "zsh-autosuggestions";
          file = "zsh-autosuggestions.plugin.zsh";
          src = builtins.fetchGit {
            url = "https://github.com/zsh-users/zsh-autosuggestions";
            rev = "a411ef3e0992d4839f0732ebeb9823024afaaaa8";
          };
        }
        {
          name = "zsh-system-clipboard";
          file = "zsh-system-clipboard.plugin.zsh";
          src = builtins.fetchGit {
            url = "https://github.com/kutsan/zsh-system-clipboard";
            rev = "cc5089a2c97ee50d06ecf0439a9760ccda4c9413";
          };
        }
      ];
    };

    fzf.enable = true;

    tmux.enable = true;

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
