# Remnant — Tradeoff Register

Every non-obvious design decision, why it went that way, and what it costs. Append as decisions are made;
never delete an entry — supersede it with a new one and mark the old one `Revised`.

**Format:** each entry records the choice, the rejected alternative, the reasoning, the price paid, and the
condition that should make us reopen it. An entry with no cost listed is probably not a real tradeoff.

| # | Decision | Status |
|---|---|---|
| T-01 | Entries are addressed and triggered, not journal entries | Settled |
| T-02 | Append-only revisions over last-write-wins | Settled |
| T-03 | One revision per field per sitting | Settled |
| T-04 | Only reflective fields carry history | Settled |
| T-05 | Shed oldest history rather than fail a save | Settled |
| T-06 | Trigger stored as `{type, value}`, not a sentence | Settled |
| T-07 | Death is one delivery trigger among several | **Open** |
| T-08 | Local-first storage, which delivery will eventually break | **Open** |
| T-09 | Retrieval-and-quote over generative persona | Settled |
| T-10 | Advance directives demoted out of step 2 | **Open** |
| T-11 | Lead with a populated life, not an empty form | Settled |
| T-12 | The whole demo lives in one swappable JSON file | Settled |
| T-13 | Every AI decision shows its reasoning, in the same affordance | **Revised v0.4** |
| T-16 | Two models: Haiku for seeing, Sonnet for judging | Settled |
| T-17 | The wizard leaves the demo flow entirely | Settled |
| T-18 | Private entries keep their shape and withhold their contents | Settled |
| T-19 | The real record is generated from the photo archive, not typed | Settled |
| T-20 | Every experience carries a learning, styled unlike the AI's reasoning | Settled |
| T-21 | Coverage gaps are shown, not hidden | Settled |
| T-22 | One life map, filtered by the scrubber | Settled |
| T-23 | The entry opens beside the timeline, not below it | Settled |
| T-24 | Derived reasoning is baked into the record, from one shared prompt | Settled |
| T-25 | Curation runs from the CLI against the published photographs | Settled |
| T-26 | Chapters are defined in the scaffold, not in code | Settled |
| T-14 | Surface what the model *declined* to promote | Settled |
| T-15 | Voice lookup fails closed | Settled |

---

## T-01 · Entries are addressed and triggered, not journal entries
**Status:** Settled · v0.2

**Chose:** The atomic unit is an *entry*: `{ to, trigger, fields, revisions }`. Every letter and every tradition
is directed at a named person and carries a condition for when it should reach them.
**Over:** An undirected journal-entry model — timestamped text, addressed to no one.
**Because:** `to` and `trigger` are the only two things separating this from a journaling app, and every feature
worth building downstream reads one or both: coverage maps ("nothing addressed to your brother"), per-person
drift, the unsent-letter nudge, and delivery itself. Without them the product competes with Day One and Apple
Journal on habit mechanics, where it has no advantage, and death-delivery becomes a bolt-on nobody arrived for.
**Costs:** Every new field has to answer "who is this for?", which is genuinely awkward for the reflective
prompts ("what brings you the most joy") that are currently addressed to nobody in particular. Those stay as
profile fields, so the app now carries two shapes of data instead of one.
**Revisit when:** Never on principle. But if profile fields keep outnumbering entries in real use, the split is
wrong and the reflective prompts should be addressable too.

## T-02 · Append-only revisions over last-write-wins
**Status:** Settled · v0.2

**Chose:** Both entries and reflective profile fields keep a `revisions` array. Saving appends a version rather
than replacing the previous one.
**Over:** The v1 behaviour — one flat snapshot in `remnant_v1`, overwritten on every autosave.
**Because:** The dataset that makes Remnant defensible is longitudinal: how your answer to the same question
changed over ten years. Drift reports, "you've rewritten this eleven times and never sent it", and the annual
retrospective are all computed from versions. v1 destroyed every one of them 800ms after it was typed. The
change is cheap now and impossible to backfill later — you cannot recover history you never recorded.
**Costs:** Storage grows without bound (see T-05), the schema is meaningfully more complex, and the payoff is
entirely deferred — nothing in the app reads `revisions` yet.
**Revisit when:** Never. This is the one decision with a deadline on it.

