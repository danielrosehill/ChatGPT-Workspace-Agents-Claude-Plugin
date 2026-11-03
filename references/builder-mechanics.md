# Agent builder mechanics (chatgpt.com/agents/studio)

Everything here was checked by hand on 2026-11-03 in one ChatGPT Business workspace,
unless it is marked **unverified**. The builder is a web app with no API for editing agents,
so these selectors **will** drift. When something fails, read the page (text or
accessibility snapshot), fix this file, and note the date.

## Browser

Any browser automation that is already signed in to ChatGPT works:

- **Playwright-style MCP** (e.g. Playwright MCP's `browser_run_code`, which takes `async (page) => { … }`).
  The snippets below use this form, and `page.waitForEvent('filechooser')` handles file uploads.
- **Claude in Chrome**: run the in-page parts with `javascript_tool`. It can't reach the
  native file chooser, so files and skills go in as synthetic paste or drop events (see below).

General notes:

- Never type a password. If you're not signed in, ask the user to sign in.
- Open a new tab rather than taking over one the user is using.
- Screenshots of the builder are slow and sometimes time out. Reading
  `document.body.innerText.slice(0, 4000)` is faster and more reliable.

## URLs

| What | URL |
|---|---|
| Agents home (tabs: Recently used / Built by me / <workspace> directory) | https://chatgpt.com/agents |
| New agent | https://chatgpt.com/agents/studio/new |
| Edit agent | https://chatgpt.com/agents/studio/edit/agt_<id> |
| Files pane | https://chatgpt.com/agents/studio/edit/agt_<id>/files |
| One skill | https://chatgpt.com/agents/studio/edit/agt_<id>/skills/hsk_<id> |
| ChatGPT channel (sharing, description, starters) | https://chatgpt.com/agents/studio/edit/agt_<id>/channels/chatgpt |
| Use the agent | https://chatgpt.com/agents/a/agt_<id> (`/agents/agt_<id>` is a 404) |
| Workspace admin, apps | https://chatgpt.com/admin/plugins (redirects to admin.openai.com) |

Agent IDs look like `agt_` + 32 hex characters, skill IDs like `hsk_` + 32 hex.

## No API (checked 2026-11-03)

- The **Workspace Agents API** (https://developers.openai.com/workspace-agents) only *triggers runs*
  of a published agent: `POST https://api.chatgpt.com/v1/workspace_agents/{agtch_id}/trigger`,
  with a Workspace Agent access token from ChatGPT Admin. It can't create or edit agents.
- **Platform `/v1/skills`** (https://developers.openai.com/api/docs/guides/tools-skills) uploads
  skills for the Responses API shell tool. They don't appear in ChatGPT agents.

## Create a draft

1. Navigate to `/agents/studio/new`.
2. Click "Start blank" (top right). Animated cards make Playwright's stability check time
   out, so force the click:
   ```js
   async (page) => {
     await page.getByText('Start blank').click({ force: true });
     await page.waitForURL(/\/agents\/studio\/edit\/agt_/);
     return page.url();
   }
   ```
3. Once it redirects to `/agents/studio/edit/agt_<id>`, the draft exists. Record the ID.

## Name

```js
async (page) => { await page.fill('input[placeholder="Agent name"]', 'My Agent'); }
```

## Instructions (ProseMirror editor)

`keyboard.insertText` was unreliable. A synthetic paste works and renders the markdown:

```js
async (page) => {
  const md = Buffer.from('<BASE64_OF_INSTRUCTIONS_MD>', 'base64').toString('utf8');
  await page.evaluate((md) => {
    const el = document.querySelector('div.ProseMirror');
    el.focus();
    const dt = new DataTransfer();
    dt.setData('text/plain', md);
    el.dispatchEvent(new ClipboardEvent('paste', { clipboardData: dt, bubbles: true, cancelable: true }));
  }, md);
  return await page.evaluate(() => document.querySelector('div.ProseMirror').innerText.length);
}
```

`scripts/paste-snippet.sh <file.md>` prints this code with the base64 filled in.

**Replacing** existing instructions (verified): click `div.ProseMirror`, press `Control+A`,
then `Delete` (one character is left behind), then paste. Check that the returned length is
close to the new text's length, not old + new.

## Files

The "Upload files" button opens a menu, and the real chooser is behind the menu item. Once
the agent has files, the item reads "Upload file" (singular), next to "Upload folder";
match it with `/^Upload file/`.

```js
async (page) => {
  await page.getByRole('button', { name: 'Upload files' }).click();
  const [fc] = await Promise.all([
    page.waitForEvent('filechooser'),
    page.getByRole('menuitem', { name: /^Upload file/ }).click(),
  ]);
  await fc.setFiles([
    { name: 'notes.md', mimeType: 'text/markdown', buffer: Buffer.from('<B64>', 'base64') },
  ]);
}
```

The URL becomes `.../files`; verify by reading the filenames from `innerText`.
`scripts/upload-snippet.sh <files...>` prints this code. For large binaries, fetch them inside
the snippet (`(await page.request.get(url)).body()`) instead of inlining base64. A 700 KB PNG
worked. The snippet can return blank while the page still shows the chooser; check `/files`.
Limits (official docs): 512 MB per file, 10 GB per agent.

## Skills

Skills use the open Agent Skills format: a folder containing `SKILL.md` (frontmatter `name`,
`description`) plus optional files. In the builder: **Skills → "+ Add skill"** opens a
dialog with "Add skill" (ChatGPT generates one from a description), **"Upload skill"**, and
"Popular skills" (`example-skill`, `skill-creator`).

- **One skill per zip.** A zip holding several skill folders is rejected with
  *"Archive must contain exactly one skill"*. `scripts/skill-zips.sh <skills-dir> <out-dir>`
  builds one zip per folder. "Upload folder" also takes a single skill folder.
- **Re-uploading does not overwrite.** Uploading a skill that's already attached adds a
  second chip with the same name. To replace it: click the chip (URL `.../skills/hsk_<id>`),
  click **Remove skill** (top right), confirm **Remove**, then upload the new zip. The skill
  view also shows Name, Display name, Description, the instructions, and a download button.
- **No `<input type=file>` in the DOM.** The dialog creates the picker on click. A synthetic
  drop works: build a `File` from base64, then dispatch `dragenter`, `dragover` and `drop`
  with a `DataTransfer` on the dropzone wrapper, the parent of the "Drop your skill here"
  button (class `vBsd-q_DropzoneWrap` on 2026-11-03; it's a CSS-module hash and will change).
  The page shows "Uploading skill…", closes the dialog and adds the chip.
  `scripts/skill-drop-snippet.sh <zip>` prints the code. With Playwright, a `filechooser`
  on the **"Upload .zip file"** button probably works the way it does for Files (**unverified**).
- Uploaded skills count as pending changes until you click **Update**. ChatGPT then checks
  them in the background for unsafe behaviour before the agent can use them.
- App tools appear inside the agent under prefixed names (`<server>_<tool>`, and gateways may
  add more prefixes). Have skills match on the tool's own name, not the full prefixed one.

## Apps

"Browse apps" opens a dialog with a "Search apps" box, a custom MCP entry ("Create app"), and
built-in apps (Google Drive, Calendar, Gmail and others). To add one: fill "Search apps" with
the exact name, click the list entry (`[role=dialog]` `getByText(name, {exact: true})`,
forced), then the detail pane's **"Add <app name>"** button. It turns into "Added" +
"Configure". The dialog stays open, so you can add several, then press Escape.

- Apps default to end-user auth: each person connects their own account on first use. The
  other option is agent-owned auth, where the builder's connection serves everyone.
- Custom MCP apps are created and published by a workspace admin (admin console → Plugins). They
  work in agents on the web only.
- Refreshing a custom app's tool list (verified): admin console → Plugins → the plugin → its
  app → the **Tools <n>** button → **Refresh**. The count updates in place without a
  republish. If your MCP server sits behind a proxy or portal that caches tool lists, make
  that resync first, or Refresh returns the old list.

## Save

- A new draft is only saved by the blue **Create** button (`getByRole('button', {name: 'Create', exact: true})`).
  It spins for about 15 s, then a dialog shows "<name> / Updated just now / Try in ChatGPT".
- After that, the button reads **Update**, with "N pending changes" beside it. Same dialog.
- Confirm by reading "Updated just now" in the top bar.

## Share

Open the "ChatGPT / Chat with your agent" card (`.../channels/chatgpt`). On the "Private to me"
row, click **Enable sharing**, which opens the "Share <name>" dialog. Type a name in "Search
people or groups", pick the `[role=option]`, set the permission (defaults to *Can edit*), then
**Send invite**. The same page holds the Description (64 characters), starter prompts and
automations. Access levels: private, anyone in the workspace with the link, or listed in
the workspace directory. Roles: Can chat, Can edit, Owner.

## Use / test

On `https://chatgpt.com/agents/a/agt_<id>` the composer is `div.ProseMirror`. Enter doesn't
send, so click the send button. Each app tool call shows "<agent> wants to use <app> to run
<tool>" with **Approve** / Cancel, one approval per call (reads included, by default).
