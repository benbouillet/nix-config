---
name: github-commits
description: Generate a summary of GitHub commits from the past week. Use when the user asks for a weekly commit summary or review of recent work.
---

# GitHub Commits Summary Skill

Generates a markdown summary of the user's commits across a GitHub org in the last 7 days.

## Command

`github-commits` is available on `PATH`. It queries the GitHub API for commits by the user in a given org.

### Required flags

| Flag | Description |
|---|---|
| `-o ORG` | GitHub organization (required) |
| `-d DAYS` | Days to look back (default: 7) |
| `-j` | JSON output for programmatic consumption |
| `-s SPEC` | Sort order: e.g. `repo:asc` to group by repo |

### Pitfalls (learned from real use)

- **Large orgs timeout.** The command checks every repo sequentially. For orgs with 400+ repos, the default 60s timeout is too short. Always use `-j` and set a generous timeout (at least 300s) when invoking via the bash tool.
- **Output too large for stdout.** With many commits across many repos, JSON output can be thousands of lines. Pipe to a temp file, then read/process it from there:
  ```
  github-commits -o myorg -j > /tmp/github-commits.json
  ```
- **Non-commit entries in JSON.** The JSON array may contain entries that are not commits. Use `jq` to filter them: `jq '.[] | select(.sha)'`.

## Workflow

1. Determine the org. If the user didn't specify one, ask. Common orgs for this user: `sundayapp`.
2. Determine output path. Default: `<workspace-root>/weekly-commits-<org>-<YYYY-MM-DD>.md`. Ask the user if they want a specific path.
3. Run `github-commits -o <org> -j` with a 300s timeout, redirecting to a temp file.
4. Read the temp file. Filter with `jq '.[] | select(.sha)'` to remove any non-commit entries.
5. Group commits by repository. For each repo, list commits chronologically with:
   - Short SHA (first 7 chars)
   - Date (YYYY-MM-DD)
   - First line of commit message
6. Write the summary markdown file with this structure:

```markdown
# Weekly Commit Summary: <org>
**Period:** <start-date> — <end-date>
**Total commits:** <N> across <M> repositories

## <repo-name-1> (<N> commits)
- `<short-sha>` <date> — <first line of message>
- ...

## <repo-name-2> (<N> commits)
...
```

7. Report back to the user with the file path and a one-line summary (total commits, total repos).

## What NOT to do

- Do NOT explore `~/dev/<org>/*` directories — the command output is authoritative.
- Do NOT run without `-j` flag — plain text output is harder to parse programmatically.
- Do NOT try to guess the org — ask if unclear.
- Do NOT use a short timeout — use 300s minimum.