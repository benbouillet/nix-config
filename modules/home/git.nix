{
  username,
  ...
}:
let
  personal_repo = "benbouillet";
  git_email = "15980664+benbouillet@users.noreply.github.com";
  git_name = "Ben Bouillet";
in {
  home.file."dev/${personal_repo}/.keep" = {
    text = "";
  };

  programs.git = {
    enable = true;
    includes =  [
      {
        condition = "gitdir:/home/${username}/dev/${personal_repo}/";
        contents = {
          user = {
            email = git_email;
            name = git_name;
            signingKey = "/home/${username}/.ssh/id_ed25519_sk_git_signing";
          };
          gpg = {
            format = "ssh";
          };
          commit.gpgsign = true;
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
}
