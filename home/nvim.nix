{ ... } : {
programs.nixvim = {
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
}
