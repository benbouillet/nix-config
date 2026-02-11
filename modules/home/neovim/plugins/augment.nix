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
  ];
}
