# Universal Phase Exit Gate Checklist

> **Version:** 0.2 (was 0.1; bumped 2026-05-12 from VibeFire Phase 1
> close intake — clarified "observed on target hardware" language in
> Section 3 and added open-items completeness check to Section 8)
> **Owner:** RORE Tech HQ Project (canonical). Copied into each product
> project's `docs/checklists/` folder. Updates flow from HQ → products
> via the HQ STANDARDS section of each product's CLAUDE.md.
>
> **Purpose.** Before a phase is declared done — and especially before
> the next phase begins — every item below is either checked, waived
> with reason, or marked N/A with reason. The gate is the *single* place
> where the system catches the small-but-critical setup, configuration,
> and transition steps that get missed when moving fast.
>
> **The bar.** This checklist exists to catch the eight Firebase gaps
> from VibeFire Phase 1. If a category below could not have caught one
> of those gaps, it earns its place. If a category is here for tidiness
> and not for catching real failures, it gets cut.
>
> **How to use.** At phase kickoff, copy this checklist into the Phase
> Protocol document's *Exit Gate* section. Add product-specific items
> on top. At phase close, walk the gate item by item. *No phase ships
> without the gate being walked.* Skipping the walk is the single most
> common way the system silently fails.

---

## How items get marked

- **PASS** — verified, evidence cited (commit, test run, screenshot,
  doc link).
- **WAIVE** — explicitly accepted as not done, with a one-sentence
  reason and a follow-up owner.
- **N/A** — does not apply to this phase or product, with a one-sentence
  reason.

A gate with un-marked items is a gate that hasn't been walked.

A gate with more than two `WAIVE` entries is a signal to pause and ask
whether the phase is actually done.

---

## 1. Scope and intent

- [ ] **Phase scope is documented and matches what was built.** Scope
  drift is fine; undocumented scope drift is not.
- [ ] **Out-of-scope items are listed**, including anything that came
  up during the phase and was deferred. These become candidate items
  for the next phase or the backlog.
- [ ] **The Phase Protocol document has been updated to reflect what
  actually happened**, not just what was planned.

## 2. Code state

- [ ] **All committed code is on the main branch (or the
  product's release branch).** No uncommitted local changes that
  matter.
- [ ] **No secrets, API keys, or credentials are committed.** Spot-check
  config files, env files, and any new dependencies.
- [ ] **`.gitignore` covers any new build artifacts, env files, or
  generated content** introduced this phase.
- [ ] **Dependencies added this phase are accounted for** — listed in
  the manifest, version-pinned where it matters, and licensed
  acceptably.

## 3. Build, test, and run — observed, not deployed

> **Language note (v0.2, from VibeFire Phase 1 close intake).**
> "Deployed artifact exists" is **not** equivalent to "observed
> working." A Cloud Function that deployed successfully but was never
> invoked from the target device has not been observed. A Firestore
> ruleset that linted clean but was never roundtripped from the target
> device has not been observed. The items below all require *the
> operator's direct observation of the behavior on the target hardware
> or environment*, not a green status in a deploy log.

- [ ] **A clean build succeeds from a fresh checkout.** Not "it works on
  my machine" — actually verified from a fresh state.
- [ ] **All automated tests pass.** Failing tests are either fixed or
  explicitly waived with a reason.
- [ ] **The operator has personally observed the product running
  end-to-end** through the primary user flow added or changed this
  phase, on the real target hardware or environment:
  - For mobile apps: real device flash + run (emulator-only is not
    sufficient).
  - For backend services: real deployed endpoint hit from outside the
    deploy environment.
  - For desktop apps: signed/packaged artifact running on a target OS.
  - For data pipelines: real source data flowing through the real
    pipeline to a real consumer.
- [ ] **For any feature involving a network roundtrip** (auth, data
  read/write, third-party API), the operator has personally observed
  the roundtrip succeed on the target device, on a network the user
  might realistically be on. Home wifi DNS quirks, captive portals,
  cellular dropouts, and corporate proxies can all mask "deployed but
  broken" states for days.
- [ ] **Logs are clean of new errors and warnings introduced this
  phase**, or each one is acknowledged.

## 4. Configuration and environment

> *This is the section that would have caught most of the eight Firebase
> gaps. Treat it as load-bearing.*

- [ ] **All environment variables required to run the product are
  documented** in CLAUDE.md or the product's setup doc, with example
  values where safe.
- [ ] **All third-party services this phase introduced or changed are
  documented**, including: which environment (dev/staging/prod), how
  credentials are managed, and what happens if the service is
  unavailable.
- [ ] **Service-specific setup checklists have been walked.** If a
  Firebase Setup Checklist exists, it was used. Same for any other
  service-specific HQ checklist relevant to this phase.
- [ ] **Permissions, scopes, and access rules** for any service touched
  this phase are reviewed against intended behavior. Default-allow is
  a red flag unless explicitly intended.
- [ ] **Quotas, rate limits, and billing thresholds** are noted for any
  new service. Surprise bills are a process failure, not a vendor
  failure.

## 5. Data and privacy

- [ ] **Data flow added or changed this phase is documented**, including
  what is captured, where it is stored, and who can see it.
- [ ] **The product's stated privacy posture (per its CLAUDE.md and
  RORE_TECH_ORG.md Section 2) is still accurate.** If anything in this
  phase changed the data flow, the privacy page must reflect it before
  the phase ships.
