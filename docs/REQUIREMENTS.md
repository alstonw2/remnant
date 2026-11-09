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

### 4.1 Sandboxed local models — `Stated, not built`
Transcription, memory cross-referencing and similar tasks run **on the user's own device**,
not by shipping raw audio and text to a central server.

### 4.2 Contractual data firewalls — `Stated, not built`
Any cloud processing must use temporary, **zero-retention** endpoints, so personal
vulnerabilities, financial difficulty and family secrets never enter commercial training
pools.

### 4.3 This contradicts what is currently built — `Open, must resolve`
**Stated plainly because a requirements document that hides its own conflict is worthless:**

Remnant today sends the record — timeline, achievements, the person's own written learnings —
to the Claude API for era derivation and ranking (T-16, T-24), and sends downscaled
photographs for curation (T-25). That is cloud processing of exactly the material 4.1 and 4.2
say must stay local.

Three routes, none free:

1. **Everything local.** Honours 3.1 fully. On-device models are materially weaker at the
   judgment tasks the product is built to show, and the page's strongest feature is the
   quality of that judgment.
2. **Split the vault.** The *living record* is processable; *sealed capsules* are opaque until
   triggered. Your record is a tool you use; your capsules are mail nobody can open. This is
   the most coherent option and resolves the tension in one sentence.
3. **Zero-retention cloud for everything.** Simplest to build, weakest claim — it rests on a
   contract rather than on mathematics, which is a different promise from 3.1.

**Leaning toward (2).** Until it is decided, the product must not claim zero-knowledge.

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

---

## 5. What already ships

| | |
|---|---|
| An explorable record — timeline, map, chapters, learnings | T-01, T-11, T-22 |
| Real inference for era grouping and ranking, with provenance | T-16, T-24 |
| Photo curation with per-frame reasoning, staleness-checked | T-25, T-27 |
| Reasoning shown in one repeated affordance, overrulable | T-13 |
| What the model declined to promote, and why | T-14 |
| Retrieval that returns nothing rather than inferring | T-09, T-15 |
| Per-entry visibility, shape kept and contents withheld | T-18 |

The through-line from here to the north star: **the product's job is to put two people at the
same age in the same room — and nothing else can do it, because nothing else holds both lives.**
