# Signing Key Birth Certificate

> **What this is.** The checklist that runs at the moment a new
> credential or signing artifact is born — Android keystore, Apple
> distribution certificate, Windows EV code-signing cert, OAuth
> credential, API key, account-recovery codes. Small but distinct.
> Pulled out at the specific moment of creation, not buried inside
> a longer checklist.
>
> **Why it has its own document.** The risk window is the gap
> between creation and discipline. The operator is focused on
> getting the build out, not on backup hygiene. A keystore created
> on `~/Desktop/` with an uncertain password is a P0 risk with a
> non-recoverable failure mode. This checklist exists to be pulled
> out *at that moment* — not to be remembered later.
>
> **Lesson trace.** HQ STANDARDS H15. Derived from
> `vibespin-LL-017`, `xagent-LL-006`, `xagent-LL-007`,
> `roreedge-LL-017`.
>
> **How to use.** When creating any new credential or signing
> artifact, open this file. Walk the relevant section before doing
> anything else with the credential.

---

## Two categories — different rules

### Category A — Irrecoverable material

If lost, the affected app cannot be updated, signed, or
distributed under its existing identity. Recovery requires
publishing under a new identity, which fragments the user base
and breaks auto-updaters.

- Android keystores (`.jks`, `.keystore`)
- Apple distribution certificates (after Apple Developer
  enrollment)
- Windows EV code-signing certificates
- Account recovery codes for any platform that owns published apps
- Master encryption keys for on-device encrypted vaults (where
  applicable)

### Category B — Recoverable but exposable

If exposed, can be rotated. Damage scope is "until rotation
completes," not "forever."

- API keys (Anthropic, OpenAI, Finnhub, etc.)
- OAuth tokens (X API, Google, etc.)
- Database credentials
- Service account JSON files (Firebase admin, GCP, etc.)
- Webhook secrets

---

## Section A — Irrecoverable material checklist

> Run BEFORE the first signed build, BEFORE the first store
> upload, BEFORE leaving the session. The cost of doing this now
> is 10 minutes; the cost of skipping it is the app.

### A.1 — File location

- [ ] **Stored at a project path covered by automated backup.**
  Not `~/Desktop/`. Not `~/Downloads/`. Not anywhere that's
  outside the backup tool's coverage. Verify the path is in the
  backup tool's included list.

- [ ] **Path documented in CLAUDE.md P4 (architecture overview)**
  so future-you (or a future collaborator) can find it. Don't
  document the *contents* — document the *location*.

### A.2 — Password / passphrase

- [ ] **Recorded in a password manager AT CREATION TIME.** Not
  later. Not "I'll add it tonight." At creation time. The risk
  window between creation and recording is where loss happens.

- [ ] **Password manager entry includes:**
  - Which keystore/cert this is for (product name + variant —
    debug vs release)
  - Where the file lives (path)
  - Any related metadata (alias, key alias, validity dates)

### A.3 — Two-location storage

- [ ] **A copy of the keystore/cert file exists in at least two
  independent locations BEFORE the first signed build runs.**
  The two locations cannot share a failure mode — "Mac local
  disk + Time Machine" is two locations; "Mac local disk +
  iCloud" is two locations; "Mac local disk + a folder on the
  same Mac" is one location.

- [ ] **At least one of the two locations is offline or
  encrypted-at-rest.** A keystore in a cloud bucket with
  default-allow rules is one accidental policy change away from
  public.

### A.4 — Acknowledgment

- [ ] **Operator has explicitly acknowledged**, in writing in
  CLAUDE.md or the Phase Protocol log, the sentence: *"If this
  signing material is lost, the affected app cannot be updated
  under its current identity. I have completed A.1–A.3 above."*

  This is not legal ceremony. It's the moment the risk becomes
  conscious. Skipping the acknowledgment is the strongest signal
  that the discipline isn't actually in place.

### A.5 — Phase 0 readiness for irrecoverable material with lead time

