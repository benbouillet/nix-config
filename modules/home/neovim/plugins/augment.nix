{
  pkgs,
  lib,
  username,
  ...
}:
{
  home.packages = with pkgs; [
    nodejs_25
  ];

  programs.nixvim.extraPlugins = [
    pkgs.vimPlugins.augment-vim
  ];

  programs.nixvim.extraConfigLua = lib.mkAfter ''
    vim.g.augment_workspace_folders = {"/home/${username}/dev/sundayapp"}
  '';

  programs.nixvim.keymaps = [
    {
      mode = [ "n" "v" ];
      key = "<leader>ac";
      action = "<cmd>Augment chat<CR>";
    }
    {
      mode = [ "n" ];
      key = "<leader>an";
      action = "<cmd>Augment chat-new<CR>";
    }
    {
      mode = [ "n" ];
      key = "<leader>at";
      action = "<cmd>Augment chat-toggle<CR>";
    }
    {
      mode = "n";
      key = "<leader>ae";
      action.__raw = ''
        function()
          -- If unset, treat as "enabled" (false).
          local cur = vim.g.augment_disable_completions
          if cur == nil then cur = false end

          vim.g.augment_disable_completions = not cur

          local state = vim.g.augment_disable_completions and "OFF" or "ON"
          vim.notify("Augment completions: " .. state)
        end
      '';
      options = { noremap = true; silent = true; desc = "Toggle Augment completions"; };
    }
  ];
}
