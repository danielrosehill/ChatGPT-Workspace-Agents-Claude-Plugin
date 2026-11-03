---
name: update-agent
description: Change an existing ChatGPT Workspace Agent in the browser builder. Replace or edit its instructions; add, replace or remove skills and context files; add or remove apps; rename it; then save with Update. Use on "update agent X's instructions", "add these skills to agent X", "replace the skill on X", "add Google Drive to agent X".
---

# Update a workspace agent

Mechanics: `references/builder-mechanics.md`. Run `inspect-agent` first so you know the
current state and can report what changed.

## Instructions

Run `scripts/paste-snippet.sh <file> --replace`. If `editorChars` comes out as roughly old +
new, the select-all didn't take: undo, click into the editor, `Control+A`, `Delete`, then paste again.

## Files

- **Add:** run `scripts/upload-snippet.sh <files>` on the `/files` view.
- **Replace:** upload the new file, then delete the old one from its row menu. Don't leave
  both, or the agent will read stale content.

## Skills

- **Add:** run `scripts/skill-zips.sh <skills-dir> <out-dir>`, then "+ Add skill" → "Upload skill",
  **one zip per skill**.
- **Replace:** re-uploading adds a **duplicate**, it doesn't overwrite. Remove the old one first:
  click its chip → **Remove skill** → **Remove**. Then upload the new zip.
- **Remove:** chip → Remove skill → Remove.
- Finally, check that each skill name appears exactly once in the Skills row.

## Apps

"Browse apps" → search → add, or remove from the app's chip. A custom MCP app has to be published
by a workspace admin first.

## Save

Click **Update** (top right, next to "N pending changes"). Confirm "Updated just now", then
re-read the page to check the change landed. Reply with what changed.
