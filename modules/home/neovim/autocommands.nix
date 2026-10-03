{
  programs.nixvim.autoCmd = [
    # Vertically center document when entering insert mode
    {
      event = "InsertEnter";
      command = "norm zz";
    }

    # Open help in a vertical split
    {
      event = "FileType";
      pattern = "help";
      command = "wincmd L";
    }

    # Enable spellcheck for some filetypes
    {
      event = "FileType";
      pattern = [
        "markdown"
      ];
      command = "setlocal spell spelllang=en";
    }

    # Format on save via LSP
    {
      event = "BufWritePre";
      callback.__raw = ''
        function(args)
          if vim.bo[args.buf].filetype == "python" then
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf, name = "ruff" })) do
              local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
              params.textDocument = vim.lsp.util.make_text_document_params(args.buf)
              params.context = {
                only = { "source.organizeImports.ruff" },
                diagnostics = {},
              }

              local response = client:request_sync("textDocument/codeAction", params, 1000, args.buf)
              if response and response.result then
                for _, action in ipairs(response.result) do
                  local resolved_action = action
                  if
                    not action.edit
                    and action.data ~= nil
                    and action.command == nil
                  then
                    local resolve_response = client:request_sync(
                      "codeAction/resolve",
                      action,
                      1000,
                      args.buf
                    )
                    if resolve_response and resolve_response.result then
                      resolved_action = resolve_response.result
                    end
                  end

                  if resolved_action.edit then
                    vim.lsp.util.apply_workspace_edit(resolved_action.edit, client.offset_encoding)
                  end
                end
              end
            end
          end

          vim.lsp.buf.format({ async = false, bufnr = args.buf })
        end
      '';
    }
  ];
}
