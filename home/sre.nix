{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # K8s & Containerization
    kubectl
    kubectx
    k9s
    argocd
    cmctl
    istioctl
    kubernetes-helm

    # IaC
    tenv
    terraform-docs
    tflint

    # Networking
    sshuttle

    # DevOps
    pre-commit

    # Cloud
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])

    # Notetaking
    notion-app-enhanced
    obsidian

    # Web
    ungoogled-chromium

    # Messaging
    slack
    postman
    dbeaver-bin
  ];

  services = {
    podman = {
      enable = true;
    };
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
