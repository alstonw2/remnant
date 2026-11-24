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
| T-09 | Retrieval-and-quote over generative persona | **Revised v0.15** |
| T-10 | Advance directives demoted out of step 2 | **Open** |
| T-11 | Lead with a populated life, not an empty form | Settled |
| T-12 | The whole demo lives in one swappable JSON file | Settled |
| T-13 | Every AI decision shows its reasoning, in the same affordance | **Revised v0.4** |
| T-14 | Surface what the model *declined* to promote | Settled |
| T-15 | Voice lookup fails closed | Settled |
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
| T-27 | Curation carries a fingerprint of what it saw | Settled |
| T-28 | Every entry states whether it has a place | Settled |
| T-29 | Cloud AI today, against a stated zero-knowledge requirement | **Revised v0.16** |
| T-30 | First sitting asks for today, not for a life | Settled |
| T-31 | Day-one records keep their own storage key | Settled |
| T-32 | The model may decline to ask, and that is shown | Settled |
| T-33 | An unnamed record over a title nothing stands behind | Settled |
| T-34 | Album extraction reads metadata before it reads pictures | Settled |
| T-35 | The day-one flow opens on a finished example, not on the ask | Settled |
| T-36 | Restraint is kept in the sealed record, not just shown live | Settled |
| T-37 | The seal is the privacy boundary, not the product | Settled |
| T-38 | Drift is an explicit act by the author, never automatic | Settled |
| T-39 | The follow-up turns on the subject, not the most concrete noun | Settled |
| T-40 | A follow-up the author declines is kept as declined | Settled |
| T-41 | The example letter waits for a second click | Settled |

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
**Status:** Revised · v0.2, amended v0.15

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
**Amended v0.15:** the lookup UI is removed. The principle stands and is unchanged — nothing will speak in a
dead person's voice — but the feature only carries weight when the person genuinely cannot answer. On a living
author's own record a visitor can simply ask them, so the section demonstrated a mechanism without the
situation that gives it stakes, against an archive of nine passages. The corpus it searched is retained and
still feeds the derivation prompt, which weighs a person's own words when ranking what mattered. Rebuild the
lookup when a record belongs to someone who is gone.

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


## T-27 · Curation carries a fingerprint of what it saw
**Status:** Settled · v0.12

**Chose:** Each curated chapter stores a hash of the exact set of photographs it was curated from. Every
later build compares it to the current set and says plainly when they differ; `--curate-stale` re-curates
only those chapters.
**Over:** Trusting cached curation indefinitely, or re-curating everything whenever photos change.
**Because:** The archive grows — photographs get added to trips that were curated months ago. Without a
fingerprint the page would keep showing the old six frames and the old "6 of 13" against a chapter that now
holds twenty, and nothing would say so. That is the worst failure mode available here: not a visible error
but a quiet lie about what the model actually chose from. Re-curating everything instead would be correct
and wasteful — most chapters do not change.
**Costs:** The fingerprint is over photo URLs, so it catches additions, removals and reordering but not a
photograph replaced at the same URL. It also marks a chapter stale when slides are hand-edited, which is
technically right and will read as a false alarm to whoever did the editing.
**Revisit when:** Photographs start being replaced in place rather than added. Then the hash needs to cover
content, not URLs.


## T-28 · Every entry states whether it has a place
**Status:** Settled · v0.13

**Chose:** A pill under every timeline entry naming its place, or saying "No location" when there is none.
Tagged ones take you to the pin — scrubbing the year forward first if the pin does not exist yet at the
current position, then centring, opening the popup and flashing the marker.
**Over:** Showing the pill only where a place exists, which is the tidier design.
**Because:** The absence is information. A record of a life should be able to say "this happened somewhere
and I have not said where" — and on the authoring side it turns the timeline into a worklist, the same role
the coverage strip plays for years. Hiding the empty state would make an untagged entry indistinguishable
from one nobody has looked at.
**Costs:** Thirty-eight of fifty-five entries currently say "No location", which is a lot of visual noise
for an absence, and it will stay noisy until most are tagged. The button also moves the scrubber as a side
effect, which is the right behaviour but is the only control on the page that changes two things at once.
**Revisit when:** Most entries are tagged. At that point the empty pill has done its job and could be
dropped, or shown only while authoring.


## T-29 · Cloud AI today, against a stated zero-knowledge requirement
**Status:** **Revised v0.16 — superseded by T-37.** Kept because the open period, and what
was shipped during it, is part of the record.
· v0.14

