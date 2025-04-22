{
  config,
  lib,
  ...
}:
{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps =
      let
        normal =
          lib.mapAttrsToList
            (key: action: {
              mode = "n";
              inherit action key;
            })
            {
              "<Space>" = "<NOP>";

              # Toggle Nvim tree
              "<leader>e" = ":NvimTreeToggle<CR>";

              # Esc to clear search results
              "<esc>" = ":noh<CR>";

              # fix Y behaviour
              Y = "y$";

              # back and fourth between the two most recent files
              "<C-c>" = ":b#<CR>";

              # close by Ctrl+x
              "<C-x>" = ":close<CR>";

              # navigate to left/right window
              "<C-k>" = "<C-w><up>";
              "<C-j>" = "<C-w><down>";
              "<C-h>" = "<C-w><left>";
              "<C-l>" = "<C-w><right>";

              # Press 'H', 'L' to jump to start/end of a line (first/last character)
              L = "$";
              H = "^";

              # resize with arrows
              "<M-k>" = ":resize -2<CR>";
              "<M-j>" = ":resize +2<CR>";
              "<M-h>" = ":vertical resize +2<CR>";
              "<M-l>" = ":vertical resize -2<CR>";

              # Toggle Diagnostic Floating window
              "gl" = "<cmd>lua vim.diagnostic.open_float()<CR>";
            };
        visual =
          lib.mapAttrsToList
            (key: action: {
              mode = "v";
              inherit action key;
            })
            {
              # better indenting
              ">" = ">gv";
              "<" = "<gv";
              "<TAB>" = ">gv";
              "<S-TAB>" = "<gv";

              # move selected line / block of text in visual mode
              "K" = ":m '<-2<CR>gv=gv";
              "J" = ":m '>+1<CR>gv=gv";

              # sort
              "<leader>s" = ":sort<CR>";
            };
      in
      config.lib.nixvim.keymaps.mkKeymaps { options.silent = true; } (normal ++ visual);
  };
}
