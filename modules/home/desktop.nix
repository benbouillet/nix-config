{
  pkgs,
  username,
  ...
}:
{
  home.packages = with pkgs; [
    obsidian
    spotify
    altus
    discord
    keepassxc
    speedcrunch
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
    taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;
      dataLocation = "/home/${username}/sync/toolbox/taskwarrior";
    };
  };
}
