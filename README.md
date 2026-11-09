# Remnant

*Your wishes, your traditions, your legacy — all in one place.*

Remnant is a side project exploring the mortality space: a gentle, guided product
for recording how you want to be cared for, which traditions you want upheld, and
how you want to be remembered.

## Features

**The explorer** — the page opens on a complete life you can explore immediately, with no
input and no API key: a draggable timeline across four eras, chapters, letters with their
delivery conditions, traditions, and the moments in between. Every decision the AI made is
shown with its reasoning and can be overruled — which frames it kept and why, which
achievements it promoted, which it deliberately left in the archive, and why a question
about the person returns nothing when they never wrote about it.

The whole demo life is `demo/life.json`. Swap that one file for your own record and the
explorer re-renders; nothing about the demo person is hardcoded in `index.html`.

A single **life map** sits above the timeline holding every place in the record, filtered
by the same scrubber — drag to 2009 and only the places that existed by then remain. Pins
open their entry.

Every experience carries a **learning** — advice to a younger self, a reflection, or
something for whoever comes after. These render in the person's own voice, visually
distinct from the model's reasoning; they are indexed by the voice lookup and weighted
when the model ranks defining moments.

Era grouping and achievement ranking are real inference, not authored copy. Derive them
once from the command line and the result is baked into the published record:

```bash
export ANTHROPIC_API_KEY=sk-...
./demo/build-life.py photos.json demo/alston.json demo/alston.scaffold.json --derive
```

Curate the chapters the same way — this picks which photographs survive, writes their
captions, and says why each was chosen:

```bash
./demo/build-life.py photos.json demo/alston.json demo/alston.scaffold.json --curate
```

Add chapter ids after the scaffold to curate only those (`--curate guatemala glacier`).

Each curated chapter records a fingerprint of the photographs it saw. When you add
photos later, the build says which chapters have drifted, and
`./finalize.sh --curate-stale` re-curates just those.
Photos are downscaled to 768px and cached in `demo/.photo-cache`, so re-runs are cheap.

That writes `demo/alston.derived.json`, which every later build merges back in — so the
photo half can be regenerated without losing the reasoning. The page shows the model and
date it was derived, and the "Re-derive with AI" button still runs it live for anyone with
a key. Both paths compose the same prompt from `demo/derive-prompt.txt`. The call uses
Sonnet rather than the Haiku used for photo curation — see `docs/TRADEOFFS.md` T-16, T-24.

**Guided life profile** — a 4-step flow covering medical directives, traditions and legacy
messages. No longer part of the demo flow (T-17); still built, still works, reachable at
`/remnant.html#plan`:
1. The basics & cultural identity
2. Care preferences (living will, medical power of attorney, after-death wishes)
3. Family traditions & heritage worth preserving
4. Legacy messages, including time-locked letters delivered at life milestones

**Chapters — AI photo stories** — upload photos from a trip or season of life;
star the ones you want highlighted, then Claude selects the handful that best
tell the story and writes the narrative connecting them. Presented as an
interactive, playable slideshow with collage slides, an interactive map of
where it happened, and full inline editing (rewrite text, reorder slides,
drop your own map pins).

## Where this is going

`docs/REQUIREMENTS.md` holds the forward-looking spec — age-matched delivery, mutual blind
disclosure, zero-knowledge custody with multi-guardian key sharding — and records where those
requirements currently contradict each other or what is built. `docs/TRADEOFFS.md` holds the
decisions already made and what each one cost.

## Architecture

- Single static `index.html` — no build step, no framework
- Photos are downscaled to 768px in the browser before anything is sent
- AI curation calls the Claude API (Haiku) directly from the browser with a
  user-supplied API key (BYOK — stored only in localStorage, never on a server)
- One batched API request per chapter (~$0.04 for 30 photos)
- Saved example chapters are static JSON in `chapters/` — visitors view them at
  zero API cost
- Profile data persists in localStorage (`remnant_v2`); no accounts, no tracking
- Letters and traditions are *entries* — `{ to, trigger, fields, revisions }` — and
  every reflective field keeps append-only revision history, one version per
  editing session. See `docs/TRADEOFFS.md` (T-01 to T-06) for why.

## Run locally

```bash
/usr/bin/python3 -m http.server 3000
# open http://localhost:3000
```

Use the absolute path: on Apple Silicon a Homebrew or python.org `python3` earlier
in `PATH` may be x86-only and fail to spawn with "Bad CPU type in executable".
`/usr/bin/python3` ships universal.

## Adding a saved chapter

1. Curate a chapter with your own API key
2. Click "Export chapter (.json)"
3. Drop the file into `chapters/`
4. Add its filename to `chapters/manifest.json`

## Deploy (as a subpage on alstonwang.com)

`index.html` is the single source of truth. `remnant.html` is the deployable
subpage, generated from it — never edit `remnant.html` directly.

```bash
./build.sh                       # regenerates remnant.html from index.html
```

Or publish in one step — `deploy.sh` rebuilds, copies `remnant.html` + `chapters/`
into the site repo on a temporary detached worktree, and pushes. GitHub Pages
redeploys in about a minute.

```bash
./deploy.sh --dry-run   # show exactly what would change, commit and push nothing
./deploy.sh             # publish
```

It finds the site repo at `$REMNANT_SITE_REPO`, else `~/alstonwang.github.io`,
else `~/Documents/GitHub/alstonwang.github.io`. Clone it first if missing:

```bash
gh repo clone alstonw2/alstonwang.github.io ~/alstonwang.github.io
```

Keep both checkouts outside `~/Documents` — sandboxed helper processes (the local
preview server among them) cannot read that directory on macOS, which shows up as
an unexplained 404 on every file.

The page goes live at `/remnant.html`; link to it from your homepage. The
`chapters/` folder powers the example gallery — omit it and the gallery simply
hides itself.

> "Death ends a life, not a relationship."
