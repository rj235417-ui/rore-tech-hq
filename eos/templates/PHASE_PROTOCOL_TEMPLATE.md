# Phase Protocol — [PRODUCT NAME] — Phase [N]: [SHORT TITLE]

> **What this document is.** The plan, log, and exit gate for one
> phase in one product. Created at phase kickoff from
> `rore-tech-hq/eos/templates/PHASE_PROTOCOL_TEMPLATE.md`. Lives at
> `docs/protocols/phase-[N].md` in the product's repo. Updated
> through the phase. Walked at phase close. Archived (kept in repo,
> not deleted) when the phase ships.
>
> **Why one document, not three.** Phase Protocol, plan, and Exit
> Gate are one artifact viewed from different angles. Splitting them
> creates drift. The plan opens the document; the gate closes it;
> the log captures what happened in between.
>
> **Scope discipline.** A Phase Protocol describes one architectural
> concern (cross-references H14 — single architectural concern per
> Claude Code session). If the protocol grows to cover two
> architectural concerns, it's two phases, not one.

---

## Header

| Field | Value |
|---|---|
| Product | [Product name] |
| Phase number | [N — 1, 2, 3, ...] |
| Phase title | [Short, descriptive — e.g., "Magic Link auth," "Trade import for Schwab," "v1.0 production launch"] |
| Phase opened | [YYYY-MM-DD] |
| Phase closed | [YYYY-MM-DD or "open"] |
| HQ STANDARDS version this phase syncs from | [vX.Y as recorded in CLAUDE.md HQ STANDARDS section at phase kickoff] |
| Operator | [Founder name or "RORE Tech operator"] |
| Primary AI collaborator | [Claude Code / specific Claude session / etc.] |

---

## 1. Purpose

> Why this phase exists. One paragraph, no more. If this section
> grows past a paragraph, the phase is too broad — split it.

[Why this phase. What it produces. What "shipped" means for it.]

---

## 2. Scope

### In scope

[Bullets of what this phase will do. Specific, verifiable.]

- [Item]
- [Item]

### Explicitly out of scope

[Bullets of what this phase will NOT do — including things that
might naturally be expected. Out-of-scope items become candidate
backlog items for the next phase.]

- [Item]
- [Item]

### Plan — specific values, fields, and decisions

> *(Cross-references H12 — implementation matches plan.)* Every
> specific value, field name, threshold number, URL, or named
> decision made at kickoff goes in this list. At phase exit (Section
> 5.6 — Implementation matches plan), every named value is grepped
> in the implementation to verify it landed.

| Named value or decision | Value at kickoff |
|---|---|
| [e.g., `ActionCodeSettings.url`] | [e.g., `https://vibefire-dev-cdfd6.firebaseapp.com/__/auth/action`] |
| [e.g., Magic Link `androidPackageName`] | [e.g., `app.vibefire.android`] |
| [e.g., MAX-tier monthly price] | [e.g., $4.99 USD] |
| [...] | [...] |

If a value changes mid-phase, edit this table and add a one-line
note in the phase log (Section 3) explaining why. Do not silently
revise.

---

## 3. Phase log

> Updated as the phase runs. One entry per session, surprise, decision,
> or change. Brief — 1-3 lines per entry. The log is what makes the
> 5-line lessons-learned intake easy to write at phase close.

**[YYYY-MM-DD]** — [What happened. What was decided. What was
learned.]

**[YYYY-MM-DD]** — [...]

**[YYYY-MM-DD]** — [...]

---

## 4. Architectural decisions made during this phase

> Anything expensive to reverse — schema choice, tech stack
> addition, API contract, irreversible config decision — gets an
> ADR in `docs/decisions/` and is linked here. Trivial decisions
> stay in the phase log.

- [`ADR-NNN`](../decisions/adr-NNN.md): [One-line summary]
- [...]

---

## 5. Exit Gate

