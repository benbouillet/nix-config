{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>m";
        action = ":RenderMarkdown toggle<CR>";
        options.silent = true;
      }
    ];

    plugins.render-markdown.enable = true;
  };
}