> Some irrecoverable material has long lead times. Plan for it
> in Phase 0, not at the moment of need.

- [ ] **Apple Developer enrollment** — order before Phase 1 of
  any product that will ship to iOS. Can take days to weeks
  depending on entity type and verification.
- [ ] **Windows EV code-signing certificate** — order before
  Phase 1 of any product that will ship Windows binaries.
  Vendors require business validation; takes time.
- [ ] **D-U-N-S number** (where required for developer
  enrollment) — apply 30 days before need.

---

## Section B — Recoverable-but-exposable material checklist

> Run when creating any new API key, OAuth token, service
> account, or webhook secret.

### B.1 — Storage

- [ ] **Stored in `.env` or equivalent, never hardcoded in
  source.** If the project doesn't have a `.env` pattern yet,
  set one up first (see DEPLOYMENT_CHECKLISTS.md → Backend).

- [ ] **Recorded in a password manager** with which service it
  belongs to, what scope it has, and which dashboard owns the
  billing.

- [ ] **NOT in the chat transcript with its real value.** If a
  credential value has been pasted into a chat (yours or an AI
  assistant's), it is exposed — chat history can't be edited.
  Rotate before continuing. *(Cross-references
  `xagent-LL-007`.)*

### B.2 — Scope

- [ ] **Created with the minimum scope required for the specific
  operation.** Not "all permissions" because that's faster.
  Read-only when read-only suffices; write-only when only writing.
  *(Cross-references H13 — per-operation compliance.)*

- [ ] **Rotation plan exists** — how often, who triggers, what
  breaks during rotation. For solo operations, "manually every
  6 months unless exposed" is a valid plan; nothing is not a plan.

### B.3 — Hardcoded-as-workaround handling

> A specific recurring failure mode: env vars don't propagate
> (Railway, Vercel, etc.), keys get hardcoded as a temporary
> workaround, the workaround never gets undone. *(Cross-references
> `xagent-LL-006`.)*

- [ ] **If a credential is hardcoded as a workaround, an
  immediate rotation ticket is created in the SAME COMMIT.**
  Not after. Not "I'll fix it tonight." In the same commit, with
  a TODO referencing the ticket. The temporary fix is not "done"
  until the rotation is.

- [ ] **AI assistants do NOT frame hardcoded-credential
  workarounds as "we can fix it properly later"** without
  simultaneously creating the rotation ticket. This is a hard
  rule on AI assistant behavior, named explicitly in HQ
  STANDARDS H1.

### B.4 — Exposure-response runbook

- [ ] **If a credential is exposed**, run this sequence:
  1. Rotate the credential at the provider's dashboard.
  2. Update the production environment with the new credential.
  3. Verify the old credential is invalidated (try it; should
     fail).
  4. If the credential was committed to git, audit history with
     `git log --all -p | grep <pattern>` and follow up on every
     hit. (For history rewrite, use `git filter-branch` or BFG —
     reference DC-D for the procedure.)
  5. Document the rotation in the Phase Protocol log.

---

## What's intentionally not in this checklist

- **Provider-specific signing procedures.** Each platform has
  its own signing workflow (Android via gradle, Apple via Xcode
  + notarytool, Windows via signtool). Those live in
  platform-specific runbooks under `eos/runbooks/` if needed.
  This checklist covers the *birth certificate* — the discipline
  at moment of creation — not the operational use.

- **Production-key rotation playbook.** A separate runbook for
  when keys must be rotated (annual schedule, after a security
  incident, etc.). Built when the first rotation is needed.

- **Backup tool selection or configuration.** Out of scope. The
  checklist requires "covered by automated backup"; the operator
  picks the tool.

---

*Source-of-truth checklist. Maintained in
`rore-tech-hq/eos/checklists/SIGNING_KEY_BIRTH_CERTIFICATE.md`.
v0.1 absorbs lessons listed in the lesson trace above.*
