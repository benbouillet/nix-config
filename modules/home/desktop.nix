{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    obsidian
    spotify
    whatsie
    discord
    keepassxc
  ];

  programs = {
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installVimSyntax = true;
      settings = {
        font-size = 14;
      };
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    fastfetch = {
      enable = true;
    };
  };
}
