# Remnant

*Everyone who will ever know you arrives mid-story.*

Your children will meet you tired, formed, already decided. They will never meet the
person figuring it out right now — and you are the only witness to that version who could
ever write it down.

Remnant records the present tense of a life, addressed to one named person, released on a
condition you choose. **Death is one delivery trigger, not the premise.**

**Live:** [alstonwang.com/remnant.html](https://alstonwang.com/remnant.html)

> The interesting part of this project is not the features. It is
> [`docs/TRADEOFFS.md`](docs/TRADEOFFS.md) — thirty-four decisions with the cost each one
> paid — and [`docs/REQUIREMENTS.md`](docs/REQUIREMENTS.md) §4.3, which is a section
> explaining where the stated requirements contradict what is actually built.

## Features

**The day-one flow** — the product. Four present-tense questions, one sitting, addressed to
one person by name, sealed behind a delivery trigger. Answer them again next month and the
month after, and the record accumulates without anyone ever sitting down to write a life.

The model has three jobs here, all of them judgment calls, all of them visible:

1. **It asks one follow-up**, built from a specific noun the person used. The prompt forbids
   feeling-labels, lesson-extraction, and summarising the answer back.
2. **It names the chapter** — a title drawn from the person's own words, with its reasoning.
3. **It may decline to ask.** When an answer discloses acute distress, the model returns no
   question at all and says why. The refusal renders as a card of its own rather than as
   silence (T-32). Most AI features demonstrate a model generating more; this one shows it
   stopping.

If the naming call fails, the record seals **unnamed** rather than inventing a title (T-33) —
the same fail-closed rule as T-15.

Entries are stamped with the author's age at the time of writing, not just the date, so an
age-matched delivery — *your daughter reads this at the age you wrote it* — needs no backfill.

**The explorer** — not the product; the exhibit of what the flow produces after years of it.
A complete life, explorable with no input and no API key: a draggable timeline across five
eras, chapters, learnings, a life map filtered by the same scrubber, and the moments in
between. Every AI decision is shown with its reasoning and can be overruled — which frames it
kept, which achievements it promoted, and which it deliberately left in the archive.

The page states plainly that this record was **assembled backwards** — twenty-eight years
reconstructed over several weeks, half of it remembered rather than recorded. That is not a
confession to bury; it is the argument for the day-one flow, because the reconstruction took
long enough that almost nobody would do it.

The whole demo life is `demo/alston.json`. Swap that one file for your own record and the
explorer re-renders; nothing about the demo person is hardcoded in `index.html`.

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

**Guided life profile** — *superseded, kept for the record.* This was the original product:
a 4-step form covering medical directives, traditions and legacy messages. It was taken out
of the demo flow (T-17) and then superseded entirely by the day-one flow (T-30), because a
form asking someone to document their life is the reason records like this never get
written. Still built, still works, unlinked but reachable at `/remnant.html#plan`:
1. The basics & cultural identity
2. Care preferences (living will, medical power of attorney, after-death wishes)
3. Family traditions & heritage worth preserving
4. Legacy messages, including time-locked letters delivered at life milestones

**Chapters — AI photo stories** — *a demonstration, not a third way in.* Upload photos from a
trip or season of life;
star the ones you want highlighted, then Claude selects the handful that best
tell the story and writes the narrative connecting them. Presented as an
interactive, playable slideshow with collage slides, an interactive map of
where it happened, and full inline editing (rewrite text, reorder slides,
drop your own map pins).

## Where this is going

Nothing below is built. It is written down so the reasoning survives, and so the gap between
what is claimed and what exists stays visible.

`docs/REQUIREMENTS.md` holds the forward-looking spec — age-matched delivery, mutual blind
disclosure, zero-knowledge custody with multi-guardian key sharding — and records where those
requirements currently contradict each other or what is built. `docs/TRADEOFFS.md` holds the
decisions already made and what each one cost.

## Architecture

- Single static `index.html` — no build step, no framework
- Photos are downscaled to 768px in the browser before anything is sent
- AI calls go to the Claude API directly from the browser with a user-supplied key
  (BYOK — stored only in localStorage, never on a server). Two models by task:
  **Haiku** for photo curation, which is perceptual, and **Sonnet** for every judgment
  call — era derivation, ranking, and all three of the day-one flow's jobs (T-16)
- Every prompt lives in `demo/*.txt` and is read by both the browser and the CLI, so the
  button and the command line cannot drift apart (T-24)
- One batched API request per chapter (~$0.04 for 30 photos)
- Saved example chapters are static JSON in `chapters/` — visitors view them at
  zero API cost
- Two localStorage stores, deliberately separate (T-31): `remnant_dispatch_v1` for
  day-one records, `remnant_v2` for the guided profile. The profile store is read back
  out of the DOM, so it only exists coherently while that flow is on screen — a failed
  first sitting must not be able to damage a record someone has kept for years. Both
  share `pushRevision`, so revision semantics cannot drift apart.
- Letters, traditions and day-one records are all *entries* — `{ to, trigger, fields,
  revisions }` — and every reflective field keeps append-only revision history, one
  version per editing session. See `docs/TRADEOFFS.md` (T-01 to T-06) for why.
- No accounts, no tracking, no server. The only outbound request is to the Claude API.

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