> Walked at phase close. Each item marked PASS, WAIVE (with
> reason), or N/A (with reason). Phase is not done until the gate
> is walked. Skipping the walk is a system failure.
>
> The Universal Phase Exit Gate appears below in full. Project-
> specific gate items can be added at the end of any section
> if needed for this phase.

### 5.1 Scope and intent

- [ ] **Phase scope is documented** in Section 2 above and matches
  what was actually built.
- [ ] **Out-of-scope items are listed** in Section 2 and any
  scope drift discovered during the phase has been documented.
- [ ] **Phase Protocol document reflects what actually happened**,
  not just what was planned.

### 5.2 Code state

- [ ] **All committed code is on the main branch** (or the
  product's release branch). No uncommitted local changes that
  matter.
- [ ] **No secrets, API keys, or credentials are committed.**
  Spot-check config files, env files, and any new dependencies.
  *(Cross-references H10 — pre-submission audit hardcoded-secrets
  pattern.)*
- [ ] **`.gitignore` covers any new build artifacts, env files, or
  generated content** introduced this phase.
- [ ] **Dependencies added this phase are accounted for** — listed
  in the manifest, version-pinned where it matters, and licensed
  acceptably. *(Cross-references DC-E — exact pin no carets.)*

### 5.3 Build, test, and run

- [ ] **A clean build succeeds from a fresh checkout.** Not "it
  works on my machine" — actually verified from a fresh state.
- [ ] **All automated tests pass.** Failing tests are either
  fixed or explicitly waived with reason.
- [ ] **The product runs end-to-end through the primary user flow
  added or changed this phase**, on a real device or in the real
  target environment. *(Cross-references H12.)* For mobile apps:
  real physical device. For backend services: deployed environment
  with a `/health` endpoint check. For desktop apps: signed
  artifact on at least one target OS.
- [ ] **Logs are clean** of new errors and warnings introduced
  this phase, or each one is acknowledged.

### 5.4 Configuration and environment

> *This is the section that catches setup-step gaps. Treat it as
> load-bearing.* (Cross-references H10, H11, H13, and the entire
> Firebase Setup Checklist family.)

- [ ] **All environment variables required to run the product are
  documented** in CLAUDE.md or the product's setup doc, with example
  values where safe.
- [ ] **All third-party services this phase introduced or changed
  are documented**, including which environment (dev/staging/prod),
  how credentials are managed, and what happens if the service is
  unavailable.
- [ ] **Service-specific setup checklists have been walked.** For
  Firebase + Flutter: `FIREBASE_FLUTTER_SETUP.md`. For Play Store
  submission: `PLAY_STORE_SUBMISSION.md`. For any backend service:
  `BACKEND_SERVICE_HARDENING.md`. Etc.
- [ ] **Permissions, scopes, and access rules** for any service
  touched this phase are reviewed against intended behavior.
  Default-allow is a red flag unless explicitly intended.
  *(Cross-references H16 — privacy as architectural constraint.)*
- [ ] **Quotas, rate limits, and billing thresholds** are noted
  for any new service.

### 5.5 Data and privacy

- [ ] **Data flow added or changed this phase is documented**,
  including what is captured, where it is stored, and who can
  see it.
- [ ] **The product's stated privacy posture (CLAUDE.md P2/P3 +
  RORE_TECH_ORG.md Section 2) is still accurate** after this phase.
  If anything changed the data flow, the privacy page reflects it
  before the phase ships. *(Cross-references H16.)*
- [ ] **No new telemetry, analytics, or tracking has been added
  without explicit operator decision** logged in an ADR or the
  phase log.

### 5.6 Implementation matches plan

> *(Cross-references H12 — VibeFire Gap 8 was specifically the
> implementation skipping a value the plan named. This check
> exists because of that lesson.)*

- [ ] **For every named value or decision in Section 2's "Plan"
  table**: grep the implementation. If the named value is absent,
  either the plan changed (update Section 2 with reason in
  Section 3 log) or the implementation skipped it (fix the
  implementation).
