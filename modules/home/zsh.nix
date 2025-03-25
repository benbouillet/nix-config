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
          rev = "e52ee8ca55bcc56a17c828767a3f98f22a68d4eb";
        };
      }
      {
        name = "zsh-system-clipboard";
        file = "zsh-system-clipboard.plugin.zsh";
        src = builtins.fetchGit {
          url = "https://github.com/kutsan/zsh-system-clipboard";
          rev = "cc5089a2c97ee50d06ecf0439a9760ccda4c9413";
        };
      }
    ];
  };
}
