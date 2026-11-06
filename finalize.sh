#!/usr/bin/env bash
# Run the two AI passes against the record, rebuild, and publish.
#
#   export ANTHROPIC_API_KEY=sk-ant-...
#   ./finalize.sh                 # derive + curate + build + deploy
#   ./finalize.sh --no-deploy     # everything except publishing
#   ./finalize.sh --curate-only guatemala glacier
#
# Both passes write their own file (demo/alston.derived.json,
# demo/alston.curated.json) which every later build merges back in, so this is
# safe to re-run and cheap to re-run — photos are cached after the first pass.
set -e
cd "$(dirname "$0")"

PHOTOS="${REMNANT_PHOTOS:-$HOME/alstonwang.github.io/photos.json}"
RECORD="demo/alston.json"
SCAFFOLD="demo/alston.scaffold.json"
BUILD="./demo/build-life.py"
PY=/usr/bin/python3           # system python is the arm64 one; see README

if [ -z "$ANTHROPIC_API_KEY" ]; then
  cat >&2 <<MSG
ANTHROPIC_API_KEY is not set.

  export ANTHROPIC_API_KEY=sk-ant-...
  ./finalize.sh
MSG
  exit 1
fi

[ -f "$PHOTOS" ] || { echo "Can't find photos.json at $PHOTOS" >&2;
                      echo "Set REMNANT_PHOTOS=/path/to/photos.json" >&2; exit 1; }

DEPLOY=1
CURATE_ONLY=""
case "${1:-}" in
  --no-deploy)   DEPLOY=0; shift ;;
  --curate-only) CURATE_ONLY=1; shift ;;
esac

echo "▸ Photos:  $PHOTOS"
echo

if [ -n "$CURATE_ONLY" ]; then
  echo "▸ Curating chapters: ${*:-all}"
  "$PY" "$BUILD" "$PHOTOS" "$RECORD" "$SCAFFOLD" --curate "$@"
else
  echo "▸ Deriving eras and ranking defining moments"
  "$PY" "$BUILD" "$PHOTOS" "$RECORD" "$SCAFFOLD" --derive
  echo
  echo "▸ Curating chapters"
  "$PY" "$BUILD" "$PHOTOS" "$RECORD" "$SCAFFOLD" --curate
fi

echo
echo "▸ What the record holds now"
"$PY" - "$RECORD" <<'PYEOF'
import json, sys
d = json.load(open(sys.argv[1]))
prov = d.get("_provenance") or {}
print("   eras:        %d  %s" % (len(d.get("eras", [])), prov.get("model", "")))
for e in d.get("eras", []):
    print("     %s–%s  %s" % (e.get("from"), e.get("to"), e.get("label")))
inc = [a for a in d.get("achievements", []) if a.get("included")]
out = [a for a in d.get("achievements", []) if a.get("included") is False]
print("   surfaced:    %s" % ", ".join(a["title"] for a in inc))
print("   held back:   %s" % (", ".join(a["title"] for a in out) or "none"))
for c in d.get("chapters", []):
    print("   %-14s %2d of %-3s kept  %s" % (
        c["id"], len(c["slides"]), c.get("candidates", "?"),
        "✓ reasoned" if c.get("curationWhy") else "— not curated"))
# Nothing half-written should ever reach the published page.
blob = json.dumps({k: v for k, v in d.items() if not k.startswith("_")})
bad = [m for m in ("_YOUR_WORDS", "_CHECK", "NEEDS_YOU") if m in blob]
if bad:
    sys.exit("\n   REFUSING TO PUBLISH — placeholder text in rendered fields: %s" % bad)
print("   placeholders in rendered fields: none")
PYEOF

echo
./build.sh

if [ "$DEPLOY" = "1" ]; then
  echo
  ./deploy.sh
else
  echo
  echo "Not deploying (--no-deploy). Run ./deploy.sh when ready."
fi
