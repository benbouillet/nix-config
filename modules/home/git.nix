{
  username,
  ...
}:
let
  personal_repo = "benbouillet";
  git_email = "15980664+benbouillet@users.noreply.github.com";
  git_name = "Ben Bouillet";
in
{
  home.file."dev/${personal_repo}/.keep" = {
    text = "";
  };

  programs = {
    git = {
      enable = true;
      signing = {
        format = "ssh";
        key = "/home/${username}/.ssh/id_ed25519_sk_git_signing";
        signByDefault = true;
      };
      includes = [
        {
          condition = "gitdir:/home/${username}/dev/${personal_repo}/";
          contents = {
            user = {
              email = git_email;
              name = git_name;
              signingKey = "/home/${username}/.ssh/id_ed25519_sk_git_signing";
            };
          };
        }
      ];
      settings = {
        init.defaultBranch = "main";
        color.ui = "true";
        pull.rebase = "true";
        push.autoSetupRemote = "true";
      };
    };
    zsh = {
      shellAliases = {
        "git-ssh-auth" = "ssh-add -t 8h ~/.ssh/id_ed25519_git";
      };
    };
    gh-dash.enable = true;
  };
}
