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
    stern
    kubectl-klock
    kubectl-ktop
    kubectl-tree

    # IaC
    tenv
    terraform-docs
    tflint
    trivy

    # DevOps
    gh
    pre-commit
    podman-compose

    # network
    nmap
    inetutils
    masscan
    openssl

    # web
    jwt-cli

    # security
    yubikey-manager

    (import ../../scripts/aws-creds-exporter.nix {inherit pkgs; })
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
      shellAliases = {
        tg = "terragrunt";
      };
    };
  };
}
