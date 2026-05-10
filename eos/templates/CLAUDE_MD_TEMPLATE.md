# CLAUDE.md — [PRODUCT NAME]

> **What this file is.** The single source of truth that any AI
> collaborator (Claude Code, technical co-founder Claude, deployed
> roundtable agents) reads when working on this product. It tells
> them what the product is, how it's built, what the standards are,
> and what's currently in flight.
>
> **How this file is structured.** Two top-level sections:
>
> - **HQ STANDARDS** — synced from `rore-tech-hq`. Do not edit in
>   product projects. Updates flow HQ → products. The version line
>   at the top of that section records which HQ version this product
>   last synced from.
> - **PROJECT-SPECIFIC** — everything unique to this product.
>   Edited freely by the operator and by AI collaborators working
>   on the product.
>
> **How to use this template.** Copy this file into a new product
> project. Replace `[PRODUCT NAME]` and the bracketed placeholders.
> Fill the PROJECT-SPECIFIC section. Sync the HQ STANDARDS section
> from the current HQ version (record the version line). After that,
> only edit the PROJECT-SPECIFIC section in this product. HQ STANDARDS
> updates come from HQ.

---

# HQ STANDARDS

> **Synced from:** `rore-tech-hq` @ vX.Y on YYYY-MM-DD
> **Do not edit this section in product projects.** Updates flow from
> HQ at phase kickoff (pull) or when HQ flags a critical update (push).
> Editing in product projects breaks the cycle that lets standards
> sharpen over time. If something here is wrong for this product,
> raise it as a lesson via the intake protocol — the fix happens at
> HQ, not here.
>
> **Future automation hook.** A standards-sync agent will eventually
> automate the pull, verify the version stamp, and flag drift. Until
> then, the operator pulls manually at phase kickoff.
>
> **Lesson trace.** Every standard below cites the lesson IDs that
> justified it. When something feels wrong, follow the trace back to
> the source lessons in `eos/lessons/INVENTORY.md` — the lesson tells
> you whether to revise the standard or whether the situation
> genuinely doesn't apply.

---

## H1. Voice and hard rules (cross-product)

**Voice.** Confident, plainspoken, engineering-honest. Short sentences
when possible. Say what the product does and what it does not do. Do
not oversell. Do not use words like "revolutionary," "AI-powered"
(when the AI is just an SDK), or "military-grade." Treat the user as
intelligent.

**Cross-product hard rules — never violate.**

- Never imply or state that any user data is stored in the cloud, on
  RORE Tech servers, or anywhere off the user's device. Per-product
  exceptions, if any, are named in PROJECT-SPECIFIC P3.
- Never write copy that promises features the product does not have.
- Never give advice in a regulated category (financial advice,
  medical claims, legal advice) in any product copy or AI output.
- Never echo a user's real credential value into a code example,
  terminal command, sample request, or any other surface — placeholders
  only, regardless of context.
  *(Lessons: `xagent-LL-007`.)*
- Per-product hard rules layer on top of these — see PROJECT-SPECIFIC P3.

---

## H2. The three-layer model

This product operates inside RORE Tech's three-layer engineering
model:

```
Layer 1 — PLAYBOOK (HQ canonical)
    The standards. Lives in rore-tech-hq.

Layer 2 — CLAUDE.md (this file)
    HQ STANDARDS section (synced) + PROJECT-SPECIFIC section
    (this product's specifics).

Layer 3 — PHASE PROTOCOL (per phase)
    The plan for the current phase, including the Exit Gate at the
    end. One document per phase, in this product's docs/protocols/
    folder.
```

## H3. The cycle

Every phase in this product follows the same cycle:

1. **Adoption.** At phase kickoff, sync the HQ STANDARDS section of
   this file from the current HQ version. Update the version stamp
   above. Pull the current Phase Protocol template from HQ.
2. **Execution.** Write the Phase Protocol from the template. Run
   the phase. Walk the Exit Gate at the end.
3. **Reporting.** Generate a 5-line lessons-learned intake at phase
   close. Send to HQ.
4. **Update.** HQ reviews intakes, updates standards, versions them.
   Next phase pulls the updated version at adoption.

If any one of these four breaks, the system stops sharpening. The
operator owns each handoff; future agents will eventually automate
the mechanical parts.

## H4. Required artifacts in this product's repo

Every product project keeps these directories under `docs/`:

