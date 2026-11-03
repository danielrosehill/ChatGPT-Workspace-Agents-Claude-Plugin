# ChatGPT-Workspace-Agents-Claude-Plugin: agent notes

Public Claude Code plugin. Release tier: **small** (`v1.0`, `v1.1`, …).

- `references/builder-mechanics.md` is the single place for selectors and UI facts. When the
  ChatGPT builder changes, fix it there with a "verified YYYY-MM-DD" note; skills just point to it.
- Keep it generic: no workspace IDs, agent IDs, names, internal hostnames or personal details.
  (The author's private fork holds those.)
- Bump `.claude-plugin/plugin.json` version with each release.
