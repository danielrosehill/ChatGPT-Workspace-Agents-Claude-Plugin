---
name: create-agent
description: Create a new ChatGPT Workspace Agent (ChatGPT Business / Enterprise / Edu) by driving the agent builder at chatgpt.com/agents/studio in a signed-in browser. Sets the name, instructions, context files, skills and apps, then saves with Create. Use on "make a ChatGPT agent for X", "create a workspace agent called X", "build a ChatGPT agent from these instructions".
---

# Create a workspace agent

Read `references/builder-mechanics.md` first; it has the selectors and snippets. There's no
API for this, so every step is browser automation. If a selector fails, read the page and
adapt instead of retrying blindly.

## 1. Gather the inputs

Before touching the browser, have these in hand:
- a name;
- `instructions.md`;
- any context files;
- any skill folders (each one a folder with a `SKILL.md`);
- the apps it needs;
- who should have access.

If the user only gave a brief, draft the instructions and files locally first and show them.
Keep the sources in a repo or folder the user owns, not only in ChatGPT.

## 2. Create the draft

1. Open a new tab at https://chatgpt.com/agents/studio/new.
2. Force-click "Start blank" and wait for `/agents/studio/edit/agt_<id>`. **Record the ID now**,
   so a failure later doesn't leave an orphan draft.

## 3. Fill it

1. **Name:** fill `input[placeholder="Agent name"]`.
2. **Instructions:** run `scripts/paste-snippet.sh instructions.md` and run the code it prints.
   Check that `editorChars` ≈ `sentChars`.
3. **Files:** run `scripts/upload-snippet.sh context/*.md`. Check that every filename appears on `/files`.
4. **Skills:** run `scripts/skill-zips.sh <skills-dir> <out-dir>`, then upload **one zip at a
   time** through "+ Add skill" → "Upload skill". A zip holding several skills is rejected.
   Check that each skill's chip appears once.
5. **Apps:** "Browse apps" → search → "Add <app>". Keep the default auth and write-action policy
   ("Always ask") unless the user says otherwise.

## 4. Save

Click **Create**. Confirm "Updated just now" appears, then find the agent under
https://chatgpt.com/agents → "Built by me". A draft that was never saved doesn't count.

## 5. Access

It stays private by default. Only share it (`share-agent`) when the user names who should get access.

## Reply

Give the edit URL `https://chatgpt.com/agents/studio/edit/agt_<id>`, what was set, and
anything not done or not verified.

Don't put secrets or passwords in instructions, files or skills.