```
docs/
├── protocols/                # Phase Protocol documents (one per phase)
└── decisions/                # ADRs — architectural decisions worth recording
```

ADRs are required for any architectural decision that would be
expensive to reverse.

The following directories are created when first needed, not at
project bootstrap:

```
docs/
├── runbooks/                 # operational procedures (deploy, rollback, etc.)
└── checklists/               # local copies of HQ checklists used by this product
```

A runbook is needed the second time the operator asks "how did I do
this last time?" Until then, the operator's habit is enough.

A `checklists/` directory holds local snapshots of HQ checklists at
the version this product synced from. Created when the first HQ
checklist is synced into the project.

## H5. The Phase Exit Gate

Every phase ends with the Universal Phase Exit Gate Checklist. The
gate is included as a section inside the Phase Protocol document for
that phase, populated from the current HQ template at phase kickoff.
Project-specific gate items get added on top of the universal ones.

A phase is not done until the gate is walked. Not "the work is
finished" — until the gate is walked. Skipping the walk is the most
common silent failure mode.

## H6. The 5-line lessons-learned intake

At phase close, every phase generates a 5-line intake to HQ. Format:

1. *Phase and product:* which phase, which product, dates.
2. *What went well:* one specific thing.
3. *What slipped:* one specific gap, near-miss, or surprise.
4. *Process implication:* which checklist or standard, if any, should
   change.
5. *One-line ask of HQ:* the smallest concrete update requested, or
   "no change" if none.

Five lines. Not six. The constraint forces signal. Drafted intakes
that don't reach HQ count as no intake.

**Future automation hook.** A postmortem-extractor agent will
eventually draft this intake from the Phase Protocol document and the
Exit Gate walk. Operator still confirms before it ships to HQ.

## H7. The Roundtable

Every product project carries a copy of `ROUNDTABLE.md` in its
knowledge base. The Roundtable is silent by default. It activates only
when summoned with one of the protocols defined in that file
(`Roundtable this.`, `[Role] + [Role] only on this.`, `Devil's
advocate from [Role].`, `Quick check — any role concerned?`,
`Roundtable on [past decision].`).

When summoned in this product, each chair adapts its lens to this
product's specifics. Veto holders are Compliance and User Advocate.
Vetoes are overridden only with an explicit override sentence and an
entry in the Override Log in `ROUNDTABLE.md`.

## H8. Discipline standard

Four cycle handoffs. Each has a failure mode if skipped:

| Handoff | What breaks if skipped |
|---|---|
| Adoption | Project starts on stale standards |
| Execution (gate walk) | Setup gaps slip through |
| Reporting (intake) | HQ has nothing to update from |
| Update (HQ review) | Lessons accumulate; standards don't move |

The operator owns each handoff until the corresponding agent exists.

---

## H9. Single source of truth for canonical strings

**Rule.** Every canonical fact (legal entity name, governing law,
product names, package IDs, taglines, billing partners, version
codes, signing fingerprints, file paths) lives in exactly one place
in the HQ repo. Products reference it; they never restate it.

**Mirrors are redirects, never copies.** If a URL must exist at two
paths, one is canonical and the other is a 301. If a config file
must exist on two platforms, one is generated from the other or
both are generated from a third manifest.

**CLAUDE.md is the canonical chat-startup context.** No more pasted
context dumps. Pasted context that disagrees with CLAUDE.md is
flagged and reconciled, not absorbed.

**Pre-commit grep enforces.** The `.audit/` directory in every
product (see H10) includes deprecated-string patterns. Any deprecated
name, deprecated state, or deprecated billing language fails the
commit.

**Specific HQ artifacts referenced from product code:**
- `rore-tech-hq/org/LEGAL_ENTITY.md` — entity name, state of formation,
  governing law, registered agent address. Legal pages reference
  values from here, never restate them.
- `rore-tech-hq/org/PRODUCTS.md` — canonical product names, taglines,
  platforms, signing fingerprints (where shareable).
- `rore-tech-hq/org/BILLING_MATRIX.md` — per-product, per-platform
  billing surface (which provider, which dashboard).

*Lessons: `roretech-website-LL-001`, `LL-008`, `LL-009`, `LL-010`,
`LL-016`, `LL-018`; `vibespin-LL-008`, `LL-020`; `roreedge-LL-020`,
`LL-004`.*

---

