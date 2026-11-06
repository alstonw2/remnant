#!/usr/bin/env python3
"""Seed a life file from the photo archive on alstonwang.com.

Reads photos.json (the photography page's index) and emits the parts of a life
record that can be derived mechanically: dated photographs, and chapters formed
from clusters of them.

It deliberately does NOT write any `why` strings. Reasoning is derived at
runtime by the model (docs/TRADEOFFS.md T-13, T-16); authoring it here would be
putting words in the system's mouth.

Everything a person has to supply themselves — letters, traditions, what they
actually said — stays in the hand-written section of the output file and is
merged over whatever this produces.

    ./demo/build-life.py photos.json demo/alston.json [scaffold.json] [--derive]

--derive additionally asks Claude to group the years into eras and rank the
candidate defining moments, writing the answer to <output>.derived.json. That
file is merged back in on every subsequent build, so the reasoning survives
regenerating the photo half and the published page ships with it — a visitor
without an API key still sees real derived reasoning rather than an empty
state. Needs ANTHROPIC_API_KEY in the environment.
"""
import json
import os
import sys
import urllib.parse
import urllib.request
from collections import defaultdict

# Era grouping and ranking is judgment over a whole life as text, and its output
# is the thing the page exists to show — so it gets the stronger model, unlike
# the high-volume perceptual photo curation, which runs on Haiku. See
# docs/TRADEOFFS.md T-16.
REASONER = "claude-sonnet-5-5"
API_URL = "https://api.anthropic.com/v1/messages"
PROMPT_FILE = "derive-prompt.txt"   # shared with index.html — one source of truth

# Absolute, so the record renders the same whether it is served from the site,
# from a local dev server, or from someone else's machine.
IMG_BASE = "https://alstonwang.com/images/"

# Caption prefixes that belong to one trip, and the chapter they form.
# Everything not claimed here stays a standalone dated photograph.
# Caption → real-world place. Chapter maps are built from this, so adding a
# coordinate here is all it takes for a trip to appear on the life map.
PLACES = {
    "Santa Cruz, Guatemala": (14.7333, -91.2000),
    "San Pedro, Guatemala": (14.6919, -91.2722),
    "Volcan de Fuego, Guatemala": (14.4747, -90.8806),
    "Acatenango, Guatemala": (14.5008, -90.8761),
    "Antigua, Guatemala": (14.5586, -90.7295),
    "Pistol River": (42.2787, -124.3976),
    "Secret Beach": (42.1830, -124.3730),
    "Samuel H. Boardman": (42.1500, -124.3500),
    "Samuel H. Boardman Scenic": (42.1500, -124.3500),
    "Devil's Punchbowl": (44.7457, -124.0618),
    "Thor's Well, Oregon Coast": (44.2780, -124.1130),
    "Shingle Mills, Oregon Coast": (42.2000, -124.3500),
    "Cannon Beach": (45.8918, -123.9615),
    "Crater Lake": (42.9446, -122.1090),
    "Glacier National Park": (48.7596, -113.7870),
    "Grinnell Glacier, Glacier": (48.7563, -113.7236),
    "Japan": (35.6762, 139.6503),
    "Taipei": (25.0330, 121.5654),
    "Costa Rica": (9.7489, -83.7534),
    "Arenal Volcano, Costa Rica": (10.4630, -84.7033),
    "La Fortuna, Costa Rica": (10.4678, -84.6427),
    "La Paz Waterfall, Costa Rica": (10.2167, -84.1667),
}

CHAPTERS = [
    ("guatemala", "Guatemala", 2025,
     ["Santa Cruz, Guatemala", "San Pedro, Guatemala", "Volcan de Fuego, Guatemala",
      "Acatenango, Guatemala", "Antigua, Guatemala"]),
    ("oregon-coast", "The Oregon Coast", 2026,
     ["Pistol River", "Secret Beach", "Samuel H. Boardman", "Samuel H. Boardman Scenic",
      "Devil's Punchbowl", "Thor's Well, Oregon Coast", "Shingle Mills, Oregon Coast",
      "Cannon Beach", "Crater Lake", "Moonlight"]),
    ("glacier", "Glacier National Park", 2024,
     ["Glacier National Park", "Grinnell Glacier, Glacier"]),
    ("asia", "Japan and Taiwan", 2025,
     ["Japan", "Taipei"]),
    ("costa-rica", "Costa Rica", 2025,
     ["Costa Rica", "Arenal Volcano, Costa Rica", "La Fortuna, Costa Rica",
      "La Paz Waterfall, Costa Rica"]),
]


