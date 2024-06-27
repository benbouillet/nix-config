{ pkgs, ... }:

{
  pkgs = [
    pkgs.docker
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs.kubectl
    pkgs.kubectx
    pkgs.sshuttle
  ];

  casks = [
    "google-chrome"
    "notion"
    "obsidian"
    "slack"
    "spotify"
  ];
}
