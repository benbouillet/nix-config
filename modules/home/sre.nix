{
  config,
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
    helmfile
    helm-ls
    helmsman
    kubernetes-helm
    kubernetes-helmPlugins.helm-cm-push
    kubernetes-helmPlugins.helm-diff
    kubernetes-helmPlugins.helm-s3
    kubernetes-helmPlugins.helm-git
    kubernetes-helmPlugins.helm-secrets
    stern
    kubectl-klock
    kubectl-ktop
    kubectl-tree

    # Automation
    python314
    gomplate

    # observability
    datadog-pup

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

    # documentation
    mdwatch

    # Programming
    go
    python3Packages.python-lsp-server

    (import ../../scripts/aws-creds-exporter.nix { inherit pkgs; })
    (import ../../scripts/github-commits.nix { inherit pkgs; })
  ];

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      sessionVariables = {
        TENV_AUTO_INSTALL = "true";
        HELM_PLUGINS = "${config.xdg.dataHome}/helm/plugins:${pkgs.kubernetes-helmPlugins.helm-diff}";
      };
      shellAliases = {
        tg = "terragrunt run --tf-path terraform --parallelism=5 --";
        ghpr = "gh pr review -a";
      };
      initContent = ''
        gh-commits() {
          github-commits "$@"
        }
      '';
    };
  };
}
