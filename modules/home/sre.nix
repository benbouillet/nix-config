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

    # DevOps
    pre-commit
  ];

  services = {
    podman.enable = true;
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      sessionVariables = {
        TENV_AUTO_INSTALL="true";
      };
    };
  };
}
