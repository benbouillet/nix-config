---
description: Generate a weekly summary of GitHub commits for team review
agent: zeus
---

Generate a comprehensive summary of all GitHub commits for organization $1 from the past week. Follow these steps:

1. Use skill `github-commits` to fetch my commits for the past 7 days
2. Explore each commit diff and make a summary of each one of them
2. For non-trivial diffs, explore `~/dev/$1/*` directories to get context on active projects
3. Create a structured summary that includes:
   - Overall statistics (total commits, repositories affected)
   - Per-repository breakdown with notable changes
   - Highlight any significant features, bug fixes, or refactors
4. Format the output as clean markdown suitable for team review
5. Save the summary to a .md file with a timestamp in the filename

Focus on making the summary actionable and informative for team members who need a quick overview of recent development work.
