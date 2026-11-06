#!/usr/bin/env bash
# Publish Remnant to alstonwang.com/remnant.html
#
# Rebuilds remnant.html from index.html, then copies remnant.html + the
# chapters/ folder into the alstonwang.github.io repo's `main` branch and
# pushes. GitHub Pages redeploys automatically (~1 min). Uses a temporary
# git worktree, so your current branch in the site repo is never touched.
#
# Usage:  ./deploy.sh [--dry-run]
#
#   --dry-run   Do everything except commit and push, and print what would
#               change. Safe to run any time.
#
# The site repo is found via, in order:
#   1. $REMNANT_SITE_REPO
#   2. the first of the known checkout locations below that exists
set -e
cd "$(dirname "$0")"

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

# Homebrew git first, then Apple's. (Xcode's shim can be broken after an
# update; /usr/local/bin/git only exists if git was installed from the
# standalone installer, so it is not a reliable fallback.)
GIT=git
git --version >/dev/null 2>&1 || GIT=/usr/bin/git

SITE="${REMNANT_SITE_REPO:-}"
if [ -z "$SITE" ]; then
  for candidate in \
    "$HOME/alstonwang.github.io" \
    "$HOME/Documents/GitHub/alstonwang.github.io"
  do
    [ -d "$candidate/.git" ] && SITE="$candidate" && break
  done
fi

if [ -z "$SITE" ]; then
  cat >&2 <<MSG
Could not find the alstonwang.github.io checkout.

Clone it next to this repo:
  gh repo clone alstonw2/alstonwang.github.io "\$HOME/alstonwang.github.io"

Or point at an existing checkout:
  REMNANT_SITE_REPO=/path/to/alstonwang.github.io ./deploy.sh
MSG
  exit 1
fi

echo "Site repo: $SITE"

WT="$(mktemp -d)/site-main"

./build.sh

# Detached worktree on origin/main: `worktree add <branch>` fails outright when
# the site repo already has main checked out, which is its normal state. Fetch
# first so we are not publishing on top of a stale base.
"$GIT" -C "$SITE" fetch --quiet origin main
"$GIT" -C "$SITE" worktree add --detach "$WT" origin/main >/dev/null
cp remnant.html "$WT"/remnant.html
cp poem.html "$WT"/poem.html
rm -rf "$WT"/chapters "$WT"/demo
cp -R chapters "$WT"/chapters

# The explorer fetches demo/*.json at runtime, so demo/ ships — but only the
# content. Dotfiles are working state: .photo-cache holds full-resolution
# downloads and is gitignored here, but a raw cp -R carried it into the site
# repo and broke the Pages build.
mkdir -p "$WT"/demo
find demo -mindepth 1 -maxdepth 1 ! -name '.*' -exec cp -R {} "$WT"/demo/ \;

# This site has no _config.yml, no layouts and no front matter, so Jekyll adds
# nothing and only introduces ways for a build to fail on file content.
touch "$WT"/.nojekyll
"$GIT" -C "$WT" add -A remnant.html poem.html chapters demo .nojekyll

if "$GIT" -C "$WT" diff --cached --quiet; then
  echo "Nothing to publish — already up to date."
elif [ "$DRY_RUN" = "1" ]; then
  echo
  echo "Would publish these changes (dry run — nothing committed or pushed):"
  "$GIT" -C "$WT" diff --cached --stat
else
  "$GIT" -C "$WT" commit -m "Publish Remnant update" >/dev/null
  "$GIT" -C "$WT" push origin HEAD:main
  echo "✓ Published. Live at https://alstonwang.com/remnant.html in ~1 minute."
fi

"$GIT" -C "$SITE" worktree remove "$WT" --force
rm -rf "$(dirname "$WT")"
