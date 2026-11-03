#!/usr/bin/env bash
# Print a Playwright `async (page) => …` snippet (e.g. Playwright MCP browser_run_code) that pastes a markdown file into the agent
# builder's Instructions editor (div.ProseMirror) via a synthetic paste event.
# Usage: paste-snippet.sh instructions.md [--replace] > /tmp/paste.js
#   --replace  select all existing text first (unverified on the live UI, check the result)
set -euo pipefail
f=${1:?usage: $0 file.md [--replace]}
replace=false; [ "${2:-}" = "--replace" ] && replace=true
b64=$(base64 -w0 "$f")
cat <<JS
async (page) => {
  const md = Buffer.from('$b64', 'base64').toString('utf8');
  await page.locator('div.ProseMirror').first().focus();
  if ($replace) { await page.keyboard.press('Control+A'); }
  await page.evaluate((md) => {
    const el = document.querySelector('div.ProseMirror');
    el.focus();
    const dt = new DataTransfer();
    dt.setData('text/plain', md);
    el.dispatchEvent(new ClipboardEvent('paste', { clipboardData: dt, bubbles: true, cancelable: true }));
  }, md);
  await page.waitForTimeout(500);
  const got = await page.evaluate(() => document.querySelector('div.ProseMirror').innerText.length);
  return { sentChars: md.length, editorChars: got };
}
JS
