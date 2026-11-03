#!/usr/bin/env bash
# One upload zip per skill folder (ChatGPT agents reject a zip holding more than one skill).
# Usage: skill-zips.sh <skills-dir> <out-dir>   (each <skills-dir>/<name>/SKILL.md -> <out-dir>/<name>.zip)
set -euo pipefail
src="${1:?skills dir}"; out="${2:?out dir}"
mkdir -p "$out"; out=$(cd "$out" && pwd)
for d in "$src"/*/; do
  [ -f "$d/SKILL.md" ] || continue
  name=$(basename "$d"); rm -f "$out/$name.zip"
  (cd "$src" && zip -qr "$out/$name.zip" "$name" -x '*/.DS_Store')
  echo "$out/$name.zip"
done