def youtube_id(url):
    if "youtu.be/" in url:
        return url.rsplit("/", 1)[-1].split("?")[0]
    q = urllib.parse.urlparse(url).query
    return urllib.parse.parse_qs(q).get("v", [""])[0]


def media_for(item):
    """A still becomes a src; a drone video becomes a poster plus a link out."""
    if item.get("type") == "video" and item.get("url"):
        vid = youtube_id(item["url"])
        return {"video": item["url"],
                "src": "https://img.youtube.com/vi/%s/hqdefault.jpg" % vid}
    section = item.get("section") or "camera"
    return {"src": IMG_BASE + section + "/" + urllib.parse.quote(item["file"])}


def build_prompt(record, here):
    """Fill the shared template. index.html composes the identical prompt from
    the same file, so the browser button and this CLI cannot drift apart."""
    by_id = {}
    for key in ("chapters", "achievements", "letters", "traditions"):
        for item in record.get(key, []):
            by_id[item.get("id")] = item

    lines = []
    for e in record["events"]:
        ref = by_id.get(e.get("ref"))
        title = e.get("title") or (ref or {}).get("title") or (ref or {}).get("name") or ""
        detail = (e.get("detail") or (ref or {}).get("detail") or "")[:160]
        lines.append("%s [%s] %s%s" % (e["year"], e["kind"], title,
                                       " — " + detail if detail else ""))

    cands = ["id:%s | %s | %s — %s" % (a["id"], a["year"], a["title"], a.get("detail", ""))
             for a in record.get("achievements", [])]

    voice = ['%s (%s): "%s"' % (q.get("at") or "undated", q.get("source", ""), q["text"])
             for q in record.get("voice", {}).get("quotes", [])]
    # Learnings are passages in the person's own words too, and the prompt is
    # told to weigh them — so they have to be in the corpus it sees.
    for key, label in (("chapters", "Chapter"), ("achievements", "Defining moment"),
                       ("eras", "Era"), ("traditions", "Tradition"), ("letters", "Letter")):
        for item in record.get(key, []):
            lrn = item.get("learning") or {}
            if lrn.get("text"):
                name = item.get("title") or item.get("name") or item.get("label") or ""
                voice.append('%s (%s — %s): "%s"' % (lrn.get("at") or "undated", label,
                                                     name, lrn["text"]))
    for e in record["events"]:
        lrn = e.get("learning") or {}
        if lrn.get("text"):
            voice.append('%s (%s): "%s"' % (lrn.get("at") or e["year"],
                                            e.get("title", ""), lrn["text"]))

    years = [e["year"] for e in record["events"]]
    born = record.get("person", {}).get("born")
    lo = min(years + ([born] if born else []))

    template = open(os.path.join(here, PROMPT_FILE), encoding="utf-8").read()
    return (template
            .replace("{TIMELINE}", "\n".join(lines))
            .replace("{CANDIDATES}", "\n".join(cands))
            .replace("{VOICE}", "\n".join(voice) or "(nothing written down yet)")
            .replace("{FROM}", str(lo))
            .replace("{TO}", str(max(years))))


def derive(record, here, out_path):
    key = os.environ.get("ANTHROPIC_API_KEY", "").strip()
    if not key:
        sys.exit("--derive needs ANTHROPIC_API_KEY in the environment.")

    body = json.dumps({
        "model": REASONER,
        "max_tokens": 2000,
        "messages": [{"role": "user", "content": build_prompt(record, here)}],
    }).encode()

    req = urllib.request.Request(API_URL, data=body, headers={
        "content-type": "application/json",
        "x-api-key": key,
        "anthropic-version": "2023-06-01",
    })
    print("  asking %s ..." % REASONER)
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            data = json.load(r)
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", "replace")[:300]
        sys.exit("API error %s: %s" % (e.code, detail))

    text = "".join(b.get("text", "") for b in data.get("content", []))
    text = text.strip().removeprefix("```json").removeprefix("```").removesuffix("```")
    try:
        parsed = json.loads(text)
    except json.JSONDecodeError:
        sys.exit("Model did not return valid JSON:\n" + text[:400])

    usage = data.get("usage", {})
    parsed["_provenance"] = {
        "model": REASONER,
        "at": __import__("datetime").datetime.now().isoformat(timespec="seconds"),
        "input_tokens": usage.get("input_tokens"),
        "output_tokens": usage.get("output_tokens"),
    }
    path = out_path.replace(".json", ".derived.json")
    json.dump(parsed, open(path, "w"), indent=2, ensure_ascii=False)
    print("  %s: %d eras, %d achievements ranked (%s in / %s out)" % (
        path, len(parsed.get("eras", [])), len(parsed.get("achievements", [])),
        usage.get("input_tokens"), usage.get("output_tokens")))
    return parsed


