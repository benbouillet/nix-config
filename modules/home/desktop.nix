{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    obsidian
    spotify
    whatsie
    steam-unwrapped
    discord
    keepassxc
  ];

  programs = {
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installVimSyntax = true;
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
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