**Chose (so far):** Era derivation and ranking go to the Claude API carrying the record —
timeline, achievements, and the person's own written learnings. Curation sends downscaled
photographs. Nothing runs on-device.
**Over:** Local models, which is what `docs/REQUIREMENTS.md` §4.1 says the product must use.
**Because:** The page exists to demonstrate the quality of the model's judgment, and on-device
models are materially weaker at exactly that. Shipping the weaker version would have meant
shipping nothing worth showing.
**Costs:** The product cannot currently claim zero-knowledge, and the requirements document
says it must. That is a live contradiction, not a deferred nicety — anything written publicly
about a blind vault is false until it is resolved.
**Revisit when:** Before any privacy claim is published. The most coherent resolution is
splitting the vault: the *living record* stays processable, *sealed capsules* stay opaque
until triggered. Your record is a tool you use; your capsules are mail nobody can open.


## T-30 · The first sitting asks for today, not for a life
**Status:** Settled · v0.15

**Chose:** A second surface, `#dayone`, that asks four present-tense questions, once, addressed
to one named person, and seals the result. The timeline is treated as an **output** of repeating
that sitting, not as something the user fills in up front.
**Over:** Making the explorer authorable — a blank version of the archive that a new user
populates with their own events, chapters, places and photographs.
**Because:** The blank archive is a months-long homework assignment, and that is the actual
reason records like this never get written. It also produces the wrong artefact: an archive is
written *about* the past and is therefore remembered, while twelve present-tense sittings are
written *from inside* the year. Only the second can honestly carry the claim the page already
makes — that none of it is reconstructed.
**Costs:** The product now has two surfaces to maintain and explain, and a first-time user sees
one entry where the demo shows fifty-six. There is no bridge yet between a day-one record and
the explorer's shape, so the promise that one becomes the other is currently stated rather than
demonstrated.
**Revisit when:** A day-one record can render in the explorer. At that point the two surfaces
are one product with two zoom levels, and the landing page should say so.

## T-31 · The day-one record keeps its own storage key
**Status:** Settled · v0.15

**Chose:** `remnant_dispatch_v1`, separate from the wizard's `remnant_v2`, with its own save
path — though it reuses `pushRevision` so revision semantics cannot drift between the two.
**Over:** Extending `remnant_v2` with a new entry kind, which is where this data arguably belongs.
**Because:** `remnant_v2` is read back out of the DOM by `syncEntriesFromDom`, so it only exists
coherently while the wizard is on screen. A first sitting that failed halfway should not be able
to damage a record someone has been keeping for years.
**Costs:** Two stores, so a future merge has to reconcile them, and a user who has used both has
their life in two places. Export will have to read both.
**Revisit when:** Day-one records need to appear in the explorer, which is the point at which
one store becomes unavoidable.

## T-32 · The model may decline to ask, and that is shown
**Status:** Settled · v0.15

**Chose:** The follow-up prompt can return `withheld: true` — no question at all — when an answer
discloses acute distress. The refusal renders as a card of its own, in a different colour from a
question, carrying the model's reason.
**Over:** Always asking something, or silently skipping with no explanation.
**Because:** The whole surface is an interview, and an interviewer who presses someone describing
a parent's diagnosis to produce better material is the version of this product not worth building.
Showing the refusal rather than hiding it is also the single most useful thing on the page for a
reader assessing judgment: most AI features demonstrate a model generating more.
**Costs:** It is the model's call, so it will sometimes withhold where a question would have been
welcome, and the user has no way to ask for one anyway. A withheld follow-up also costs a call and
returns nothing visible but a sentence.
**Revisit when:** Real sittings exist to check it against. If it withholds on answers that were
merely sad rather than acute, the threshold in `demo/dispatch-followup-prompt.txt` is too low.

## T-33 · An unnamed record over a title nothing stands behind
**Status:** Settled · v0.15

**Chose:** If the naming call fails, the entry seals anyway and renders as "Unnamed", saying which
step did not run.
**Over:** A local fallback title built from the date, the recipient, or the first few words.
**Because:** The same rule as T-15 — fail closed rather than infer. A plausible-looking title the
model never produced is indistinguishable, later, from one it did, and the naming is the part a
reader is being asked to judge.
**Costs:** Without a key the product's most visible output is an empty slot, which demos badly. The
honest version is less impressive than the dishonest one, which is the usual shape of this tradeoff.
**Revisit when:** Never, unless naming moves on-device, at which point there is no failure to handle.


## T-34 · Album extraction reads metadata before it reads pictures
**Status:** Settled (scope) · v0.15