## T-03 · One revision per field per sitting
**Status:** Settled · v0.2

**Chose:** A 30-minute window. Inside it the newest revision is amended in place; outside it a new one is appended.
**Over:** A revision per autosave (keystroke-level), or an explicit user-triggered "save a version" button.
**Because:** Keystroke-level history is noise — a thousand near-identical rows describing one afternoon — and it
would exhaust localStorage in weeks. A manual button gets pressed by nobody. Session granularity is the level the
interesting question is actually asked at: *what did you think about this in March, versus this March?*
**Costs:** Edits made 29 minutes apart collapse into one version, so genuine mid-session rewrites are lost. The
window is a guess with no data behind it.
**Revisit when:** Real usage shows how people actually edit. If sittings are typically long, the window is too short.

## T-04 · Only reflective fields carry history
**Status:** Settled · v0.2

**Chose:** `VERSIONED_FIELDS` — the open-ended prompts. Names, phones, emails, and dates are stored current-only.
**Over:** Versioning every field uniformly.
**Because:** A phone number changing is a correction, not a revision. Keeping its history costs storage and
produces nothing anyone would want to read.
**Costs:** The set is hand-maintained, so a new prompt added to the wizard silently gets no history unless someone
remembers to add it. That failure is invisible until years later, when the data is already gone.
**Revisit when:** A field is added and forgotten. Consider inverting the default — version everything except a
short denylist of factual fields.

## T-05 · Shed oldest history rather than fail a save
**Status:** Settled · v0.2

**Chose:** On `QuotaExceededError`, drop the oldest revision anywhere in the archive and retry, never dropping the
last version of anything. Current answers are never sacrificed.
**Over:** Letting the save fail loudly, or capping history at a fixed count per field.
**Because:** The thing a user would notice and be hurt by is losing what is on screen. History is valuable but
it degrades gracefully — losing 2027 while keeping 2029 is survivable; losing today's letter is not.
**Costs:** Silent data loss. The archive quietly thins from the oldest end, which is precisely the end the drift
features care most about, and nothing tells the user it happened.
**Revisit when:** There is a backend (T-08), or before the first drift feature ships — whichever is first. At
minimum this should warn the user rather than degrade silently.

## T-06 · Trigger stored as `{type, value}`, not a sentence
**Status:** Settled · v0.2

**Chose:** Classify the unlock dropdown into `milestone | recurring | on-death | custom` alongside the human label.
**Over:** Storing the selected sentence verbatim, as v1 effectively did.
**Because:** Delivery logic has to branch on what kind of condition this is. "On the anniversary of my passing"
and "When they graduate" fire through completely different machinery, and re-deriving that from prose at delivery
time means parsing English in the one code path that must never be wrong.
**Costs:** `triggerTypeFor()` is regex over the option labels, so editing a dropdown option can silently
reclassify a trigger. The options and the classifier need to move to one shared table.
**Revisit when:** The dropdown gains options, or delivery is built for real.

## T-07 · Death is one delivery trigger among several
**Status:** Open · v0.2

**Chose:** Reframe the product around letters that can arrive while the writer is alive — milestones, dates,
letters to future-self, "send it now" — with death as the always-on fallback rather than the pitch.
**Over:** The original framing: an archive of a life, delivered after it ends.
**Because:** It fixes two problems at once. The payer is alive and receiving value monthly, so there is no
"who keeps paying after you're gone". And recipients see the product within weeks instead of decades, so the
referral loop closes at family scale rather than needing platform-wide critical mass.
**Costs:** It weakens the emotional clarity of the original pitch, which was unusually sharp. It also puts the
name under strain — *Remnant* is what is left over, which fits a memorial better than a channel between living
people. And it demands delivery infrastructure the current architecture cannot provide (T-08).
**Revisit when:** After the first cohort actually uses it. If people only ever write on-death letters, the
alive-value thesis is wrong and the original framing was right.

