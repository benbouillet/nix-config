---
name: github-commits
description: Generate a summary of GitHub commits from the past week. Use when the user asks for a weekly commit summary or review of recent work.
---

# GitHub Commits Summary Skill

This skill helps generate a comprehensive summary of GitHub commits from the past week across repositories in `~/dev/<org>/*` directories.

## Usage

To generate a weekly commit summary:

1. Run the `github-commits` command to analyze commits from the past 7 days
2. Optionally explore `~/dev/<org>/*` directories to get broader context on projects
3. Output the summary to a markdown file suitable for team review

## Key Features

- Summarizes commits from the past week (last 7 days)
- Groups commits by repository for easier navigation
- Highlights significant changes, bug fixes, and new features
- Optionally explores development directories for additional context
- Generates clean markdown output for team reviews

## How to Use

1. Simply invoke the `github-commits` command to generate a summary of recent work
2. For extended context, you can explore `~/dev/<org>/*` directories where org represents GitHub organizations or project groupings
3. The output will be saved to a markdown file for sharing with your team

## Example Output Format

The generated markdown file will include:
- Overall summary of changes
- Repository-specific sections with commit details
- Date ranges and statistics
- Links to specific commits when available

Use this skill whenever you need to prepare a weekly development summary for team review.