---
name: github-cli
description: Use GitHub CLI (`gh`) for repository, issue, pull-request, Actions, search, API, and `gh skill` management tasks. Use when a user asks to inspect or work with GitHub from the command line.
---

# GitHub CLI

Use `gh` for GitHub tasks; consult the [GitHub CLI manual](https://cli.github.com/manual/) for command options.

## Prerequisites and safety

- Require `gh` to be installed and authenticated. Check with `gh auth status`; do not expose credentials. For noninteractive automation, set `GH_TOKEN` for github.com or ghe.com, or `GH_ENTERPRISE_TOKEN` for GitHub Enterprise Server (GHES), via the environment or a secret manager; never inline token values in commands or logs, and do not use insecure credential storage. See [authentication](https://cli.github.com/manual/gh_auth_status) and [environment variables](https://cli.github.com/manual/gh_help_environment).
- `gh skill` (also `gh skills`) is in preview and may change; use a current `gh` version and check its help if a command or flag is unavailable. See [`gh skill`](https://cli.github.com/manual/gh_skill).
- Identify the target host and repository before acting. Prefer explicit `--repo HOST/OWNER/REPO`; otherwise verify the current repository with `gh repo view` before use. Never infer a host or repository from context when it is ambiguous. See [`gh repo`](https://cli.github.com/manual/gh_repo) and [`GH_REPO`](https://cli.github.com/manual/gh_help_environment).
- Inspect and preview before changing state. Ask the user to confirm immediately before any state-changing action: create, edit, close, reopen, merge, review, comment, label, assign; rerun or cancel a workflow; release, repository administration or settings; `gh api` mutations; or skill install, update, or publish. Do not treat a previous general request as confirmation for a specific consequential change.
- Never print tokens, run `gh auth token --show-token`, or place token values in commands, arguments, output, or logs. See [`gh auth token`](https://cli.github.com/manual/gh_auth_token).

## Read-only recipes

Use the actual confirmed host/owner/repo in place of `HOST/OWNER/REPO`.

```bash
# Repository details and current authentication
gh repo view HOST/OWNER/REPO
gh auth status

# Issues
gh issue list --repo HOST/OWNER/REPO --state open
gh issue view 123 --repo HOST/OWNER/REPO

# Pull requests, checks, and diff
gh pr list --repo HOST/OWNER/REPO --state open
gh pr view 123 --repo HOST/OWNER/REPO
gh pr checks 123 --repo HOST/OWNER/REPO
gh pr diff 123 --repo HOST/OWNER/REPO

# Actions runs: inspect and follow a run
gh run list --repo HOST/OWNER/REPO
gh run view 123456 --repo HOST/OWNER/REPO
gh run watch 123456 --repo HOST/OWNER/REPO

# Search repositories, issues/PRs, or code
gh search repos 'query'
gh search issues 'query' --repo HOST/OWNER/REPO
gh search prs 'query' --repo HOST/OWNER/REPO
gh search code 'query' --repo HOST/OWNER/REPO
```

See the manuals for [`issue`](https://cli.github.com/manual/gh_issue), [`pr`](https://cli.github.com/manual/gh_pr), [`pr checks`](https://cli.github.com/manual/gh_pr_checks), [`run`](https://cli.github.com/manual/gh_run), and [`search`](https://cli.github.com/manual/gh_search). `gh run watch` observes a run; rerunning or cancelling it changes state and requires confirmation ([`gh run rerun`](https://cli.github.com/manual/gh_run_rerun), [`gh run cancel`](https://cli.github.com/manual/gh_run_cancel)).

Submit a review only after confirming the exact review outcome with the user:

```bash
gh pr review 123 --repo HOST/OWNER/REPO --approve
```

The review command and its review modes are documented in [`gh pr review`](https://cli.github.com/manual/gh_pr_review).

## Formatting and API

For commands supporting JSON, request only needed fields with `--json`; filter with `--jq` or format with `--template`:

```bash
gh pr list --repo HOST/OWNER/REPO --json number,title,state
gh issue list --repo HOST/OWNER/REPO --json number,title --jq '.[] | [.number, .title]'
gh repo view HOST/OWNER/REPO --json nameWithOwner,url --template '{{.nameWithOwner}} {{.url}}'
```

`--jq` uses jq syntax and `--template` uses Go templates; `--jq` and `--template` require `--json` and its field list. See [formatting](https://cli.github.com/manual/gh_help_formatting).

Use `gh api` when a first-class command does not expose the needed endpoint. For reads, use GET explicitly whenever supplying fields: fields otherwise switch the default method from GET to POST. Use `--paginate` for paginated collection results where appropriate. For enterprise, set the confirmed host with `--hostname`.

```bash
# Read-only GET, with explicit method despite query parameter
gh api --hostname HOST -X GET repos/OWNER/REPO/issues -f state=open --paginate

# Mutation example only after user confirms the exact target and change
gh api --hostname HOST -X POST repos/OWNER/REPO/issues -f title='Title' -f body='Description'
```

The API method and pagination behavior are documented in [`gh api`](https://cli.github.com/manual/gh_api). Treat any non-GET request as a mutation and get confirmation first.

## Agent skill management

Search, preview, and list are for discovery; preview reads remote skill content. Install, update, and publish change local or remote state and require confirmation. `gh skill publish --dry-run` validates only; do not publish without confirmation. See [`gh skill`](https://cli.github.com/manual/gh_skill), [`search`](https://cli.github.com/manual/gh_skill_search), [`preview`](https://cli.github.com/manual/gh_skill_preview), [`list`](https://cli.github.com/manual/gh_skill_list), [`install`](https://cli.github.com/manual/gh_skill_install), [`update`](https://cli.github.com/manual/gh_skill_update), and [`publish`](https://cli.github.com/manual/gh_skill_publish).

```bash
# Read-only discovery and preview
gh skill search 'query'
gh skill preview OWNER/REPO skill-name
gh skill list
gh skill update --dry-run

# Mutating; first obtain user confirmation
gh skill install OWNER/REPO skill-name
gh skill update skill-name

# Validation only; do not run publish itself without confirmation
gh skill publish --dry-run
```

The skill file format and directory/name requirements are defined by the [Agent Skills specification](https://agentskills.io/specification).