## T-08 · Local-first storage, which delivery will eventually break
**Status:** Open · v0.2

**Chose:** Keep everything in `localStorage`, no accounts, BYOK for the Claude API — for now.
**Over:** Standing up a backend as part of this change.
**Because:** It costs nothing to run, has no trust surface worth attacking, and keeps the whole product a single
static file. Nothing built so far needs a server.
**Costs:** This is flatly incompatible with the direction in T-07. A browser that is not open cannot deliver a
letter on a trigger, cannot send the monthly reminder, and cannot be the liveness ping for a dead-man's switch.
The archive is also confined to one browser on one device, and clearing site data destroys it.
**Revisit when:** Delivery is built — which is the moment T-07 becomes real. The smallest viable answer is a
service that holds encrypted blobs and a trigger schedule and never reads content, keeping the archive
local-first and readable-by-you while buying the delivery mechanic.

## T-09 · Retrieval-and-quote over generative persona
**Status:** Settled · v0.2

**Chose:** Any "what would they have said about this?" feature answers with the person's actual words, dated,
and returns nothing when they never addressed the topic.
**Over:** A model fine-tuned or prompted to speak *as* the deceased.
**Because:** The failure mode of a hallucinating persona is inventing words a grieving person will believe their
parent said. That harm cannot be walked back, and it poisons trust in the archive itself. The quoting version is
also more moving — a real sentence with a date on it beats a fluent imitation.
**Costs:** Far less impressive in a demo, and it returns "he never wrote about this" often, especially early when
the archive is thin. That silence is the honest answer and it will still read as a product failure to some users.
**Revisit when:** Never for impersonation. Summarising *across* a person's own entries, clearly labelled as
synthesis and always linked to sources, is a separate question worth reopening.

## T-10 · Advance directives demoted out of step 2
**Status:** Open · v0.2

**Chose (proposed):** Make the first action in the wizard *write one letter to one person*, and move medical
wishes, MPA, and after-death logistics into a later optional layer.
**Over:** The current order, where step 2 of 4 is CPR, ventilators, and feeding tubes.
**Because:** It is the heaviest, most legally fraught, most death-framed part of the product, and it currently
greets a new user roughly ninety seconds in. Time-to-first-value should be one letter, in under five minutes.
**Costs:** Directives are the real differentiator against journaling apps for the practical, planning-minded
user, and burying them may lose exactly the segment most willing to pay. It also unbalances a flow whose
four-step structure is currently doing a lot of design work.
**Revisit when:** Not yet implemented — the wizard still opens on directives. Decide before the next round of
UI work.


## T-11 · Lead with a populated life, not an empty form
**Status:** Settled · v0.3

**Chose:** The page opens on a complete, explorable life — Rosa Fuentes, 1951– — with a live timeline
scrubber in the hero that responds before any scrolling. The wizard moves behind "also plan the practical side."
**Over:** The previous order, where a visitor met an empty 4-step form whose second step was CPR and
ventilator preferences.
**Because:** The page's actual audience is people evaluating the work, and they will not do twenty minutes of
data entry to find out what the product is. A finished artifact explains the product in seconds; a blank form
explains nothing and asks for labor first. This also happens to be right for real users — see T-10.
**Costs:** The first thing anyone sees is now fictional, which has to be labelled honestly and slightly
undercuts the "this is your life" pitch. And the demo is only as convincing as its writing: a generic persona
would actively hurt, where a blank form was merely inert.
**Revisit when:** Alston swaps in his own record. At that point the demo life becomes a second-class citizen
and the page may want a chooser rather than a single default.

## T-12 · The whole demo lives in one swappable JSON file
**Status:** Settled · v0.3

**Chose:** `demo/life.json` holds the person, eras, events, chapters, achievements, letters, traditions and
quotes. `index.html` contains no content about Rosa at all and renders whatever the file provides.
**Over:** Inlining the demo content into the page, which is simpler and one fewer network request.
**Because:** The stated plan is to replace the fictional life with a real one. If that swap is a one-file
change it will actually happen; if it means editing a 116KB HTML file it will not.
**Costs:** The page now needs to be served over http — opening `index.html` from the filesystem fails the
fetch, and the explorer shows an error instead of content. Deploy also has to remember to ship `demo/`.
**Revisit when:** Never, unless the file grows large enough that a single fetch becomes a visible delay.

