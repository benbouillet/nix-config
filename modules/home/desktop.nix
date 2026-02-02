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
    opencloud-desktop
  ];

  programs = {
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installVimSyntax = true;
      settings = {
        font-size = 12;
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
        Security = {
          LockDatabaseIdle = true;
          LockDatabaseIdleSeconds = 600;
          MinimizeOnCopy = true;
        };
        PasswordGenerator = {
          AdvancedMode = true;
          LowerCase = true;
          UpperCase = true;
          Numbers = true;
          Logograms = false;
          EASCII = false;
          Dashes = true;
          Length = 32;
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
