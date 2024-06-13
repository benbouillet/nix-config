{pkgs, config, lib, ...}: {
  # add home-manager user settings here
  home.packages = with pkgs; [
    git
    tree
    zsh-vi-mode
    nerdfonts
    ripgrep
    obsidian
  ];
  home.stateVersion = "23.11";

  home.file.".hushlogin" = {
    text = "";
  };

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

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    fzf.enable = true;

    tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "screen-256color";
      mouse = true;
      keyMode = "vi";
      baseIndex = 1;
      plugins = with pkgs; [
        tmuxPlugins.yank
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.urlview
        tmuxPlugins.tmux-thumbs
        tmuxPlugins.tmux-fzf
        tmuxPlugins.sessionist
        tmuxPlugins.pain-control
        tmuxPlugins.nord
        tmuxPlugins.resurrect
        tmuxPlugins.continuum
      ];
      extraConfig = ''
      set-option -ga terminal-overrides ",xterm-256color:RGB"
      '';
    };

    git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        user.email = "15980664+benbouillet@users.noreply.github.com";
        user.name = "Ben Bouillet";
      };
    };

    nixvim = {
      enable = true;
      defaultEditor = true;
      enableMan = true;
      colorschemes.nord = {
        enable = true;
    
        settings = {
          enable_sidebar_background = true;
	  borders = true;
	  contrast = true;
        };
        
      };
      opts = {
        number = true;
        shiftwidth = 2;
        relativenumber = true;
      };
      plugins = {
        lualine.enable = true;
        treesitter.enable = true;
        telescope.enable = true;
        nvim-tree.enable = true;
        bufferline.enable = true;
        barbecue.enable = true;
        which-key.enable = true;
        cmp.enable = true;
        cmp-buffer.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-path.enable = true;
        lsp = {
          enable = true;
          servers = {
            tsserver.enable = true;
            lua-ls.enable = true;
            pyright.enable = true;
          };
        };
      };
    };
  };
}