## T-13 · Every AI decision shows its reasoning, in the same affordance
**Status:** Revised · v0.3, amended v0.4

**Chose:** One reusable "why" chip, used in nine places — chapter curation, each individual frame, era
grouping, achievement inclusion, achievement exclusion, letter nudging, tradition significance, voice
retrieval, and voice refusal. Same component, same visual treatment, every time.
**Over:** Showing the model's reasoning only on chapter curation, where the `why` field already existed.
**Because:** One explained decision reads as a feature; nine explained decisions read as a stance. The
repetition is the argument — it says the system is built to be auditable rather than decorated with one
moment of transparency.
**Costs:** Nine explanations is a lot of disclosure on one page, and a user who opens none of them pays the
visual cost anyway.
**Amended v0.4:** the original cost here was honesty — the reasoning strings were authored, so the page
asserted a capability the pipeline did not have. Era grouping and achievement ranking are now real calls
(T-16). The demo still *ships* cached reasoning so it works with no API key, but the provenance line states
which you are reading and "Re-derive with AI" replaces it live. Remaining gap: per-frame `why` on the three
stored chapters is still authored, because those chapters have no real photographs behind them.
**Revisit when:** Real photos replace the gradient placeholders, at which point the stored chapters should be
regenerated through the actual curation call rather than written.

## T-14 · Surface what the model declined to promote
**Status:** Settled · v0.3

**Chose:** Achievements carry `included: true|false`. The excluded one — a Chamber of Commerce award, still
in its box — is kept out of the timeline but shown in the detail panel under "deliberately not surfaced,"
with its reasoning.
**Over:** Silently dropping anything the model ranked low.
**Because:** Any system can show what it picked. Showing what it passed over, and defending the omission, is
the part that demonstrates judgment — and it is the only way a user can catch the model being wrong about
their own life.
**Costs:** It invites argument with every omission, and at scale a "what was left out" list is as long as the
archive. This works at demo size and needs a different shape at real volume.
**Revisit when:** A real record produces more than a handful of exclusions.

## T-15 · Voice lookup fails closed
**Status:** Settled · v0.3

**Chose:** The retrieval requires a topic hit or two distinctive word matches, with common words filtered out
entirely. Below that threshold it returns "She never wrote about this" and explains why, rather than the
nearest passage.
**Over:** Returning the best available match whatever its score, which is what the first implementation did —
"whether she was happy" matched a letter about an argument, on the word "was."
**Because:** This is T-09 in practice. A system that always returns something is a system that will eventually
put words near a dead person's mouth, and a loose substring match gets there faster than a language model
does. Failing closed is the whole product promise.
**Costs:** Real questions get refused — asking in different words than she used returns nothing even when she
addressed the subject. Precision bought with recall, deliberately.
**Revisit when:** Semantic matching is on the table. Even then the threshold stays, and "no answer" has to
remain a first-class result rather than a fallback.


## T-16 · Two models: Haiku for seeing, Sonnet for judging
**Status:** Settled · v0.4

**Chose:** Chapter curation stays on Haiku. Era grouping and achievement ranking go to Sonnet, in a separate
text-only call.
**Over:** One model for everything, which is simpler to reason about and to price.
**Because:** They are different tasks. Curation is perceptual and high-volume — thirty images, one batched
call, and the judgment needed per photo is shallow. Era grouping reads a whole life as text and has to argue
about what clusters and what gets left out; that output is the thing the page is built to show, and a weaker
answer there is immediately visible in a way a slightly worse photo pick is not. The reasoning call is also
tiny — no images, roughly 4KB of prompt — so the stronger model costs almost nothing here.
**Costs:** Two model constants to keep current instead of one, and a second place to handle API failure.
Anyone reading the code has to understand why the split exists, hence this entry.
**Revisit when:** Haiku closes the gap on structured judgment, or the reasoning prompt grows enough that the
cost difference stops being negligible.

