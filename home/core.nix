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

    nixvim = {
      enable = true;
      defaultEditor = true;
      enableMan = true;
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };
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
	termguicolors = true;
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
      keymaps = [
        {
          action = "<NOP>";
          key = "<Space>";
          mode = "n";
        }
        {
          action = "y$";
          key = "Y";
          mode = "n";
        }
        {
          action = ":w<CR>";
          key = "<leader>S";
          mode = "n";
        }
      ];
    };

    nnn = {
      enable = true;
    };

  };
}