## H10. Pre-submission and pre-deploy grep audits as standing process

**Rule.** Every product repo carries a `.audit/` directory of
versioned grep-pattern files, organized by category. The audit runs
as a pre-commit hook (fast subset) and as a pre-submission gate
(full audit). New patterns flow from HQ when surfaced anywhere.

**The audit is intentionally lightweight.** A folder of grep patterns
plus a thin shell wrapper. Not a CI matrix. Not a SaaS product.
Adding a pattern is a one-line PR; cost is near zero, value compounds.
If anyone proposes building this on a heavy CI infrastructure, push
back — the Vibe Spinner DEV-button-shipped-three-times bug needs a
one-line bash script, not Jenkins.

**Standard `.audit/` categories:**
- `stalkerware-patterns.txt` — for surveillance-adjacent products
  (Security SPY profile). Triggered code patterns even when unused.
- `deprecated-strings.txt` — old product names, old governing law,
  old billing partner language.
- `hardcoded-secrets.txt` — API keys, tokens, common secret patterns.
- `debug-affordances.txt` — `dev-btn`, `__debug__`, `console.log`,
  `TODO: remove`, etc.
- `asset-existence.sh` — every `<img src>` or favicon path in HTML
  resolves to a tracked file in the repo.
- `link-consistency.sh` — internal links use consistent extension
  conventions; no whitespace in filenames.

**Run order.**
- *Pre-commit:* the fast subset (stalkerware-patterns, hardcoded-secrets,
  debug-affordances) on the staged diff. Fails fast.
- *Pre-submission:* the full audit on the release artifact (the AAB,
  the AAR, the deployed bundle, etc.). Fails the submission build.

*Lessons: `securityspy-LL-001`, `LL-009`, `LL-010`; `vibespin-LL-002`,
`LL-004`; `roretech-website-LL-002`, `LL-003`, `LL-004`, `LL-008`;
`xagent-LL-007`.*

---

## H11. Loud failure beats silent skip

**Rule.** Every fall-through, default, skip, or "unknown input"
branch in every product produces a user-visible record. Either fail
loudly (throw with a clear message), log + count + surface to the
user, or — at minimum — emit a "skipped: N items, here's the list"
report. "Silently dropped" is never an acceptable outcome.

**Specific applications:**

- *Parsers and importers.* Every transaction code, every action
  verb, every date format has an explicit handler — including
  `SKIP` with a reason. Unknown codes log a "unhandled: X" warning
  the operator can act on. (DC-B in the inventory.)
- *Defaults.* Every default value (year, account, currency, etc.)
  is loud — emitted to a log or to the UI when used. Silent
  defaults are how Schwab dates became year 2001.
- *Hardcoded data.* Every hardcoded date, calendar, threshold has
  an `expires_at` or a TODO at scaffold time. Silently stale data
  is its own bug class.
- *Service deploys.* Every deployable service ships with a `/health`
  or `/diag` endpoint that returns the deployed git SHA, deployed
  timestamp, and a boolean for every required environment variable.
  After every deploy: wait 60s, hit `/health`, compare SHA against
  local HEAD. Treat auto-deploy as advisory, not authoritative.
  *(This applies to backend services. Mobile apps and desktop apps
  use phase-exit smoke tests instead — see H12.)*

*Lessons: `roreedge-LL-007`, `LL-008`, `LL-009`, `LL-021`;
`tradeedge-LL-008`, `LL-004`; `xagent-LL-005`, `LL-013`, `LL-016`;
`roreedge-LL-001`.*

---

## H12. Real samples, real devices, real artifacts before declaring "done"

**Rule.** A phase is not done until the deployed artifact runs
end-to-end against real input on the real target. CI passes is
necessary, not sufficient.

**Specific applications:**

- *Mobile apps.* Real-device smoke test of the released artifact on
  at least one physical device, end-to-end through the primary user
  flow added or changed this phase. Never run on a real device, never
  done. The VibeFire Phase 1 ClassNotFoundException would have been
  caught by `flutter run` on a Pixel.
- *Data pipelines.* Reconciled against a known-good external source
  (broker statement, accounting export, historical totals) before
  any phase shipping P&L or balance math. The Edge Journal -$6.5M
  fake loss would have been caught in seconds against the user's
  actual portfolio total.
