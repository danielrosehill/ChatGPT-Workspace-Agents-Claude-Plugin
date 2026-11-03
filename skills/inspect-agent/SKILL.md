---
name: inspect-agent
description: Read the current state of one ChatGPT Workspace Agent from the browser builder, without changing anything. Covers name, instructions, files, skills, apps, sharing and schedules. Use on "what's in agent X", "show agent X's instructions", "which skills does agent X have", or before update-agent.
---

# Inspect a workspace agent

Mechanics: `references/builder-mechanics.md`. This is read-only: never click Create, Update or Remove.

1. Get the ID from the user or `list-agents`, then open
   `https://chatgpt.com/agents/studio/edit/agt_<id>`.
2. Read it in one evaluate call (screenshots of the builder are slow):
   ```js
   () => ({
     name: document.querySelector('input[placeholder="Agent name"]')?.value,
     instructions: document.querySelector('div.ProseMirror')?.innerText,
     page: document.body.innerText.slice(0, 6000)
   })
   ```
   The page text lists apps, skills and file counts. For filenames, open `/files`. For one
   skill's content, click its chip (`/skills/hsk_<id>`).
3. If the user keeps local sources, diff them against what you read and report the drift. Don't
   overwrite either side without asking.

Reply with the name, ID, the instructions' length and first lines, then files, skills, apps and
access. Say which parts you read directly and which you couldn't find.
