{
  programs.nixvim = {
    diagnostic.settings.virtual_text = true;

    plugins = {
      lsp = {
        enable = true;

        inlayHints = true;

        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate in diagnostics
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            gD = "references";
            gt = "type_definition";
            gi = "implementation";
            K = "hover";
            "<F2>" = "rename";
          };
        };

        servers = {
          bashls.enable = true;
          jsonls.enable = true;
          jqls.enable = true;
          gopls.enable = true;
          pylsp = {
            enable = true;
            extraOptions = {
              before_init.__raw = ''
                function(_, config)
                  if not config.root_dir then
                    return
                  end

                  local python = config.root_dir .. "/.venv/bin/python"

                  if vim.fn.executable(python) == 1 then
                    config.settings = config.settings or {}
                    config.settings.pylsp = config.settings.pylsp or {}
                    config.settings.pylsp.plugins = config.settings.pylsp.plugins or {}
                    config.settings.pylsp.plugins.jedi = config.settings.pylsp.plugins.jedi or {}
                    config.settings.pylsp.plugins.jedi.environment = python
                  end
                end
              '';
            };
          };
          nixd = {
            enable = true;
            settings = {
              nixpkgs.expr = "import <nixpkgs> { }";
              formatting.command = [ "nixfmt" ];
              options = {
                nixos.expr = ''(builtins.getFlake "/home/ben/dev/benbouillet/nix-config").nixosConfigurations.obiwan.options'';
                home_manager.expr = ''(builtins.getFlake "/home/ben/dev/benbouillet/nix-config").nixosConfigurations.obiwan.options.home-manager.users.type.getSubOptions [ ]'';
              };
            };
          };
          terraformls.enable = true;
          dockerls.enable = true;
          helm_ls.enable = true;
        };
      };
    };
  };
}
