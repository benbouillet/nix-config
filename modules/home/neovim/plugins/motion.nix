{
  programs.nixvim = {
    plugins = {
      spider.enable = true;

      hop = {
        enable = true;
        autoLoad = true;
      };
    };

    keymaps = [
      {
        key = "f";
        action.__raw = ''
          function()
            require'hop'.hint_char1({
              direction = require'hop.hint'.HintDirection.AFTER_CURSOR,
              current_line_only = true
            })
          end
        '';
        options.remap = true;
      }
      {
        key = "F";
        action.__raw = ''
          function()
            require'hop'.hint_char1({
              direction = require'hop.hint'.HintDirection.BEFORE_CURSOR,
              current_line_only = true
            })
          end
        '';
        options.remap = true;
      }
      {
        key = "t";
        action.__raw = ''
          function()
            require'hop'.hint_char1({
              direction = require'hop.hint'.HintDirection.AFTER_CURSOR,
              current_line_only = true,
              hint_offset = -1
            })
          end
        '';
        options.remap = true;
      }
      {
        key = "T";
        action.__raw = ''
          function()
            require'hop'.hint_char1({
              direction = require'hop.hint'.HintDirection.BEFORE_CURSOR,
              current_line_only = true,
              hint_offset = 1
            })
          end
        '';
        options.remap = true;
      }
      {
        mode = "n";
        key = "<leader>h";
        action = "<cmd>HopWord<cr>";
      }
    ];
  };
}
