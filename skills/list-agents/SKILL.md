---
name: list-agents
description: List the ChatGPT Workspace Agents you can see (Built by me, Recently used, or the workspace directory) with their names and agt_ IDs, read from chatgpt.com/agents in the browser. Use on "what ChatGPT agents do I have", "list my workspace agents", "find the ID of agent X".
---

# List workspace agents

Mechanics: `references/builder-mechanics.md`.

1. Open a new tab at https://chatgpt.com/agents.
2. Pick the tab: "Built by me" (the default), "Recently used", or the workspace's directory tab.
3. Read the names and IDs in one call:
   ```js
   async (page) => {
     await page.getByRole('tab', { name: 'Built by me' }).click().catch(() => {});
     await page.waitForTimeout(1500);
     return await page.$$eval('a[href*="agt_"]', as => as.map(a => ({
       text: a.innerText.trim().split('\n')[0], href: a.getAttribute('href') })));
   }
   ```
   If that returns nothing, the cards may not be links. Read the accessibility snapshot for
   names instead, then open each card to get its ID from the URL. An empty list when the user
   has agents means the read failed, not that there are none.

Reply with a short table: name, ID, and which tab it came from. If the user keeps a registry,
offer to reconcile it.
