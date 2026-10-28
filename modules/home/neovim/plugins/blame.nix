{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>b";
        action = ":BlameToggle window<CR>";
        options.silent = true;
      }
    ];
    plugins.blame = {
      enable = true;
    };
  };
}