## T-17 · The wizard leaves the demo flow entirely
**Status:** Settled · v0.4

**Chose:** Nothing in the page points at the 4-step form any more. It still builds, still works, still holds
the entry model and revision history, and is reachable at `#plan` — but the demo flow is hero → explore →
make a chapter.
**Over:** T-10's softer version, which demoted directives behind an "also plan the practical side" link.
**Because:** The link was still an invitation to fill out a hundred and fifty fields on a page whose entire
job is to show, in ninety seconds, what the product is. Supersedes T-10: the question was never where the
form goes in the order, it was whether a demonstration should contain a form at all.
**Costs:** The most functionally complete part of the codebase is now invisible to anyone who does not know
the URL fragment, which is a strange thing to do with working software. If directives ever become the
product again, this reverses.
**Revisit when:** The page stops being a demonstration and starts being something people sign up for.


## T-18 · Private entries keep their shape and withhold their contents
**Status:** Settled · v0.5

**Chose:** Any entry can carry `"visibility": "private"`. It still occupies its place in the timeline and
still reports its shape — *a letter to someone, written 2024, six revisions* — but the page never renders
the contents.
**Over:** Two separate records, one public and one private, or simply leaving intimate entries out.
**Because:** The demo's power comes from its most private material — in the fictional version, an unsent
letter and a jar of broken needles. Swapping in a real life puts that tension on a public page in front of
strangers who are evaluating the author. Withholding contents while keeping the shape resolves it in the
product's favour: a locked card is *more* convincing than an absent one, because it demonstrates the privacy
model rather than describing it.
**Costs:** A locked card is a visible invitation to wonder what is behind it, which is its own kind of
disclosure — "there is an unsent letter here" says a good deal even with the text withheld. Anyone truly
sensitive should omit the entry, not mark it private, and the distinction is easy to get wrong.
**Revisit when:** Real private entries exist. The shape metadata may need its own redaction level.

## T-19 · The real record is generated from the photo archive, not typed
**Status:** Settled · v0.5

**Chose:** `demo/build-life.py` reads the photography page's `photos.json` and emits the chapters and dated
moments; a hand-written scaffold holds the parts only a person can supply, and the script merges them.
**Over:** Writing the record out by hand once.
**Because:** 135 dated, captioned photographs already existed. A life record assembled from an archive the
person already keeps is both less work and more honest than one composed for the occasion — and when new
photos are added, regenerating is one command rather than an editing session.
**Costs:** The captions in `photos.json` are location labels, not narrative ("Acatenango, Guatemala" four
times running), and the generator writes no `why` and performs no culling — so the real chapters currently
read as contact sheets rather than curated stories. That is correct behaviour (T-13: reasoning must be
earned) but it means the real record looks weaker than the fictional one until curation is actually run
against the images.
**Revisit when:** The curation call is wired to run over these photographs. That is the step that turns
"13 of 13 kept" into a chapter.


## T-20 · Every experience carries a learning, styled unlike the AI's reasoning
**Status:** Settled · v0.5

**Chose:** Chapters, achievements, eras, traditions and letters each carry a `learning` — advice to a
younger self, a reflection, or something for whoever comes after. It renders in serif on gold, clearly
unlike the dashed terra "why" chip the model uses.
**Over:** Leaving the record as a sequence of things that happened.
**Because:** Three things at once. It answers the tenet directly — what a life consisted of includes what it
taught. It is the part no archive can generate, which makes it the strongest evidence the record is actually
someone's. And the visual separation matters more than it looks: a page where the machine's argument and the
person's voice share a style is a page that is quietly lying about which is which.
**Costs:** It asks real work of the author — ten experiences, ten lessons — and a thin or glib learning is
worse than none, because it reads as filler in the one place the page promises sincerity. The empty state is
therefore a visible prompt rather than a blank, which means an unfinished record openly shows its gaps.
**Also:** learnings feed two other systems. They are indexed by the voice lookup as passages in the person's
own words, and the derivation prompt weighs them when ranking defining moments — an entry someone drew a
lesson from outranks one they merely listed. That coupling is deliberate: it means writing a learning is the
highest-leverage thing an author can do, and the page gets better in three places at once.
**Revisit when:** Learnings exist on real entries and it becomes clear whether "advice / reflection /
forward" are the right three kinds.