- *Parser specs.* Real export samples obtained from every supported
  source before the spec is written. Hand-written examples are
  proxy data and they lie. Webull, IBKR, and TDA all use compound
  action verbs that no hand-written sample contains.
- *Web deploys.* Documented post-deploy verification: wait 60s, curl
  the canonical URL, grep for one known-changed string, check
  HTTP 200, verify the mirror URLs. Not "checked in browser."
- *Frontend fixes.* A JS data-pipeline fix is verified by *hard
  refresh + clear local state + re-run input from scratch*.
  Anything less is testing the previous build.

**Implementation didn't match plan.** A specific failure mode worth
naming: the plan correctly specifies a value (e.g., the `url` field
for Magic Link `ActionCodeSettings`), then implementation skips it.
A "verify implementation matches plan" check belongs in every Phase
Exit Gate where the plan was specific.

*Lessons: `roreedge-LL-001`, `LL-002`, `LL-014`; `securityspy-LL-004`,
`LL-017`; `tradeedge-LL-013`; `vibespin-LL-019`; VibeFire Gap 7,
Gap 8.*

---

## H13. Per-endpoint, per-operation, per-platform compliance is per-X

**Rule.** At kickoff for any project that touches an external
service, a compliance regime, or a payment surface, the operator
writes the per-endpoint / per-operation / per-platform matrix before
integration code begins. "We have the API key" is not the matrix.

**The matrix names:**
- Which dashboard owns the billing for each endpoint.
- Which scope or tier is required for each specific operation
  (read vs write vs automated post; free tier vs paid tier per
  endpoint, not per provider).
- Which disclosure surface covers which sensitive API (in-app
  prominent disclosure does not cover store-listing description;
  one prominent disclosure does not cover multiple sensitive APIs).
- Which billing provider is allowed on which platform (Stripe on
  web is fine; Stripe on Google Play violates policy).
- Which content rating system controls what (IARC content rating
  rates the content; Target Audience setting names the audience —
  these are not the same field).

**Reference artifact:** `rore-tech-hq/org/BILLING_MATRIX.md` (per-product,
per-platform) and the per-service-checklist family in
`rore-tech-hq/eos/checklists/` (Firebase, Play Store, App Store, AI
publishing, etc.).

*Lessons: `xagent-LL-001`, `LL-002`, `LL-003`; `tradeedge-LL-001`;
`securityspy-LL-002`, `LL-003`, `LL-006`; `vibespin-LL-005`, `LL-010`;
`roretech-website-LL-010`, `LL-013`.*

---

## H14. Single architectural concern per Claude Code session

**Rule.** Every Claude Code session has one architectural concern.
Two concerns means two sessions. Bundling "while we're in here"
changes multiplies the failure surface.

**Bug fixes use the BUG REPORT format, not prescriptive prompts.**

```
SYMPTOM: [what the user sees, on which device, with which input]
HISTORY: [when this started, what was changed, what was tried]
REQUIREMENT: [the invariant that must be true after the fix]
ACCEPTANCE TEST: [the specific check that confirms the fix]
```

Prescriptive prompts ("change line 42 to use `startsWith`") encode
the operator's current hypothesis, which may be wrong. They go
stale fast. Descriptive prompts let the agent investigate and
propose the right fix, and produce more durable solutions across
rebuilds.

**Temporary workarounds create immediate follow-up tickets in the
same commit.** A hardcoded credential, a deferred refactor, a
"we'll fix this properly later" — none of these are valid without a
P1 ticket attached at the moment the workaround is committed. AI
assistants do not frame workarounds as "we can fix it properly later"
without simultaneously creating the rotation/refactor ticket.

*Lessons: `roreedge-LL-022`; `vibespin-LL-018`; `tradeedge-LL-014`;
`xagent-LL-006`.*

---

## H15. Credentials and signing material at moment of creation

**Rule.** Credential and signing-material creation is its own
checklist, run at the moment of creation. Backup, password manager
entry, and (for irrecoverable material) two-location storage are
completed *before the next action*.

**Irrecoverable material — special handling:**
- Android keystores (`.jks`)
- Apple distribution certificates (after enrollment)
- Windows EV code-signing certificates
- Account-recovery codes for any platform that owns published apps

For each: stored at a project path covered by automated backup
(never `~/Desktop/`), password recorded in a password manager *at
creation time* (not later), file copy in at least two independent
locations before the first signed build runs.

