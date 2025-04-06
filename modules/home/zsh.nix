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
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.1";
          hash = "sha256-vpTyYq9ZgfgdDsWzjxVAE7FZH4MALMNZIFyEOBLm5Qo=";
        };
      }
    ];
  };
}