## T-21 · Coverage gaps are shown, not hidden
**Status:** Settled · v0.6

**Chose:** A year-by-year coverage strip under the scrubber. Years holding something are solid bars sized by
density; empty years are hatched. The legend names the longest gap, and the incomplete notice lists every
stretch of three years or more with nothing in it.
**Over:** Rendering only the years that have content, which looks complete at any level of completeness.
**Because:** It is the authoring view and the product view at once. For the author the gaps are the to-do
list — the page says "1998–2017" and that is the next afternoon's work. For a visitor it is the honest shape
of a record in progress, and a record that admits what it is missing is more trustworthy than one that
quietly crops to its best years.
**Costs:** A record that is mostly gaps looks mostly empty, which is exactly how this one looks right now —
six of twenty-nine years. That is accurate and it is still a bad first impression, so the gaps have to get
filled before this is shown to anyone.
**Revisit when:** The record is reasonably complete. A finished life does not need its own progress bar, and
this may become an authoring-only view.


## T-22 · One life map, filtered by the scrubber
**Status:** Settled · v0.7

**Chose:** A single map above the timeline holding every place in the record — birthplace, schools, cities,
and every trip chapter's locations. It obeys the scrubber: drag to 2009 and three pins remain. Chapter pins
are green, single moments terra, and a pin's popup opens that entry below.
**Over:** A map per chapter, which is what the existing Chapters viewer already does.
**Because:** Places are how people actually navigate a life — "where were you then" is a more natural
question than "what year was that". Binding it to the scrubber turns the map into a second reading of the
same data rather than a decoration: watching pins appear from Hainan, to New York, to Ithaca, to Seattle,
then scattering outward across five trips, is the migration story told without a sentence of copy.
**Costs:** Leaflet has to be measured after the container is visible, so the map renders behind an
80ms timeout and re-fits on open — fragile in the way deferred layout always is. Coordinates are also
hand-placed in a table keyed by photo caption, which means a new trip silently has no pins until someone
adds its coordinates. And the map needs network tiles, so it is the one part of the page that fails
visibly offline.
**Revisit when:** A chapter is added and nobody notices it missing from the map. EXIF was the obvious fix and
it does not work here — sampling three of the site's photographs (an iPhone shot, a Fujifilm shot, one from
Guatemala) found EXIF present but the GPS block stripped from every one. EXIF would improve the *dates*,
which `photos.json` gets wrong in places, but coordinates have to stay hand-placed.


## T-23 · The entry opens beside the timeline, not below it
**Status:** Settled · v0.8

**Chose:** Above 900px the explorer is two columns — the timeline on the left, a sticky panel on the right
that fills with whatever you clicked. Clicking scrolls nothing. Below 900px it stacks and the panel scrolls
into view as before.
**Over:** One column with the detail rendered underneath, which is what it was.
**Because:** Reading a life means moving through it quickly, and a layout that jumps the page on every click
punishes exactly that. Side by side, the timeline stays put and the panel changes — so the photograph is the
thing that moves, not the page. It also gives photographs somewhere to be big: in the old single column they
were 92px thumbnails next to text, and the whole claim of the product is that you can see what a life
consisted of.
**Costs:** Two layouts to keep working, and the sticky panel has its own scroll for long chapters, which
means a scroll container inside a scroll container — always slightly awkward with a trackpad. The rail also
needs explicit affordances it did not need before (a chevron, a hint line, a marked-open state), because a
row that changes something elsewhere on screen is less obviously clickable than one that expands in place.
**Revisit when:** Someone misses that the panel changed. If that happens the panel needs a transition, not a
bigger hint.


