{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.nixvim.homeManagerModules.default ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    enableMan = true;
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    clipboard.register = "unnamedplus";
    opts = {
      number = true;
      shiftwidth = 2;
      relativenumber = true;
      termguicolors = true;
    };
    plugins = {
      nvim-autopairs.enable = true;
      transparent = {
        enable = true;
        settings = {
          extra_groups = [
            "all"
            "TroubleNormal"
            "TroubleNormalNC"
            "TroubleCount"
            "TroubleFsCount"
            "TelescopeBorder"
            "DiagnosticSignError"
            "DiagnosticSignWarn"
            "DiagnosticSignWarn"
            "DiagnosticSignInfo"
            "DiagnosticSignHint"
          ];
          exclude_groups = [ "StatusLine" "CursorLine" ];
        };
      };
      lualine.enable = true;
      treesitter = {
        enable = true;
        settings.indent.enable = true;
      };
      web-devicons.enable = true;
      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
          ui-select.enable = true;
        };
        settings = {
          defaults = {
            wrap_results = true;
          };
        };
        keymaps = {
          "<leader>ff" = {
            action = "find_files";
            options = {
              desc = "Telescope Find Files";
            };
          };
          "<leader>fg" = {
            action = "live_grep";
            options = {
              desc = "Telescope Live Grep";
            };
          };
          "<leader>fb" = {
            action = "buffers";
            options = {
              desc = "Telescope Find Buffers";
            };
          };
          "<leader>fh" = {
            action = "help_tags";
            options = {
              desc = "Telescope Find Tags in Help";
            };
          };
          "<leader>fd" = {
            action = "diagnostics";
            options = {
              desc = "Telescope Diagnostics";
            };
          };
        };
      };
      nvim-tree.enable = true;
      bufferline.enable = true;
      barbecue.enable = true;
      which-key.enable = true;
      cmp = {
        enable = true;
        settings = {
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = false })";
            "<C-Space>" = ''
              vim.schedule_wrap(function(fallback)
                if cmp.visible() and has_words_before() then
                  cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                elseif require("luasnip").expandable() then
                  require("luasnip").expand()
                elseif require("luasnip").expand_or_jumpable() then
                  require("luasnip").expand_or_jump()
                else
                  fallback()
                end
              end)
            '';
          };
        };
      };
      cmp-buffer.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-path.enable = true;
      smart-splits.enable = true;
      indent-blankline.enable = true;
      typescript-tools.enable = true;
      commentary.enable = true;
      nix.enable = true;
      leap.enable = true;
      luasnip.enable = true;
      lsp = {
        enable = true;
        servers = {
          gopls.enable = true;
          lua_ls.enable = true;
          pyright.enable = true;
        };
      };
      tmux-navigator.enable = true;
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
      {
        action = ":NvimTreeToggle<CR>";
        key = "<leader>e";
        mode = "n";
      }
      {
        action = "<C-w><up>";
        key = "<C-k>";
        mode = "n";
      }
      {
        action = "<C-w><down>";
        key = "<C-j>";
        mode = "n";
      }
      {
        action = "<C-w><left>";
        key = "<C-h>";
        mode = "n";
      }
      {
        action = "<C-w><right>";
        key = "<C-l>";
        mode = "n";
      }
    ];
  };
}
