#!/usr/bin/env bash
# Print page JS that opens "+ Add skill" -> "Upload skill" and drops one skill zip on the
# dropzone (synthetic drag/drop; verified 2026-11-03 via Claude in Chrome javascript_tool).
# Usage: skill-drop-snippet.sh <skill.zip> > /tmp/drop.js
#   Claude in Chrome: pass the file content as javascript_exec text (top-level await is fine).
#   Playwright:       wrap as  async (page) => page.evaluate(async () => { <snippet> })
set -euo pipefail
zip="${1:?skill zip}"; name=$(basename "$zip"); b64=$(base64 -w0 "$zip")
cat <<JS
const btn = t => [...document.querySelectorAll('button')].find(b => b.textContent.trim() === t);
btn('Add skill').click(); await new Promise(r => setTimeout(r, 800));
btn('Upload skill').click(); await new Promise(r => setTimeout(r, 800));
const bytes = Uint8Array.from(atob('$b64'), c => c.charCodeAt(0));
const file = new File([bytes], '$name', { type: 'application/zip' });
const zone = document.querySelector('.vBsd-q_DropzoneWrap')
  || [...document.querySelectorAll('button')].find(b => /Drop your skill here/.test(b.textContent))?.parentElement;
const dt = new DataTransfer(); dt.items.add(file);
for (const t of ['dragenter', 'dragover', 'drop']) zone.dispatchEvent(new DragEvent(t, { bubbles: true, cancelable: true, dataTransfer: dt }));
'dropped $name';
JS
