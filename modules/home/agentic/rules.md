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
