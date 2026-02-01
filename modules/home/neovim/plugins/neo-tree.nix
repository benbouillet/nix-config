{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = ":Neotree action=focus reveal toggle<CR>";
        options.silent = true;
      }
    ];

    plugins.neo-tree = {
      enable = true;

      settings = {
        window = {
          width = 30;
          auto_expand_width = true;
        };
        close_if_last_window = false;

        default_source = "filesystem";
        sources = [
          "filesystem"
          "buffers"
          "git_status"
        ];

        filesystem = {
          filtered_items = {
            visible = true;
            hide_dotfiles = false;
            hide_gitignored = true;
            never_show = [ ".git" ];
            always_show = [ ".github" ];
          };
        };
      };
    };
  };
}