def apply_derived(record, derived):
    """Only the model's own two outputs are overwritten. Events, chapters,
    letters, quotes and every learning are the person's and are never touched."""
    if derived.get("eras"):
        record["eras"] = derived["eras"]
        for e in record["events"]:
            era = next((x for x in record["eras"]
                        if e["year"] >= x["from"] and (x.get("to") is None or e["year"] <= x["to"])), None)
            if era:
                e["era"] = era.get("id")
    ranked = {a["id"]: a for a in derived.get("achievements", [])}
    for a in record.get("achievements", []):
        d = ranked.get(a["id"])
        if not d:
            continue
        if isinstance(d.get("included"), bool):
            a["included"] = d["included"]
        if d.get("why"):
            a["why"] = d["why"]
    if derived.get("_provenance"):
        record["_provenance"] = derived["_provenance"]


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    flags = {a for a in sys.argv[1:] if a.startswith("--")}
    src_path, out_path = args[0], args[1]
    here = os.path.dirname(os.path.abspath(__file__))
    photos = json.load(open(src_path))

    claimed = {cap for _, _, _, caps in CHAPTERS for cap in caps}
    by_caption = defaultdict(list)
    for p in photos:
        by_caption[p.get("caption") or ""].append(p)

    chapters = []
    for cid, title, year, caps in CHAPTERS:
        shots = [p for cap in caps for p in by_caption.get(cap, [])]
        shots = [p for p in shots if p.get("date")]
        # Videos last — they read as a coda rather than an opening frame.
        shots.sort(key=lambda p: (p.get("type") == "video", p["date"]))
        if not shots:
            continue
        chapters.append({
            "id": cid,
            "year": year,
            "title": title,
            "eyebrow": "Chapter · %s" % year,
            "narrative": "",          # written by curation, not here
            "curationWhy": "",        # derived, not authored
            "candidates": len(shots),
            "locations": [
                {"name": cap, "lat": PLACES[cap][0], "lng": PLACES[cap][1]}
                for cap in caps if cap in PLACES
            ],
            "slides": [
                dict(media_for(p), caption=p.get("caption", ""), why="")
                for p in shots
            ],
        })

    # Dated photographs that aren't part of a chapter become timeline moments.
    loose = []
    for p in photos:
        cap = p.get("caption") or ""
        if cap in claimed or not p.get("date"):
            continue
        loose.append(p)
    loose.sort(key=lambda p: p["date"])

    seen = set()
    events = []
    for p in loose:
        cap = p.get("caption") or ""
        if cap in seen:
            continue
        seen.add(cap)
        events.append(dict({
            "year": int(p["date"][:4]),
            "kind": "video" if p.get("type") == "video" else "photo",
            "title": cap,
            "detail": "",
        }, **media_for(p)))
    for cid, _, year, _ in CHAPTERS:
        if any(c["id"] == cid for c in chapters):
            events.append({"year": year, "kind": "chapter", "ref": cid})

    out = {
        "_generated": "demo/build-life.py — chapters and photo moments from photos.json",
        "chapters": chapters,
        "events": events,
    }

    # Merge the hand-written half over the generated one. The scaffold owns the
    # person, achievements, letters and quotes; this script owns anything that
    # can be read out of the photo archive.
    if len(args) > 2:
        scaffold = json.load(open(args[2]))
        events = events + scaffold.pop("scaffoldEvents", [])
        scaffold.pop("chapters", None)
        # Learnings are keyed by id so they survive regeneration — the photos
        # can change without losing what the experience taught.
        learnings = scaffold.pop("learnings", {})
        out.update(scaffold)
        for ch in out["chapters"]:
            if learnings.get(ch["id"], {}).get("text"):
                ch["learning"] = learnings[ch["id"]]
        for a in out.get("achievements", []):
            if learnings.get(a["id"], {}).get("text"):
                a["learning"] = learnings[a["id"]]
        out["events"] = events

    out["events"] = sorted(out["events"], key=lambda e: e["year"])

    # Reasoning persists across rebuilds: regenerate the photo half as often as
    # you like without losing what the model concluded.
    derived_path = out_path.replace(".json", ".derived.json")
    if "--derive" in flags:
        derived = derive(out, here, out_path)
    elif os.path.exists(derived_path):
        derived = json.load(open(derived_path))
    else:
        derived = None
    if derived:
        apply_derived(out, derived)

    json.dump(out, open(out_path, "w"), indent=2, ensure_ascii=False)
    print("%s: %d chapters, %d photo moments%s" % (
        out_path, len(chapters), len(events),
        ", %d eras derived" % len(out.get("eras", [])) if derived else ""))


if __name__ == "__main__":
    main()
