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
    (python314.withPackages (
      ps: with ps; [
        ipython
        pyperclip
      ]
    ))
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

  home.file.".ipython/profile_default/ipython_config.py".text = ''
    from IPython.terminal.interactiveshell import TerminalInteractiveShell
    from prompt_toolkit.clipboard.pyperclip import PyperclipClipboard

    init_prompt_toolkit_cli = TerminalInteractiveShell.init_prompt_toolkit_cli

    def with_system_clipboard(self):
      init_prompt_toolkit_cli(self)
      if self.pt_app:
        self.pt_app.clipboard = PyperclipClipboard()

    TerminalInteractiveShell.init_prompt_toolkit_cli = with_system_clipboard

    c.TerminalInteractiveShell.editing_mode = 'vi'
  '';

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
