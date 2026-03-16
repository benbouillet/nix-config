{
  pkgs,
  opencode-augment-auth,
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

    (import ../../scripts/aws-creds-exporter.nix { inherit pkgs; })
  ];

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      sessionVariables = {
        TENV_AUTO_INSTALL = "true";
      };
      shellAliases = {
        tg = "terragrunt run --tf-path terraform --parallelism=5 --";
      };
    };
    opencode = {
      enable = true;
      # agents = {
      #   code-reviewer = ''
      #     # Code Reviewer Agent
      #
      #     You are a senior software engineer specializing in code reviews.
      #     Focus on code quality, security, and maintainability.
      #
      #     ## Guidelines
      #     - Review for potential bugs and edge cases
      #     - Check for security vulnerabilities
      #     - Ensure code follows best practices
      #     - Suggest improvements for readability and performance
      #   '';
      #   documentation = ./agents/documentation.md;
      # };
      commands = {
        gc = ''
          Propose a comment for the current staged changes about to be committed.
          Usage: /comment
        '';
      };
      enableMcpIntegration = true;
      settings = {
        autoshare = false;
        autoupdate = true;
        plugin = [
          "${opencode-augment-auth}"
        ];
        model = "augment/claude-sonnet-4-5";
      };
      rules = ''
        ## Environment
        - Stack: Kubernetes (kubectl, k9s, argocd, istioctl), Terraform (via tenv), AWS, Podman
        - Cloud: GCP (Cloud SQL, BigQuery) + AWS

        ## ⛔ Never execute apply-like actions
        You are NEVER allowed to run any command that modifies infrastructure or cluster state.
        This includes but is not limited to:
        - `kubectl apply`, `kubectl delete`, `kubectl patch`, `kubectl rollout restart`, `kubectl scale`
        - `terraform apply`, `terraform destroy`, `terragrunt apply`, `terragrunt destroy`
        - `argocd app sync`, `argocd app delete`
        - `helm install`, `helm upgrade`, `helm uninstall`
        - `nixos-rebuild switch`

        Always stop at the plan/diff/dry-run stage and let the user decide and execute.

        ## Kubernetes
        - Always use `--dry-run=client` before suggesting any change
        - Always confirm the target context first (`kubectl config current-context`)
        - Prefer `kubectl diff` to show what would change
        - Use `kubectx` to switch contexts, never modify kubeconfig manually

        ## Terraform / IaC
        - Always run `terraform plan` and stop there — never proceed to apply
        - Use `tenv` to manage Terraform versions — do not install terraform globally
        - Use `tflint` and `trivy` to validate before proposing changes
        - Prefer `terragrunt` via the `tg` alias for multi-module operations

        ## AWS
        - AWS credentials are short-lived, loaded via `aws-creds-exporter`
        - Never hardcode AWS credentials or suggest storing them in plain files

        ## Security
        - Never print secrets, tokens, or credentials in output
        - Treat any file under `~/.config/` or `~/.aws/` as sensitive

        ## General SRE
        - Prefer non-destructive operations; always suggest rollback steps
        - When in doubt, observe before acting (`stern`, `k9s`, `kubectl logs`)
        - Suggest `trivy` scans when working with container images
      '';

    };
    mcp = {
      enable = true;
      servers = {
        github = {
          url = "https://api.githubcopilot.com/mcp/";
          type = "http";
        };
        auggie = {
          type = "remote";
          url = "https://api.augmentcode.com/mcp";
          enabled = true;
        };
      };
    };
  };
}
