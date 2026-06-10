# Remnant

*Your wishes, your traditions, your legacy — all in one place.*

Remnant is a side project exploring the mortality space: a gentle, guided product
for recording how you want to be cared for, which traditions you want upheld, and
how you want to be remembered.

## Features

**Guided life profile** — a 4-step flow covering:
1. The basics & cultural identity
2. Care preferences (living will, medical power of attorney, after-death wishes)
3. Family traditions & heritage worth preserving
4. Legacy messages, including time-locked letters delivered at life milestones

**Chapters — AI photo stories** — upload photos from a trip or season of life;
Claude analyzes them, selects the handful that best tell the story, and writes
the narrative connecting them. Presented as an interactive, playable slideshow.

## Architecture

- Single static `index.html` — no build step, no framework
- Photos are downscaled to 768px in the browser before anything is sent
- AI curation calls the Claude API (Haiku) directly from the browser with a
  user-supplied API key (BYOK — stored only in localStorage, never on a server)
- One batched API request per chapter (~$0.04 for 30 photos)
- Saved example chapters are static JSON in `chapters/` — visitors view them at
  zero API cost
- Profile data persists in localStorage; no accounts, no tracking

## Run locally

```bash
python3 -m http.server 3000
# open http://localhost:3000
```

## Adding a saved chapter

1. Curate a chapter with your own API key
2. Click "Export chapter (.json)"
3. Drop the file into `chapters/`
4. Add its filename to `chapters/manifest.json`

> "Death ends a life, not a relationship."