**Recoverable but exposable material — different handling:**
- API keys, OAuth tokens
- Database credentials
- Service account JSON files

For each: rotated immediately after any exposure (chat paste,
accidental commit, hardcoded workaround). Hardcoded credentials in
code create an immediate rotation ticket *with the same commit*, not
later.

**HQ artifact:** `rore-tech-hq/eos/checklists/SIGNING_KEY_BIRTH_CERTIFICATE.md`
covers the moment-of-creation checklist for both categories. Run it
when each new credential or signing artifact is born.

*Lessons: `vibespin-LL-017`; `xagent-LL-006`, `LL-007`;
`roreedge-LL-017`.*

---

## H16. Privacy commitments are architectural constraints

**Rule.** Any feature that touches data flow, permissions, telemetry,
AI integration, or sample/demo data is reviewed against the product's
stated privacy commitments at *design time*, not at compliance-page
time.

**Specific rules:**

- A feature that violates a stated commitment either gets a
  dedicated, in-context consent surface — not buried disclosure —
  or it doesn't ship. If the product promises "your data stays
  local," any feature that sends data anywhere needs its own
  consent surface, not a ToS clause.
- Permissions and capabilities are declared *minimally*. Never
  "defensively." `SYSTEM_ALERT_WINDOW` declared "just in case" is a
  stalkerware signal. Capacitor plugins added "just in case"
  declare permissions for code paths that don't exist.
- Demo, sample, or test modes never share persistence with real
  user data. Sample data lives in memory only; real data lives in
  storage. Crossing the line breaks the privacy promise quietly.
- Product framing in privacy policies and store listings must match
  product framing in code and UX. "Silently captures" language in a
  privacy policy is a code change, not legal hygiene.

**The Roundtable's User Advocate chair already covers this** when
summoned. This standard exists so the design-time check happens
*before* a Roundtable would be summoned, not as a backstop.

*Lessons: `roreedge-LL-015`, `LL-016`; `securityspy-LL-015`, `LL-009`;
`vibespin-LL-002`.*

---

## H17. PWA / service worker scope on multi-product domains

**Rule.** Every product hosted under a shared domain registers its
service worker with an explicit `scope:` parameter equal to its
subfolder. No exceptions. SW scope is an emergent property of where
the script lives and what `scope:` is passed at registration —
defaulting it once will eventually take over the entire origin and
hijack sibling products.

**Specific requirements:**

- *Explicit scope.* `navigator.serviceWorker.register('/path/sw.js',
  { scope: '/path/' })`. Never omitted.
- *Versioned cache name.* `vibespin-v2`, not `vibespin`. Every deploy
  that changes a cached file bumps the version. Make it a step in
  the deploy script.
- *Recovery URL.* A `unregister-sw.html` page exists at every product's
  path. If a SW misbehaves, users (or the operator from a sibling
  product) can recover by visiting that URL.
- *Domain registry.* `rore-tech-hq/org/DOMAIN_REGISTRY.md` lists every
  product's SW scope on shared domains. New PWAs check the registry
  before registering.

**Applies to:** any product served from `roretech.com` or any future
shared RORE Tech domain that hosts a PWA. Does not apply to products
served from a dedicated subdomain or a separate domain entirely.

*Lessons: `vibespin-LL-003`, `LL-014`, `LL-016`; `roretech-website-LL-007`.*

---

## H18. Storefront truth — every claim maps to a built feature

**Rule.** Every feature listed in store metadata, paywall modals,
paid-tier descriptions, or marketing copy maps to a specific
function or screen in the *current* build. The mapping is documented
in the Phase Protocol for the release.

**Specific rules:**

- *Unbuilt features* are labeled "Coming soon" with a target version,
  or removed. Unlabeled aspirational features in a paid tier are
  Misleading Behavior policy violations on Google Play and on the
  App Store.
- *Brand assets* (badges, logos, trademarks) come from official
  sources only. Never redrawn, never approximated. Google Play
  badge, Apple App Store badge, partner logos — all downloaded from
  the canonical source with the canonical sizing and clear-space
  rules.
- *App-name field is a policy surface.* For surveillance-adjacent
  products, every word in the app-name field that connotes covert,
  hidden, or silent capture is a policy risk. Internal branding
  (subtitles, in-app copy) and store-listing app name are separate
  surfaces. Tag concerning words for in-app-only use.
