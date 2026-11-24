# Remnant — Requirements

What the product is for, what it must do, and where the stated requirements currently
conflict with each other or with what is built. Decisions already made and paid for live in
[TRADEOFFS.md](TRADEOFFS.md); this document is the forward-looking half.

**Status key** — `Shipped` · `Next` · `North star` · `Stated, not built` · `Open question`

---

## 0. The thesis

Everyone who will ever know you arrives mid-story and meets whichever version you already
are. Your children will meet you tired, formed, "fine" — never the person figuring it out
right now. You are the only continuous witness of your own life and the only one who cannot
see it from outside.

The record exists to make the current version of a person legible to people who structurally
cannot see it. **Death is one delivery trigger, not the premise** (T-07).

The evidence that this is felt widely: five independent creators in late 2026 reaching
488K / 59K / 57K+ engagements on the same realisation — *there is a version of my parents I
will never meet*, *they were my age once*, *I only ever met the tired version*. One of them
is manually filming an interview project with his parents because no tool does this.

---

## 1. Delivery

### 1.1 Temporal lock and post-mortem release — `Stated, not built`
Records stay sealed until a trigger fires: a named milestone, or the creator's death.

**Open question — the word "legally-bound."** Probate, jurisdiction and executor authority
are not things an application can assert. The defensible claim is *executor-released, with a
notification window and a grace period*. Do not publish a legal guarantee the product cannot
honour.

### 1.2 Age-match trigger — `Next`
**The gap in the category.** Capsules today unlock on a calendar date. A letter timed to a
child's 18th birthday is received *by an adolescent*. A letter keyed to the age the creator
was when writing it is received *by a peer*.

> Decryption based on the recipient's age matching the creator's age at the time of recording.

The psychology is the point: the child opens it at the exact life stage the parent was
living through, so maturity levels align and empathy becomes possible rather than merely
requested. This is the mechanical expression of what those reels are all mourning — that the
recognition of a parent as a peer arrives by accident, decades late, and usually too late.

**Prerequisite:** the record must be indexed by age, not year. See 1.3.

### 1.3 Age as a first-class axis — `Next, cheap`
Every entry carries the subject's age alongside its date, and the timeline scrubs by age.
Required for 1.2, and it is the only way two people's records ever align. Buildable against
the current record in about an hour.

### 1.4 Context triggers — `Open question`
Proposed: *"open when you go through a heartbreak" · "when you are lost in your career" ·
"when a market correction occurs equivalent to the one I survived."*

**Split these.** Age and market data are computable. **Emotional state is not**, and the only
routes to it are self-report or inference.

**Inference is out of scope on principle.** An algorithm deciding a person is sad enough to
receive their dead parent's letter is the version of this product we will not build. It is
the same line as T-09 (no generated speech in a dead person's voice) and T-15 (retrieval
fails closed).

**Therefore: a shelf, not a trigger.** Labelled doors the recipient opens when they decide
they are ready — *"for when you lose someone," "for when you want to quit."* The person in
pain declares the moment. This is also better product: it hands control to the grieving
party rather than surprising them.

---

## 2. Mutual blind disclosure — `North star`

Existing platforms assume one active author and one passive recipient. This inverts that.

**How it works.** Two people separately answer the *same* prompt at different points in their
lives — *"What is your biggest unstated fear right now?"*, *"What dream did you have to let go
of this year?"* The first answer is sealed. When the second person answers the same prompt,
the vault detects the match and unlocks both, side by side.

**The psychology.** It demonstrates to the younger person that their current private battle
is an exact mirror of one already fought in their family. It attacks the isolation of the
experience rather than describing it.

**Why it is the most monetizable thing here** — and the reason is not "two accounts pay more."
**The unlock condition is another person's participation.** The vault stays shut until your
mother answers. Invitation stops being a growth tactic and becomes the mechanic. Nothing else
in the category has that property.

### 2.1 Do not require a generation gap — `Requirement`
As originally specified — parent answers at 35, child answers at 35 — nothing unlocks for
thirty years. That is a product with no feedback loop for a generation, and it reintroduces
precisely the problem the pivot escaped: value arriving only after the payer is gone.

**The mechanic must run at any age gap between any two people.** Siblings, partners, a parent
and a 25-year-old both answering about *this* year. *"What did you let go of this year?"*
unlocks in a week. The thirty-year version is the showcase; the one-week version is the
business, and the one that can be demonstrated.

### 2.2 Non-matching answers — `Open question`
The mechanic promises recognition. Sometimes the answers will not rhyme — the parent's fear
at 35 was money, the child's is something else entirely. A flat reveal after a long wait is
worse than no reveal. Unresolved.

---

## 3. Privacy and custody

### 3.1 Zero-knowledge architecture — `Stated, not built`
The platform is a blind vault. Password and biometric keys derive decryption keys **on the
user's device**. The server never sees plaintext files, the master password, or unencrypted
memory contents.

