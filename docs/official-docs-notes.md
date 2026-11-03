# Official docs notes

Source: https://help.openai.com/en/articles/20001143 (read 2026-11-03;
plain WebFetch and curl get a Cloudflare challenge, a search-engine fetcher such as Exa gets through). Recheck before
relying on limits.

- An agent combines tools, apps, custom MCP, skills and files.
- Files: 512 MB per file, 10 GB per agent.
- Write actions default to "Always ask"; per action you can set Never ask or a custom
  rule. Action constraints can be written in natural language.
- App auth per app: end-user (each user connects their own account) or agent-owned (the
  builder's connection is used for everyone).
- Access: Private, anyone with the link, or listed in the org directory.
- Collaboration: multiplayer editing with roles Can chat, Can edit, Owner.
- Schedules (Automations button in the builder).
- Triggers: Slack, and an API trigger using a Workspace Agent access token; the call
  returns 202 with a `conversation_url`. This runs agents; there is no known public API
  for building or editing them, hence the browser route in this plugin.
- Custom MCP apps work in agents on the web only.
