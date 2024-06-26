{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    sessionVariables = {
      LC_ALL="en_US.UTF-8";
      LANG="en_US.UTF-8";
      EDITOR="nvim";
      COMPLETION_WAITING_DOTS="true";
    };
    initExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "vi-mode"
        "git"
        "docker"
        "docker-compose"
        "dotenv"
        "aws"
        "gcloud"
        "colored-man-pages"
        "fzf"
        "gitfast"
        "gitignore"
        "isodate"
        "kubectx"
        "kubectl"
        "terraform"
        "tmux"
      ];
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        file = "zsh-autosuggestions.plugin.zsh";
        src = builtins.fetchGit {
          url = "https://github.com/zsh-users/zsh-autosuggestions";
          rev = "a411ef3e0992d4839f0732ebeb9823024afaaaa8";
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


  home.shellAliases = {
    k = "kubectl";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
}
