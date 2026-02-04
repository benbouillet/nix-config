{
  imports = [
    ./barbar.nix
    ./blame.nix
    ./comment.nix
    ./lsp.nix
    ./lualine.nix
    ./motion.nix
    ./neo-tree.nix
    ./render-markdown.nix
    ./snacks.nix
    ./telescope.nix
    ./transparent.nix
    ./treesitter.nix
  ];

  programs.nixvim = {
    plugins = {
      # Lazy loading
      lz-n.enable = true;

      web-devicons.enable = true;

      which-key.enable = true;

      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "+";
          change.text = "~";
        };
      };

      nvim-autopairs = {
        enable = true;
        autoLoad = true;
      };

      smart-splits = {
        enable = true;
        autoLoad = true;
      };

      colorizer = {
        enable = true;
        settings.user_default_options.names = false;
      };

      indent-blankline = {
        enable = true;
        autoLoad = true;
      };

      tmux-navigator.enable = true;

      trim = {
        enable = true;
        settings = {
          highlight = true;
          ft_blocklist = [
            "checkhealth"
            "floaterm"
            "lspinfo"
            "neo-tree"
            "TelescopePrompt"
          ];
        };
      };
    };
  };
}
