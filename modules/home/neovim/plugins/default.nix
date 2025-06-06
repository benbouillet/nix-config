{
  imports = [
    ./barbar.nix
    ./lualine.nix
    ./transparent.nix
    ./neo-tree.nix
    ./treesitter.nix
    ./telescope.nix
    ./lsp.nix
    ./comment.nix
    ./snacks.nix
    ./motion.nix
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
