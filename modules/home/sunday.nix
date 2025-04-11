{
  pkgs,
  username,
  ...
}:
let
  git_email = "ben.bouillet@sundayapp.com";
  git_name = "Ben Bouillet";
in {
  home = {
    file."dev/sundayapp/.keep" = {
      text = "";
    };

    packages = with pkgs; [
      # Networking
      sshuttle

      # Cloud
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      awscli2

      # Notetaking
      notion-app-enhanced

      # Messaging
      slack
      postman
      dbeaver-bin
    ];
  };

  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      extensions = [
        "bgnkhhnnamicmpeenaelnjfhikgbkllg" # adguard
        "fdjamakpfbbddfjaooikfcpapjohcfmg" # dashlane
        "lejiafennghcpgmbpiodgofeklkpahoe" # Custom UserAgent String
      ];
    };
    git = {
      enable = true;
      includes =  [
        {
          condition = "gitdir:/home/${username}/dev/sundayapp/";
          contents = {
            user = {
              email = git_email;
              name = git_name;
            };
            commit.gpgsign = true;
          };
        }
      ];
    };
  };
}
