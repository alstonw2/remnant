#!/usr/bin/env bash
# Run the two AI passes against the record, rebuild, and publish.
#
#   export ANTHROPIC_API_KEY=sk-ant-...
#   ./finalize.sh                 # derive + curate + build + deploy
#   ./finalize.sh --no-deploy     # everything except publishing
#   ./finalize.sh --curate-only --no-deploy            # curate, look, don't publish
#   ./finalize.sh --curate-only --no-deploy guatemala  # just one chapter
#   ./finalize.sh --derive-only                        # after the learnings are written
#   ./finalize.sh --curate-stale --no-deploy           # after adding photos
#
# Order matters: --curate reads only the photographs and overwrites chapter
# titles and narratives, so run it before writing anything by hand. --derive
# reads the learnings and weighs them, so run it after they are written.
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

# Catch a malformed key here rather than after a round trip to the API. The
# common mistakes are pasting a key onto the end of an example prefix, and
# leaving a smart-quote or ellipsis in from a copied instruction.
check_key() {
  case "$ANTHROPIC_API_KEY" in
    *sk-ant-*sk-ant-*)
      echo "Key contains the prefix twice — you pasted it after an example prefix." >&2
      echo "Export the whole key on its own:  export ANTHROPIC_API_KEY=sk-ant-..." >&2
      exit 1 ;;
    sk-ant-*) ;;
    *)
      echo "That does not look like an API key (should start with sk-ant-)." >&2
      exit 1 ;;
  esac
  if printf '%s' "$ANTHROPIC_API_KEY" | LC_ALL=C grep -q '[^ -~]'; then
    echo "Key contains a non-ASCII character — probably a smart quote or … pasted in." >&2
    exit 1
  fi
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 \
         https://api.anthropic.com/v1/models \
         -H "x-api-key: $ANTHROPIC_API_KEY" -H 'anthropic-version: 2023-06-01')
  if [ "$code" != "200" ]; then
    echo "Key rejected by the API (HTTP $code). Nothing was run or spent." >&2
    exit 1
  fi
  echo "▸ Key OK"
}

if [ -z "$ANTHROPIC_API_KEY" ]; then
  cat >&2 <<MSG
ANTHROPIC_API_KEY is not set.

  export ANTHROPIC_API_KEY=sk-ant-...
  ./finalize.sh
MSG
  exit 1
fi

check_key

[ -f "$PHOTOS" ] || { echo "Can't find photos.json at $PHOTOS" >&2;
                      echo "Set REMNANT_PHOTOS=/path/to/photos.json" >&2; exit 1; }

DEPLOY=1
CURATE_ONLY=""
CURATE_STALE=""
DERIVE_ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --no-deploy)   DEPLOY=0; shift ;;
    --curate-only) CURATE_ONLY=1; shift ;;
    --curate-stale) CURATE_STALE=1; shift ;;
    --derive-only) DERIVE_ONLY=1; shift ;;
    *) break ;;
  esac
done

echo "▸ Photos:  $PHOTOS"
echo

if [ -n "$CURATE_STALE" ]; then
  echo "▸ Re-curating only chapters whose photographs changed"
  "$PY" "$BUILD" "$PHOTOS" "$RECORD" "$SCAFFOLD" --curate-stale
elif [ -n "$CURATE_ONLY" ]; then
  echo "▸ Curating chapters: ${*:-all}"
  "$PY" "$BUILD" "$PHOTOS" "$RECORD" "$SCAFFOLD" --curate "$@"
elif [ -n "$DERIVE_ONLY" ]; then
  echo "▸ Deriving eras and ranking defining moments"
  "$PY" "$BUILD" "$PHOTOS" "$RECORD" "$SCAFFOLD" --derive
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
