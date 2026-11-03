# ChatGPT Workspace Agents: Claude Code plugin

A Claude Code plugin for building and managing **ChatGPT Workspace Agents** (the agent builder
in ChatGPT Business, Enterprise and Edu at `chatgpt.com/agents/studio`) from Claude Code.

> **Heads up: this drives a browser.** OpenAI has no public API for creating or editing
> workspace agents. The Workspace Agents API only *triggers runs* (checked 2026-11-03). So
> these skills automate the builder UI with Claude in Chrome or a Playwright-style browser MCP.
> It is not ideal and **it will break** when OpenAI changes the page. Each fact in
> `references/builder-mechanics.md` carries the date it was checked. The plugin is mostly useful
> as a map of the builder and a set of working techniques, so update the mechanics file when
> something drifts.

## Skills

| Skill | Does |
|---|---|
| `create-agent` | Name, instructions, files, skills, apps → a saved agent |
| `update-agent` | Replace instructions; add, replace or remove files and skills; add or remove apps; save |
| `inspect-agent` | Read-only dump of one agent |
| `list-agents` | Agents and `agt_` IDs from chatgpt.com/agents |
| `share-agent` | Private, link or directory access; invite people as Can chat / Can edit / Owner |

## Findings worth knowing (2026-11-03)

- **Skills: one per zip.** The builder's "Upload skill" accepts a `.zip` or folder holding exactly
  one Agent Skills folder (`SKILL.md` + files). A zip with several is rejected:
  *"Archive must contain exactly one skill"*.
- **Re-uploading a skill duplicates it.** Nothing is overwritten. To update a skill, remove the old one
  (open the skill → Remove skill), then upload the new one.
- **No file input to target.** The skill dialog creates its picker on click. A synthetic
  `drop` event carrying a `File` built from base64 works (`scripts/skill-drop-snippet.sh`).
- **Instructions editor** is ProseMirror. A synthetic `paste` event is the reliable way to set
  the text (`scripts/paste-snippet.sh`).
- Uploaded skills stay pending until you click **Update**. ChatGPT then safety-checks them
  before the agent can use them.
- `/v1/skills` on the OpenAI Platform is a different thing (skills for the Responses API shell
  tool). It doesn't reach ChatGPT agents.

## Requirements

- A ChatGPT workspace with agents enabled, and permission to build agents in it.
- A browser automation tool already signed in to ChatGPT: **Claude in Chrome**, or a
  Playwright-style MCP that can run `async (page) => …` code. The agent never types your password.
- `bash`, `base64`, `zip`.

## Install

```
/plugin install chatgpt-workspace-agents --marketplace danielrosehill/ChatGPT-Workspace-Agents-Claude-Plugin
```

On older Claude Code: `/plugin marketplace add danielrosehill/ChatGPT-Workspace-Agents-Claude-Plugin`,
then `/plugin install chatgpt-workspace-agents@chatgpt-workspace-agents`.

Or clone it and point Claude Code at the folder with `--plugin-dir`.

## Layout

- `references/builder-mechanics.md`: URLs, selectors, working snippets, and what's verified vs not.
- `scripts/paste-snippet.sh`: instructions → paste snippet.
- `scripts/upload-snippet.sh`: context files → file-chooser snippet.
- `scripts/skill-zips.sh`: one upload zip per skill folder.
- `scripts/skill-drop-snippet.sh`: one skill zip → drop snippet.
- `docs/official-docs-notes.md`: what OpenAI's help article says (limits, access levels, auth).

## License

MIT
