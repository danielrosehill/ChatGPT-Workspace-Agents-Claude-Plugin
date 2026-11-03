---
name: share-agent
description: Change who can use or edit a ChatGPT Workspace Agent (private, anyone in the workspace with the link, or listed in the workspace directory), or invite named people as Can chat / Can edit / Owner, through the builder in the browser. Use on "share agent X with Y", "list agent X in the directory", "make agent X private again".
---

# Share a workspace agent

Mechanics: `references/builder-mechanics.md` → *Share*. Sharing gives other people access, so act
only when the user explicitly names who gets it and at which level.

1. Open `https://chatgpt.com/agents/studio/edit/agt_<id>/channels/chatgpt` (the "ChatGPT / Chat
   with your agent" card).
2. On "Private to me", click **Enable sharing**, which opens the "Share <name>" dialog. Search the
   person, pick the option, and set the role the user named (the default is *Can edit*, so lower it to
   *Can chat* if that's what they asked for). Then **Send invite**.
3. Re-read the sharing list to confirm the change.
4. Say in one line if the agent uses apps with **agent-owned** auth. Anyone it's shared with then
   acts through the builder's connected accounts.