## T-24 · Derived reasoning is baked into the record, from one shared prompt
**Status:** Settled · v0.9

**Chose:** `build-life.py --derive` runs the era-grouping and ranking call from the command line and writes
the answer to `<record>.derived.json`, which every later build merges back in. The prompt itself lives in
`demo/derive-prompt.txt`, read by both the CLI and the browser button.
**Over:** Leaving derivation as a browser-only action, which is what it was.
**Because:** The in-browser version held its result in memory and lost it on reload, so the published page
shipped with no eras at all — a visitor without an API key met "No eras yet, press Re-derive" exactly where
the page's best argument should be. Baking the result in means the page ships with real derived reasoning,
labelled with the model and date, and the button still runs it live for anyone who has a key. Keeping the
result in its own file rather than in the record means the photo half can be regenerated freely without
losing what the model concluded.
**Costs:** Reasoning on the page can now be stale — derived against an earlier version of the record and
silently carried forward, with only the provenance date to hint at it. Nothing warns when the record has
changed underneath it. The prompt file is also fetched at runtime by the browser, one more request and one
more thing that can 404.
**Revisit when:** The record changes often enough that stale reasoning misleads. The fix is a content hash
in `_provenance` and a "derived against an older record" warning, not re-deriving on every load.


## T-25 · Curation runs from the CLI against the published photographs
**Status:** Settled · v0.10

**Chose:** `build-life.py --curate [ids]` downloads each chapter's photographs, downscales them to 768px
with `sips`, caches them, and sends one batched vision call per chapter. The result lands in
`<record>.curated.json` and merges on every later build, the same shape as `--derive`. The prompt moves to
`demo/curate-prompt.txt`, shared with the in-browser flow.
**Over:** Leaving curation to the browser upload flow, which is where it already worked.
**Because:** The browser flow curates photos you are uploading now. The record's chapters are built from an
archive already published on the site, so there was nothing to upload and the chapters shipped uncurated —
"13 of 13 photographs kept", four consecutive frames captioned "Acatenango, Guatemala", and no per-frame
reasoning on the one page built to show per-frame reasoning. This closes the last gap between what the page
claims and what it does.
**Costs:** Two code paths now produce chapters, and only the prompt is shared — the CLI has no concept of
starred photos or tone, so those placeholders are filled with defaults and that divergence is invisible
until someone wonders why a CLI chapter reads differently. It also depends on `sips`, which is macOS-only;
Pillow is not installed on the system python. And curation overwrites captions, so anything hand-edited in
a chapter is lost on the next run — only the chapter's `learning` is protected.
**Revisit when:** Captions get hand-edited and then clobbered. At that point curated output needs to merge
rather than replace, or hand-edits need their own layer.


## T-26 · Chapters are defined in the scaffold, not in code
**Status:** Settled · v0.11

**Chose:** `chapterDefs` and `places` move out of `build-life.py` and into `demo/alston.scaffold.json`. A
chapter selects its photographs by caption list, by date range, or both. Deleting a chapter means deleting
its entry, and its curated output is pruned automatically on the next build.
**Over:** Leaving them as Python constants, which is where they started because the first version was a
one-off migration script.
**Because:** Chapters are content, and content the author edits every week does not belong in code. Adding a
trip should not mean opening a `.py` file and matching a tuple's shape.
**Costs:** Chapter ids are now only validated at build time — a typo in `learnings` or a `captions` entry
that matches nothing fails quietly, printing a skip line that is easy to miss in a long build. The date-range
form is also greedy: it claims every photograph in the window, so two trips in one week need caption lists
instead.
**Also:** the move surfaced a real bug. Two `places` keys had been written from a truncated terminal display
— `"Grinnell Glacier, Glacier"` and `"Samuel H. Boardman Scenic"` — and matched no caption at all, so two
photographs were silently dropped from their chapters while two map pins were fabricated for captions that
do not exist. The caption-driven rebuild exposed both. `--list-photos` now prints captions at full width for
exactly this reason.
**Revisit when:** A typo'd id costs real time. The build should validate ids against the record and fail
loudly rather than skip.
