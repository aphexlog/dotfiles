# Pull Request Style

Create pull requests with a clear, structured format.

## Title

Use conventional commit style for PR titles:

`type(scope): description`

- Types: feat, fix, chore, docs, refactor, test, style, ci, perf, revert
- Scope: area of change (zed, nvim, tmux, starship, wezterm, zsh, github, opencode, etc.)
- Description: lowercase, imperative mood, no trailing period, under 72 chars

## Body Template

Use this template for every PR body:

```md
## Summary
- <what changed and why>
- <key design choice or tradeoff>

## Changes
- <grouped list of notable code/config changes>
- <mention any migrations, renames, or removals>

## Validation
- <tests/checks run>
- <manual verification steps>

## Risks
- <known risk areas>
- <rollback or mitigation plan>

## Notes
- <follow-ups, TODOs, or out-of-scope items>
```

## Rules

- Keep bullets concise and specific; avoid vague summaries.
- Focus on why and impact, not only a raw file list.
- Include exact commands used for validation when relevant.
- Call out breaking changes explicitly under `## Risks`.
- If no item applies to a section, write `- none`.
