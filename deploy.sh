#!/usr/bin/env bash
# Publish Remnant to alstonwang.com/remnant.html
#
# Rebuilds remnant.html from index.html, then copies remnant.html + the
# chapters/ folder into the alstonwang.github.io repo's `main` branch and
# pushes. GitHub Pages redeploys automatically (~1 min). Uses a temporary
# git worktree, so your current branch in the site repo is never touched.
#
# Usage:  ./deploy.sh
set -e
cd "$(dirname "$0")"

GIT=git
git --version >/dev/null 2>&1 || GIT=/usr/local/bin/git   # fall back if Xcode git is broken
SITE="$HOME/Documents/GitHub/alstonwang.github.io"
WT="$(mktemp -d)/site-main"

./build.sh

"$GIT" -C "$SITE" worktree add "$WT" main >/dev/null
cp remnant.html "$WT"/remnant.html
rm -rf "$WT"/chapters
cp -R chapters "$WT"/chapters
"$GIT" -C "$WT" add remnant.html chapters

if "$GIT" -C "$WT" diff --cached --quiet; then
  echo "Nothing to publish — already up to date."
else
  "$GIT" -C "$WT" commit -m "Publish Remnant update" >/dev/null
  "$GIT" -C "$WT" push origin main
  echo "✓ Published. Live at https://alstonwang.com/remnant.html in ~1 minute."
fi

"$GIT" -C "$SITE" worktree remove "$WT" --force
rm -rf "$(dirname "$WT")"
