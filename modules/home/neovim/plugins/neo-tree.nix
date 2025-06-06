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

      closeIfLastWindow = true;
      window = {
        width = 30;
        autoExpandWidth = true;
      };

      sources = [
        "filesystem"
        "buffers"
        "git_status"
      ];

      defaultSource = "filesystem";

      extraOptions = {
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
