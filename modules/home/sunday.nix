{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # Networking
    sshuttle

    # Cloud
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])

    # Notetaking
    notion-app-enhanced

    # Messaging
    slack
    postman
    dbeaver-bin
  ];

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
  };
}
