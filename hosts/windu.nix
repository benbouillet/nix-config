{ pkgs, ... }:

{
  pkgs = [
    pkgs.docker
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs.kubectl
    pkgs.kubectx
    pkgs.sshuttle
    pkgs.tenv
    pkgs.k9s
    pkgs.podman
    # pkgs.podman-desktop
    pkgs.podman-tui
    pkgs.tenv
  ];

  casks = [
    "google-chrome"
    "notion"
    "obsidian"
    "slack"
    "spotify"
    "whatsapp"
  ];
}
