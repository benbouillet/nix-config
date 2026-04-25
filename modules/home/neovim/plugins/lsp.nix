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
          pylsp.enable = true;
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