- *Content rating ≠ Target Audience.* These are two distinct
  systems on Play Console (and equivalent on App Store Connect).
  IARC rates *content*; Target Audience names the audience.
  Filling the questionnaires correctly requires understanding
  which question controls which displayed badge.

*Lessons: `vibespin-LL-006`; `securityspy-LL-014`, `LL-003`;
`roretech-website-LL-005`, `LL-013`.*

---

# PROJECT-SPECIFIC

> Everything below is specific to this product. Edit freely. The
> HQ STANDARDS section above does not get edited in this file —
> if a standard is wrong for this product, raise it as a lesson.

---

## P1. What this product is

**Name.** [Product name as it appears in stores, on the site, in
copy. Include the ™ until USPTO registration issues.]

**One-line description.** [What it does, in one sentence, in the
voice from H1.]

**Platform(s).** [Android / iOS / macOS / Windows / Web / etc.]

**Distribution.** [Google Play / App Store / GitHub Releases / direct
download / etc.]

**Status.** [In development / live / sunset.]

**Current version.** [Latest released version, where to find it.]

## P2. Audience and positioning

**Primary audience.** [Who uses this. Be specific. Not "everyone."]

**Positioning.** [What this product is *vs.* what it could be
mistaken for. The non-obvious part of the framing — e.g., "owner-
protection, not surveillance" or "journaling, not advice."]

**What this product does NOT do.** [The things it could be expected
to do but deliberately doesn't. This is often more useful to
collaborators than the feature list.]

## P3. Per-product hard rules

> Layer on top of the cross-product hard rules in H1. These are the
> rules specific to this product that, if violated, are not just a
> bad call — they are a compliance, trust, or platform-policy break.

- [Rule]
- [Rule]
- [Rule]

## P4. Architecture overview

**Stack.** [Languages, frameworks, key libraries, platform SDKs.]

**Where data lives.** [On-device storage, encrypted vaults,
third-party services touched, what data flows where. Be precise —
this is the section the privacy page must match.]

**Third-party services.** [Each service this product uses, what it's
used for, where credentials live, what happens if it's unavailable.
For each service, the per-endpoint / per-operation matrix per H13.]

**Build and release.** [How the product is built, signed, and
shipped. Where artifacts go.]

## P5. Repository layout

```
[paste the actual repo tree here, one or two levels deep, with
a one-line note on each significant directory]
```

## P6. How to run this product locally

[The minimum a fresh contributor — or future-you in three months —
needs to get the product running from scratch. Environment variables,
credentials, setup commands. Reference any service-specific setup
checklists from HQ that apply.]

## P7. Compliance landscape (this product)

[The specific regulatory frame this product sits under. Pulled from
RORE_TECH_ORG.md Section 7 if relevant, plus anything product-
specific. Examples: Play Store stalkerware policy, BIPA biometric
rules, Investment Advisers Act framing line, RSI disclosure
requirements, COPPA boundary.]

[Each item should name what the line is and what would cross it.
"Avoid surveillance framing" is a posture; "store listing must say
'protect your device' not 'monitor someone'" is a line.]

## P8. Open items for this product

[Living list. Things known to need attention, scoped to this product.
Items get added when discovered, removed when resolved. The product's
deployed roundtable should refer to this when drafting work that
intersects with these items.]

1. [Item.]
2. [Item.]

## P9. Phase history

[One line per phase, oldest first. Acts as the product's institutional
memory at a glance.]

| Phase | Dates | Outcome | Phase Protocol doc |
|---|---|---|---|
| Phase 0 | YYYY-MM-DD → YYYY-MM-DD | [Shipped / killed / ongoing] | `docs/protocols/phase-0.md` |
| Phase 1 | ... | ... | ... |

## P10. Notes for AI collaborators specific to this product

[Anything an AI collaborator working on this product needs to know
that isn't covered above. Common conventions, naming patterns,
gotchas, "always ask before X," etc. Keep this section short — if it
gets long, the things in it probably belong in earlier sections.]

---

*Template version 0.2. Sourced from `rore-tech-hq`. Adds H9–H18
based on cross-cutting patterns in `eos/lessons/INVENTORY.md` v0.1.
When this template itself updates at HQ, products do not auto-migrate
— they pick up the new template structure at their next major
adoption (typically a new phase or a deliberate refresh). Changes to
existing CLAUDE.md content follow the standard cycle: lesson → HQ
update → next-phase pull.*
