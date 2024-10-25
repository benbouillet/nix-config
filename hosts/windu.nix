{ pkgs, ... }:

{
  pkgs = [
    # pkgs.docker
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs.kubectl
    pkgs.kubectx
    pkgs.sshuttle
    pkgs.tenv
    pkgs.k9s
    # pkgs.podman
    # pkgs.podman-desktop
    # pkgs.podman-tui
    pkgs.tenv
    pkgs.tailscale
    pkgs.coreutils
    pkgs.argocd
    pkgs.yarn
    pkgs.typescript
    pkgs.nodejs_20
    pkgs.corepack
    pkgs.htop
    pkgs.cmctl
    pkgs.bat
    pkgs.istioctl
    pkgs.pre-commit
    pkgs.terraform-docs
    pkgs.tflint
    pkgs.kubernetes-helm
  ];

  casks = [
    "google-chrome"
    "notion"
    "obsidian"
    "slack"
    "spotify"
    "whatsapp"
    "postman"
    "orbstack"
    "tailscale"
    "dbeaver-community"
  ];
}