**Chose:** The first version of album extraction reads EXIF only — dates and coordinates,
in the browser, with no model call and no upload. Density, gaps, place clustering and the
questions that come out of them are arithmetic on that metadata.
**Over:** Per-image vision over the album, which is the version the idea sounds like and the
version every competitor will ship.
**Because:** The expensive half mostly reproduces what Google Photos and Apple Photos already
do for free against a library they already hold, while the cheap half carries the entire
argument — that an import is scaffolding and the *question* is the product. Metadata alone
supports "eighty-three photographs, one location, April 2019, then nothing for five months",
which is a better interview prompt than anything a caption model returns. It is also the only
version that is honest about §4.1 today, because nothing leaves the device.
**Costs:** No faces, so "who stops appearing" and "who is behind the camera" — the two most
distinctive signals in §4.6.2 — are not available in the first version. Photographs without
EXIF, or stripped of it by a messaging app, contribute nothing at all. Demos worse than the
vision version, which is the usual shape of this tradeoff.
**Revisit when:** §4.3 is resolved. Vision over image content is stage two and should not ship
before the cloud/local question has an answer, because an album is a far larger disclosure
than a timeline.


## T-35 · The day-one flow opens on a finished example, not on the ask
**Status:** Settled · v0.16

**Chose:** The opening screen renders a complete sealed record — `demo/example-dispatch.json`,
an invented person, labelled as such — using the same `d1LetterHtml` component the real thing
uses. No API key, no ten-minute exercise, nothing to fill in before the artefact is visible.
**Over:** Leading with "Record today · Ten minutes. Four questions.", which is what shipped
first and is what the flow asks of someone who has not yet seen why they would.
**Because:** This is T-11 applied to the second surface. The explorer opens on a populated
life for exactly this reason and the day-one flow shipped without the same treatment — a
visitor was asked for ten minutes and a credential before anything demonstrated what they
would get. Anyone evaluating the product rather than using it leaves at that point, and the
most important behaviour in the whole project, the model declining to ask, was behind that gate.
**Costs:** The example is fictional on a page whose credibility rests on the archive being
real, so it has to be labelled hard and in the same breath — one careless reading and the
no-reconstruction claim is damaged. It is also one more file that can drift from the product;
sharing `d1LetterHtml` limits that but does not remove it.
**Revisit when:** A real first sitting exists to put there instead. An invented example is the
weaker version of this and should be replaced rather than kept.

## T-36 · Restraint is kept in the sealed record, not just shown live
**Status:** Settled · v0.16

**Chose:** A withheld follow-up renders inside the sealed letter, carrying the model's reason,
and answered follow-ups carry the "why it asked this" chip into the record too.
**Over:** Showing the model's turn only during the sitting, which is what shipped first.
**Because:** A letter that recorded only the questions the model *did* ask would hide the one
decision worth seeing, and would make the record a misleading account of how it was made. It
also means a reader arriving months or decades later can see what was asked of the writer and
what was deliberately not — which is part of the provenance, not decoration.
**Costs:** The sealed letter is longer and carries machine commentary into something addressed
to a person, who may not want the interviewer's notes in their inheritance. A per-record choice
about whether the model's turn survives into delivery is probably correct and does not exist yet.
**Revisit when:** Letters are actually delivered. At that point "what the recipient sees" and
"what the record holds" stop being the same thing and must be separated.


## T-37 · The seal is the privacy boundary, not the product
**Status:** Settled · v0.16 — supersedes T-29

**Chose:** Split the vault at the seal. A record being written is a tool the author is using
and may be processed in the cloud under zero-retention terms (§4.2). Anything past its seal
point is mail, is encrypted client-side, and no model ever sees it.
**Over:** (a) everything local, which honours §3.1 completely but ships materially weaker
judgment, and judgment is the only thing this product is really demonstrating; (b) zero-retention
cloud for everything, which is simplest and rests the whole promise on a contract rather than on
mathematics — a different promise from the one §3.1 makes.
**Because:** Zero-knowledge was always the right guarantee for *capsules* and never the right
guarantee for a drafting tool. Collapsing both into one promise is what produced the
contradiction in the first place; the requirement was over-broad, not the implementation wrong.
Stating the boundary as one sentence — *before the seal it is a tool, after the seal it is mail* —
resolves it without weakening the part that matters.
**Costs:** The living record, which is most of what a person writes, is processed in the cloud,
and "zero-retention" is a contractual claim rather than a mathematical one. Anyone who expected
§3.1 to cover everything they ever typed will read this as a retreat, and they would not be
entirely wrong. The split also puts a sharp edge in the product that has to be explained to
users at exactly the moment they are least interested in reading about architecture.
**Revisit when:** On-device models close the judgment gap. At that point route (a) becomes
available without sacrificing the demonstration, and this entry should be revised again rather
than defended.

## T-38 · Drift is an explicit act by the author, never automatic
**Status:** Settled · v0.16

