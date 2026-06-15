#!/usr/bin/env bash
# Regenerate the deployable subpage from the canonical app file.
# index.html is the single source of truth; remnant.html is generated from it.
# Run this before uploading to alstonwang.com so the two never drift.
set -e
cd "$(dirname "$0")"
cp index.html remnant.html
echo "✓ remnant.html regenerated from index.html"
echo "  Upload remnant.html + the chapters/ folder to your web root."
