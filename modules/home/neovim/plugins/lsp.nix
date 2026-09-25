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
                function(params, config)
                  local root_dir = config.root_dir

                  if not root_dir then
                    return
                  end

                  local python = root_dir .. "/.venv/bin/python"

                  if vim.fn.executable(python) == 1 then
                    params.initializationOptions = params.initializationOptions or {}
                    params.initializationOptions.pylsp = params.initializationOptions.pylsp or {}
                    params.initializationOptions.pylsp.plugins = params.initializationOptions.pylsp.plugins or {}
                    params.initializationOptions.pylsp.plugins.jedi = params.initializationOptions.pylsp.plugins.jedi or {}
                    params.initializationOptions.pylsp.plugins.jedi.environment = python
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