- [ ] **No new telemetry, analytics, or tracking has been added without
  explicit operator decision** logged in an ADR or commit message.

## 6. Compliance and platform policy

- [ ] **Any change touching a regulated surface (biometrics, financial
  framing, surveillance framing, age-gated content, RSI disclosure)
  has been re-reviewed.** "We didn't change anything sensitive" is
  itself a check that requires looking, not assuming.
- [ ] **Store listing, marketing copy, and legal pages** are still
  consistent with what the product actually does after this phase.
  Drift between page and product is the most common compliance trip.
- [ ] **Platform-specific policy items relevant to this product** have
  been considered (Play Store stalkerware policy for Security SPY,
  no-advice framing for Edge Journal, RSI disclosure for Vibe Spinner,
  etc.).

## 7. Documentation

- [ ] **CLAUDE.md (project-specific section) is updated** with anything
  the next phase or the next collaborator needs to know.
- [ ] **An ADR exists for any architectural decision made this phase
  that would be expensive to reverse.** "Expensive to reverse" is the
  bar — not every decision needs an ADR.
- [ ] **Runbooks are updated for any operational procedure that
  changed** this phase (deploy, rollback, credential rotation, common
  failure recovery).
- [ ] **README or setup doc still works for a fresh contributor.**
  Imagine onboarding yourself in three months with no memory of this
  phase.

## 8. Release and rollback

- [ ] **The release artifact (binary, store listing, web deploy) is
  identified and verified** if this phase ships externally.
- [ ] **A rollback path exists.** What does "back out this phase" look
  like? If there is no rollback path, that is a decision logged in an
  ADR, not an oversight.
- [ ] **External communication (changelog, store listing notes, support
  page) is drafted** if user-visible behavior changed.
- [ ] **Open-items deferred to a future phase have explicit
  owner + target date + risk acceptance** (v0.2, from VibeFire Phase 1
  close intake). Every item carried forward names:
  1. *Owner* — operator or named collaborator responsible.
  2. *Target date* — when this gets done, or when this gets
     re-evaluated.
  3. *Risk acceptance* — one sentence stating what's being deferred
     and what the cost is if it slips.

  An open item without all three is not "tracked" — it's hoping. Items
  without all three are surfaced for operator decision before the gate
  passes.

## 9. Lessons and intake

- [ ] **A 5-line lessons-learned intake is drafted for HQ.** Even when
  the phase felt routine. Routine phases produce the most reliable
  data about what is and isn't tripping the system.

  **Format (5 lines, no more):**
  1. *Phase and product:* which phase, which product, dates.
  2. *What went well:* one specific thing.
  3. *What slipped:* one specific gap, near-miss, or surprise.
  4. *Process implication:* which checklist or standard, if any,
     should change.
  5. *One-line ask of HQ:* the smallest concrete update requested,
     or "no change" if none.

- [ ] **Intake has been sent to HQ.** A drafted intake that doesn't
  reach HQ is the same as no intake.

---

## Gate decision

At the bottom of the gate walk, one of the following is recorded:

- **GATE PASSED** — all items PASS, N/A, or WAIVE with reason; phase is
  done.
- **GATE PASSED WITH WAIVERS** — same, but with explicit waivers
  carrying named follow-up owners and target dates.
- **GATE FAILED** — one or more items cannot be marked. The phase is
  not done. The protocol document stays open until they can be.

A GATE FAILED is not a problem. A gate that was never walked is.

---

## What's intentionally not in this checklist

- **Fine-grained code review items.** That's the engineer's job inside
  the phase, not a gate at the boundary.
- **Performance and scale benchmarks.** Add per-product if and when a
  product has a real performance bar to clear.
- **Security audit items.** When a product reaches a stage that
  warrants a security audit, that audit is its own checklist, not a
  line item here.
- **Marketing and growth items.** Distribution lives in LAUNCH_PLAN
  documents, not phase gates.

---

*Universal artifact. Maintained in HQ. Copied into each product's
`docs/` folder. Updates flow HQ → products at the monthly review.*
