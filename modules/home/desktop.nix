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
    speedcrunch
    vlc
    digikam
    moonlight-qt
    carbon-now-cli
    swappy
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
    keepassxc = {
      enable = true;
      settings = {
        Browser.Enabled = true;
        GUI = {
          AdvancedSettings = true;
          ApplicationTheme = "dark";
          CompactMode = true;
          HidePasswords = true;
          AutoSaveOnExit = true;
        };
        Config = {
          Security_LockDatabaseIdle = true;
          Security_LockDatabaseIdleSeconds = 600;
          MinimizeOnCopy = true;
        };
        SSHAgent.Enabled = false;
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
