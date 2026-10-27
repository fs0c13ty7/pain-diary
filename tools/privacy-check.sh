#!/usr/bin/env bash
# Privacy check: run before EVERY commit and push.
# This repo is PUBLIC. It must only ever contain the app's code.
# Pain logs, backup files and any personal information must never be committed.
set -u
cd "$(git rev-parse --show-toplevel)" || exit 1
fail=0
bad() { echo "BLOCKED: $1"; fail=1; }

# 1. Only these files may be in the repo (staged or committed).
allowed='^(index\.html|manifest\.webmanifest|sw\.js|README\.md|CLAUDE\.md|\.gitignore|tools/privacy-check\.sh|icons/(icon-192|icon-512|apple-touch-icon)\.png)$'
files=$(git ls-files --cached)
while IFS= read -r f; do
  [ -z "$f" ] && continue
  [[ "$f" =~ $allowed ]] || bad "unexpected file '$f' (only app files are allowed)"
done <<< "$files"

# 2. Content scan of every text file for logged data or personal details.
for f in $files; do
  case "$f" in *.png) continue;; esac
  [ -f "$f" ] || continue
  # Backup / entry data is JSON with quoted keys; the app code never uses quoted keys like these.
  grep -nE '"(exportedAt|areaNotes|stiffness|fatigue|entries)"[[:space:]]*:' "$f" >/dev/null && bad "'$f' looks like it contains logged entries or a backup"
  grep -nE '"date"[[:space:]]*:[[:space:]]*"[0-9]{4}-[0-9]{2}-[0-9]{2}"' "$f" >/dev/null && bad "'$f' contains dated entry data"
  grep -nE '"app"[[:space:]]*:[[:space:]]*"pain-diary"' "$f" >/dev/null && bad "'$f' contains a Pain Diary backup"
  # Email addresses and phone numbers
  grep -noE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$f" | grep -v 'users.noreply.github.com' >/dev/null && bad "'$f' contains an email address"
  grep -nE '(\+44|\b0)7[0-9]{3}[[:space:]]?[0-9]{6}\b' "$f" >/dev/null && bad "'$f' may contain a phone number"
done

# 3. Size sanity check: the app is small; a big file means something unexpected got in.
for f in $files; do
  [ -f "$f" ] || continue
  size=$(wc -c < "$f")
  [ "$size" -gt 300000 ] && bad "'$f' is unexpectedly large ($size bytes)"
done

# 4. Commit author email must not be a personal address.
email=$(git config user.email || true)
[[ "$email" == *users.noreply.github.com ]] || bad "git author email '$email' is not a GitHub noreply address"

if [ "$fail" -ne 0 ]; then echo "Privacy check FAILED. Nothing should be committed or pushed."; exit 1; fi
echo "Privacy check passed: $(echo "$files" | grep -c .) app files, no personal data found."