- [ ] **Verified for at least one critical value** that what the
  plan said matches what's running. For Magic Link: the actual
  URL the SDK is sending. For paywall: the actual SKU the modal
  references. For data import: the actual grouping key the
  query uses.

### 5.7 Compliance and platform policy

- [ ] **Any change touching a regulated surface** (biometrics,
  financial framing, surveillance framing, age-gated content, RSI
  disclosure) has been re-reviewed. "We didn't change anything
  sensitive" is itself a check that requires looking, not assuming.
- [ ] **Store listing, marketing copy, and legal pages** are
  consistent with what the product actually does after this phase.
  *(Cross-references H18 — storefront truth.)*
- [ ] **Platform-specific policy items relevant to this product**
  have been considered (Play Store stalkerware policy for Security
  SPY, no-advice framing for Edge Journal, RSI disclosure for
  Vibe Spinner, etc.).
- [ ] **Pre-submission audit (`.audit/` grep patterns) ran clean**
  on the release artifact. *(Cross-references H10.)*

### 5.8 Documentation

- [ ] **CLAUDE.md (PROJECT-SPECIFIC section) is updated** with
  anything the next phase or the next collaborator needs to know.
- [ ] **An ADR exists for any architectural decision made this
  phase that would be expensive to reverse.** Linked from Section
  4 above.
- [ ] **Runbooks are updated** for any operational procedure that
  changed this phase (deploy, rollback, credential rotation,
  common failure recovery).
- [ ] **README or setup doc still works for a fresh contributor.**

### 5.9 Release and rollback

- [ ] **The release artifact** (binary, store listing, web deploy)
  is identified and verified if this phase ships externally.
- [ ] **A rollback path exists.** What does "back out this phase"
  look like? If there is no rollback path, that is a decision
  logged in an ADR, not an oversight.
- [ ] **External communication** (changelog, store listing notes,
  support page) is drafted if user-visible behavior changed.

### 5.10 Lessons and intake

- [ ] **A 5-line lessons-learned intake is drafted for HQ.** Even
  when the phase felt routine. *(Cross-references H6.)*

  **Format:**
  1. *Phase and product:* [...]
  2. *What went well:* [one specific thing]
  3. *What slipped:* [one specific gap, near-miss, or surprise]
  4. *Process implication:* [which checklist or standard, if any,
     should change]
  5. *One-line ask of HQ:* [smallest concrete update requested,
     or "no change"]

- [ ] **Intake has been sent to HQ.** A drafted intake that doesn't
  reach HQ is the same as no intake.

---

## 6. Gate decision

[Recorded after the gate is walked. One of:]

- **GATE PASSED** — all items PASS, N/A, or WAIVE; phase is done.
- **GATE PASSED WITH WAIVERS** — same, with explicit waivers
  carrying named follow-up owners and target dates.
- **GATE FAILED** — one or more items cannot be marked. Phase is
  not done. Protocol stays open until they can be.

[List of WAIVERS, if any:]

| Item | Reason | Follow-up owner | Target date |
|---|---|---|---|
| [...] | [...] | [...] | [...] |

---

## 7. Lessons-learned intake (final, sent to HQ)

[The 5-line intake, sent to HQ at phase close. Copy of what was
sent, kept here for the project's institutional memory.]

```
Phase and product: ...
What went well: ...
What slipped: ...
Process implication: ...
One-line ask of HQ: ...
```

**Sent to HQ:** [YYYY-MM-DD]

---

*Phase Protocol template v0.1. Sourced from
`rore-tech-hq/eos/templates/PHASE_PROTOCOL_TEMPLATE.md`. The
embedded Exit Gate (Section 5) is synced from
`rore-tech-hq/eos/checklists/PHASE_EXIT_GATE.md` at phase kickoff.*