### 3.2 Multi-guardian cryptographic sharding — `Stated, not built`
No single automated system decides whether someone has died. The master release key is split
into three shares held by distinct trusted circles — e.g. a family member, a legal
representative, a lifelong friend. **Two of three** must upload their fragments to satisfy a
post-mortem release condition. No individual guardian can force the vault open early.

**Open questions:** guardians lose keys, change relationship, or predecease the creator.
Shares need rotation and replacement without re-sealing the vault. Two colluding guardians
is the explicit trust boundary — say so plainly rather than implying it cannot happen.

### 3.3 Dead man's switch pulse — `Stated, not built`
A passive check-in every 6 or 12 months. Consecutive misses open a grace period, alert the
guardians, and begin the legacy transition sequence.

**Required constraint (T-07):** a missed pulse must never, by itself, release anything. For
any consumer product, **disengagement is indistinguishable from death and vastly more
common.** The pulse raises a question; guardians (3.2) answer it. Delivering a death letter
about someone who is alive is the one unrecoverable failure available here, so the system
biases toward under-firing: notify the author on every channel, wait, then ask the guardians.

---

## 4. AI under a zero-knowledge constraint

### 4.1 Sandboxed local models — `Scoped by §4.3`
Transcription, memory cross-referencing and similar tasks run **on the user's own device**,
not by shipping raw audio and text to a central server.

### 4.2 Contractual data firewalls — `Required for everything §4.3 permits`
Any cloud processing must use temporary, **zero-retention** endpoints, so personal
vulnerabilities, financial difficulty and family secrets never enter commercial training
pools.

### 4.3 Resolved — the seal is the boundary — `Decided, partly built`

**The conflict, as it stood.** Remnant sends the record — timeline, achievements, the
person's own written learnings — to the Claude API for era derivation and ranking (T-16,
T-24), sends downscaled photographs for curation (T-25), and sends the day-one answers for
follow-up and naming (T-30). That is cloud processing of exactly the material §4.1 and §4.2
said must stay local. Three routes were open: everything local, split the vault, or
zero-retention cloud for everything.

**Decided: split the vault (T-37).** The rule is one sentence:

> **Before the seal, a record is a tool you are using. After the seal, it is mail nobody
> can open.** The seal is the boundary, and nothing crosses it in the direction of a model.

| | Processable in the cloud | Never |
|---|---|---|
| A record being written or edited | ✓ zero-retention, §4.2 | |
| A day-one sitting in progress — follow-ups, naming | ✓ | |
| Era derivation, ranking, photo curation | ✓ | |
| Anything past its seal point, awaiting a trigger | | ✗ encrypted client-side, no model ever |
| A capsule in transit to its recipient | | ✗ |

This resolves the contradiction honestly rather than by weakening §3.1. Zero-knowledge was
always the right promise for *capsules* and was never the right promise for a drafting tool —
the strongest feature of this product is the quality of the model's judgment while you write,
and the one thing that must be inviolable is the letter after you have sealed it. Collapsing
those two into a single guarantee is what produced the contradiction.

**The author is not a third party.** A person can always decrypt their own capsules; they hold
the key. So re-reading an old sealed record and asking the model about it is permitted — but
only as an **explicit act by the author in session**, never automatically, because the moment
it is automatic the system is deciding to decrypt rather than the person. This was a live
violation: drift analysis read a prior sealed record and shipped it to the API without being
asked (fixed in T-38).

**What is still not built, and therefore still may not be claimed.**
Sealing today means a flag in localStorage. There is no client-side encryption, no key
derivation, no guardian sharding (§3.2). The *rule* is decided; the *cryptography* is not.

> Until §3.1 is implemented, the product may describe the boundary and may not claim it is
> enforced. "Sealed capsules are never sent to a model" is true today and is a policy
> statement. "The server cannot read your capsules" is not true today, because there is no
> server and no encryption — and it must not be written anywhere until both exist.

### 4.4 Multilingual capture — `Next`
Built-in audio and video recording with transcription and translation. The specific need:
second-generation and immigrant families whose parents' best material exists only in a
language the children are losing.

**Design call:** keep the **audio as primary and treat text as the index.** Most products do
the reverse because text is cheaper to store and search — but voice, laughter and speech
rhythm are the thing families actually want, and transcription destroys exactly that.

### 4.5 Shareable extracts — `Open question`
Proposed: export quote cards or audio snippets to Instagram and TikTok as an organic growth
loop.

**Note the tension.** The most shareable material is the most private, and the product's
strongest AI decisions are all restraint (T-09, T-15). "Export your breakthroughs to drive our
growth loop" undercuts that in the same breath. If built: opt-in per entry, never prompted
after an emotional one, and never defaulted on.


### 4.6 Extraction from the user's own albums — `Next, in a reduced form`

**The proposal.** A person hands over an album of photographs and video; the system
extracts what it can and produces the scaffolding of a record, so that starting does not
mean typing a life in from nothing. The onboarding problem is the real one — it is why
the archive in §5 took weeks and why almost nobody would repeat it (T-30).

