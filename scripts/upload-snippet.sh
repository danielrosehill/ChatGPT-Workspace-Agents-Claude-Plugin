#!/usr/bin/env bash
# Print a Playwright `async (page) => …` snippet (e.g. Playwright MCP browser_run_code) that uploads the given files to the
# currently open agent builder (Files menu -> Upload files) as in-memory buffers.
# Usage: upload-snippet.sh file1.md [file2.md ...] > /tmp/upload.js
set -euo pipefail
[ $# -ge 1 ] || { echo "usage: $0 file..." >&2; exit 1; }
entries=""
for f in "$@"; do
  name=$(basename "$f")
  case "$name" in
    *.md) mime=text/markdown ;; *.pdf) mime=application/pdf ;; *.txt) mime=text/plain ;;
    *.csv) mime=text/csv ;; *.json) mime=application/json ;; *) mime=application/octet-stream ;;
  esac
  b64=$(base64 -w0 "$f")
  entries+="    { name: '${name//\'/\\\'}', mimeType: '$mime', buffer: Buffer.from('$b64', 'base64') },"$'\n'
done
cat <<JS
async (page) => {
  await page.getByRole('button', { name: 'Upload files' }).click();
  const [fc] = await Promise.all([
    page.waitForEvent('filechooser'),
    page.getByRole('menuitem', { name: /^Upload file/ }).click(),
  ]);
  await fc.setFiles([
$entries  ]);
  await page.waitForTimeout(3000);
  return page.url();
}
JS
