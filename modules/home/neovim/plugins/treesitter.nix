{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;

      # nixvimInjections = true;

      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
      folding.enable = true;
    };

    # hmts disabled — nil crash on TSNode:parent(), see https://github.com/calops/hmts.nvim/pull/38
    hmts.enable = false;
  };
}