**Why this is not the same as importing socials.** An earlier version of this idea pulled
from Instagram, Facebook and LinkedIn. That one fails on its own premise: social history
is the *performed* record, the nine frames chosen for an audience, which is the exact layer
§0 says the product exists to get underneath. A camera roll is the opposite. It holds the
twelve hundred that were taken — the bad frame, the one where someone is crying, the forty
near-identical attempts at a shot that mattered. The unposted material is evidence; the
posted material is a claim. Only the first is worth building on.

It is also the only version that is practically available. Meta's Graph API does not expose
a usable history, LinkedIn's is effectively closed, and scraping meets a login wall. A file
the person chooses themselves has no such gate, and the browser already reads it (T-19, T-25).

#### 4.6.1 Source, never record — `Requirement`
Extracted material is **raw input, labelled and attributed as such.** The record is only what
the person writes against it. This is not a stylistic preference:

> The page states that everything in the archive is real and none of it is reconstructed.
> A generated caption is a fabricated memory. The moment one is stored as record, that
> sentence is false, and it is carrying most of the product's credibility.

The operating rule: **the model may say what it sees, and what it noticed. Never what it
meant.** "Eighty-three photographs, one location, April 2019" is observation. "A joyful
week with family" is invention, and belongs to the person or to nobody.

#### 4.6.2 What is worth extracting — `Design call`
The obvious extraction — faces, places, dates, auto-albums, *your trip to Lisbon* — is what
Google Photos and Apple Photos already do, free, on-device, against a library they already
hold. Competing there is losing on someone else's ground.

What nothing else computes, because nothing else has a reason to:

| Signal | Why it is worth a question |
|---|---|
| **Who is behind the camera** | The person appearing in none of the photographs is often the one holding the family together. Absence from the frame is the finding. |
| **Density anomalies** | Four hundred photographs in a week, then nothing for five months. The gap is the story, and it is arithmetic. |
| **Who stops appearing** | A face across six years and two hundred frames, then never again. No one writes that prompt for themselves. |
| **Near-duplicates** | Forty attempts at one shot is a record of having cared how it came out. |

Each resolves to a **question**, which is the day-one flow's input (T-30). The extraction is
not the output; it is what makes the interview specific. A prompt that already knows the
date, the place and who was in frame is a different instrument from a blank box.

#### 4.6.3 Video and audio are the larger case — `North star`
A photograph is silent. Video carries **the voice** — speech, laughter, cadence, and the
language itself. This is §4.4 arriving from the other direction: the material that second-
generation families are actually losing is not a list of events, it is the sound of someone
talking. A family video holds a grandmother speaking Hainanese; nothing the family writes
down substitutes for it.

So the two cases should be scoped apart rather than as one feature. **Photographs save
manual work. Video is itself the artefact**, and the §4.4 rule applies to it directly: keep
the audio as primary and treat the transcript as the index.

#### 4.6.4 What this costs, and what ships first — `Constraint`
Full extraction is the most expensive thing in this document: per-image vision calls, face
clustering, duplicate detection, and a video pipeline that cannot live in a browser-only app
with localStorage. It also lands squarely on §4.3 — an album is a far larger disclosure than
a timeline, and shipping it to a cloud model widens the contradiction rather than resolving it.

**Therefore the first version reads metadata only.** Dates and coordinates come out of EXIF
in the browser, with no model call, no upload and no per-image cost. Density, gaps, clustering
by place and the resulting questions are all arithmetic on that metadata. It demonstrates the
whole thesis — *import is scaffold, the question is the product* — for a fraction of the cost,
and it is the only version that is honest about §4.1 today, because nothing leaves the device.

Vision over image content is a second stage, gated on §4.3 being resolved.

---

## 5. What already ships

| | |
|---|---|
| A day-one flow: four present-tense questions, one named reader, sealed | T-30, T-31 |
| An AI interviewer that may decline to ask, and shows the refusal | T-32 |
| Age stamped at the time of writing, so age-matched delivery needs no backfill | T-30 |
| An explorable record — timeline, map, chapters, learnings | T-01, T-11, T-22 |
| Real inference for era grouping and ranking, with provenance | T-16, T-24 |
| Photo curation with per-frame reasoning, staleness-checked | T-25, T-27 |
| Reasoning shown in one repeated affordance, overrulable | T-13 |
| What the model declined to promote, and why | T-14 |
| Retrieval that returns nothing rather than inferring | T-09, T-15 |
| Per-entry visibility, shape kept and contents withheld | T-18 |
| A record that states how it was built, including what was reconstructed | T-30 |

**Not yet shipped, and the honest gap:** a day-one record cannot render in the explorer. The
claim that twelve sittings become the archive is currently stated rather than demonstrated,
and §4.6 is the route that closes it.

The through-line from here to the north star: **the product's job is to put two people at the
same age in the same room — and nothing else can do it, because nothing else holds both lives.**