**Chose:** Comparing a new sitting against an earlier sealed one is offered on the finished
letter as a button, and runs only when pressed. The copy says plainly what pressing it does:
unseals the earlier record and sends both to the model.
**Over:** Running it automatically at seal time, which is what shipped in T-30 and which read
a sealed record and sent it to the API without being asked.
**Because:** T-37 says nothing crosses the seal toward a model on its own. The author is not
a third party and may always re-open their own record — they hold the key — but the moment it
happens automatically it is the *system* deciding to decrypt rather than the person, which is
precisely the thing the boundary exists to prevent. This was a live violation of a rule written
in the same session, which is an argument for writing rules down where the code can be checked
against them.
**Costs:** Drift is the hook that makes a second sitting worth doing, and it is now behind a
button carrying a deliberately off-putting sentence. Fewer people will see the feature that most
justifies coming back. That is the correct trade and it is still a real cost.
**Revisit when:** Capsules are actually encrypted. The question then becomes whether an author
re-opening their own capsule should need to re-authenticate, which is a different decision.


## T-39 · The follow-up turns on the subject, not on the most concrete noun
**Status:** Settled · v0.16

**Chose:** `dispatch-followup-prompt.txt` now says to find what the answer is *about* before
finding something specific inside it, and names the failure directly: a date, age, place or
person used as a comparison is a frame the writer built to say something else with.
**Over:** The original instruction — "turn on a specific noun, name, place or moment the person
used themselves" — which is what shipped and which reads well until it meets real writing.
**Because:** Caught by the first real sitting. Someone wrote that their parents had a child at
26 and that they are 28 and not where they wanted to be; the model asked what the parents were
doing at 28. It wrote that it felt young three years ago and still does; the model asked what
it was doing three years ago. Both questions turned on the most concrete token available and
both missed the subject entirely — the author called them irrelevant, and they were. A
follow-up that asks about the measuring stick rather than the thing being measured reads as
not having listened, which is worse than asking nothing (T-32).
**Costs:** "Find the subject" is a vaguer instruction than "turn on a specific noun", and vaguer
instructions are harder to hold a model to; expect more variance. It also makes the restraint
path more attractive to the model than it should be, since declining is now the easier way to
satisfy a harder rule.
**Revisit when:** Enough real sittings exist to see whether follow-up quality or the withhold
rate moved. If withholds climb, the rule overcorrected.


## T-40 · A follow-up the author declines is kept as declined
**Status:** Settled · v0.16

**Chose:** When the model asks a follow-up and the author chooses not to answer it, the sealed
letter renders the question with an explicit **Left unanswered** card — the question, the
model's reasoning for asking it, and the fact that it was turned down.
**Over:** Dropping the exchange, which is what the code did until now. An unanswered follow-up
rendered as nothing at all, so the letter looked like one where every question got an answer.
**Because:** This is T-36 pointed the other way. T-36 kept the model's restraint in the record;
this keeps the author's. Both exist because the interesting content of a sitting is where it
stopped, and both failure modes are the same failure mode — a record that quietly edits itself
into a cleaner record than the one that was written. Caught the same way as T-36 and T-39: by
actually sitting down and answering, and then declining one. The real example now ships with
one withhold by the model and one refusal by the author, which is a more honest demonstration
than four clean exchanges.
**Costs:** Three of four questions in the shipped example now carry some form of negative space,
which makes the surface read as more fraught than a first sitting usually is. A visitor skimming
may read the gold and grey cards as errors rather than as the point. The note under the letter
has to do the work of explaining that, and notes explaining a design are a sign the design is
not self-evident.
**Revisit when:** The shelf holds enough real sittings to tell whether declining is common or
whether this example is unrepresentative.


## T-41 · The example letter waits for a second click
**Status:** Settled · v0.16

**Chose:** The opening screen shows the invitation — what the example is, whose it is, that it
is real — and the letter itself renders only when someone presses **Open the letter**.
**Over:** Rendering it on load, which is what T-35 shipped and what every instinct about
reducing friction says to do.
**Because:** Two reasons, and the second is the one that matters. The practical one: an unasked-for
wall of someone's interior life is not an onboarding screen, and a visitor who has not decided
to read it yet has no way to not read it. The real one: this product's entire claim is that a
sealed record is opened by a deliberate act, by one named person, at one moment. A page that
demonstrates that claim by auto-playing the contents of a sealed letter contradicts itself in
the first second. The click is small, and it is the product's own thesis applied to its own
demo.
**Costs:** Directly against T-11 and T-35, which say to lead with the populated artifact rather
than the ask. Some visitors will not click, and they will leave having seen a description of the
example instead of the example. That is a measurable loss of the thing the example was added to
fix. It is accepted because the alternative teaches the wrong lesson about the product in the
same breath as demonstrating it.
**Revisit when:** The invitation copy can be tested. If the click-through is poor, the fix is
better copy above the button, not removing the button.
