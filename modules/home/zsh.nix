{
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      strategy = [ "history" ];
    };

    history = {
      save = 100000;
      append = true;
      expireDuplicatesFirst = true;
      extended = true;
      share = true;
    };

    shellAliases = {
      ls = "eza";
      cd = "z";
    };

    syntaxHighlighting.enable = true;

    sessionVariables = {
      LC_ALL="en_US.UTF-8";
      LANG="en_US.UTF-8";
      EDITOR="nvim";
      COMPLETION_WAITING_DOTS="true";
      ZSH_SYSTEM_CLIPBOARD_USE_WL_CLIPBOARD="";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "vi-mode"
        "git"
        "gcloud"
        "colored-man-pages"
        "gitfast"
        "kubectl"
        "terraform"
        "tmux"
        "fzf"
      ];
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        file = "zsh-autosuggestions.plugin.zsh";
        src = builtins.fetchGit {
          url = "https://github.com/zsh-users/zsh-autosuggestions";
          rev = "v0.7.1";
          sha256 = "02p5wq93i12w41cw6b00hcgmkc8k80aqzcy51qfzi0armxig555y";
        };
      }
      {
        name = "zsh-system-clipboard";
        file = "zsh-system-clipboard.plugin.zsh";
        src = builtins.fetchGit {
          url = "https://github.com/kutsan/zsh-system-clipboard";
          rev = "v0.8.0";
          sha256 = "08ndsqgkz397d9zaa3in40rp9y3y6jd7x55kq16hk5cxdcjc8r2m";
        };
      }
    ];
  };
}
