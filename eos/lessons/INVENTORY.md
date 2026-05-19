# RORE Tech — Cross-Project Lessons Inventory

> **Version:** 0.3 (bumped 2026-05-19 — added 7 Vibe Spinner lessons LL-033 through LL-039 from Phase 3 close, plus richer content for LL-023/025/026/027/028/029/032 from same source)
> **Compiled:** 2026-05-10 (v0.1), updated 2026-05-16 (v0.2), updated 2026-05-19 (v0.3)
> **Source inventories:** 6 — `security_spy_lessons-inventory.md` (22),
> `vibespin_lessons-inventory.md` (21 → 32 in v0.2 → 39 in v0.3),
> `Rore_tech_journal_lessons-inventory.md`
> (22), `Trade_edge_lessons-inventory.md` (20), `xagent_essons-inventory.md`
> (20), `Rore_tech_website_lessons-inventory.md` (18), plus the VibeFire
> Phase 1 Firebase Setup Gaps Dump (8 gaps).
> **Total lessons referenced:** 139 + 8 VibeFire gaps = 147.
>
> **What this is.** The single source of truth for everything RORE Tech
> has learned across products that is worth encoding into a standard or a
> checklist. Each downstream artifact (HQ STANDARDS update, the Firebase
> checklist, the Play Store checklist, etc.) cites back to specific
> lesson IDs in this inventory. That trace is what makes the EOS cycle
> auditable: "this checklist item exists because of these lessons."
>
> **What this is not.** A retrospective of every project. Trivial bugs,
> one-time flukes, and items that don't change a future project's
> behavior are excluded. Every entry here is *generative* — it produces
> a checklist item, a standard, or a rule.
>
> **How it's organized.**
>
> 1. **Cross-cutting patterns** (Section 1) — patterns that recur across
>    3+ projects. These become rules in HQ STANDARDS. Universal.
> 2. **Domain clusters** (Section 2) — patterns that recur within a
>    specific stack or surface (Play Store, importers, AI publishing,
>    Electron, backends, web hosting). These become domain-specific HQ
>    checklists. Not every product touches every cluster.
> 3. **Singleton lessons** (Section 3) — high-value lessons that don't
>    cluster but are worth preserving for the project that hits the
>    same situation.
> 4. **Lesson ID index** (Section 4) — every source lesson, listed once,
>    pointing to which section absorbs it.
>
> **How to read this with a checklist.** Every checklist item should
> link back to one or more lesson IDs. If a checklist item has no
> lesson backing, it's an opinion, not a learning. Mark it as such or
> cut it.

---

# Section 1 — Cross-Cutting Patterns

> Patterns that recur in 3+ source inventories. These become rules in
> the HQ STANDARDS section of every CLAUDE.md, because they apply to
> every product regardless of stack.

---

## CC-1. Single source of truth for canonical strings, paths, and entities

**Pattern.** A canonical fact (product name, governing law, billing
partner, package name, file path, version code) gets restated in
multiple files, and silently drifts. The drift is invisible until a
release lands wrong.

**Source lessons:**
- `roretech-website-LL-001` — two `privacy.html` files for one product.
- `roretech-website-LL-008` — Delaware vs. Massachusetts governing law drift across all legal pages.
- `roretech-website-LL-009` — "Vibe Studios Spinner" surviving multiple drafts.
- `roretech-website-LL-010` — per-product billing partner drift (SUB-003 only on Security SPY).
- `roretech-website-LL-016` — pasted context dumps disagreeing with CLAUDE.md.
- `roretech-website-LL-018` — `.gitignore` rule rationale lives elsewhere than the rule.
- `vibespin-LL-008` — display name + package name drifted across 4+ config files.
- `vibespin-LL-020` — `www/` source-of-truth split between two folders, manually synced.
- `roreedge-LL-020` — "ROREtech Inc." vs "RORE Tech" multi-file find-and-replace.
- `roreedge-LL-004` — two functions reading the same data with different grouping keys.

**Rule (becomes HQ STANDARDS).** Every canonical fact lives in exactly
one place in the HQ repo. Products reference it; they never restate it.
Mirrors are redirects, never copies. Pre-commit grep enforces. CLAUDE.md
itself is the canonical chat-startup context — no more pasted dumps.

**Specific HQ artifacts this drives.**
- `org/LEGAL_ENTITY.md` (entity name, state, governing law, address — already partially in `RORE_TECH_ORG.md`).
- `org/PRODUCTS.md` (canonical product names, taglines, platforms, billing partners).
- `org/BILLING_MATRIX.md` (per-product, per-platform billing surface).
- Pre-commit grep checks: deprecated names, deprecated states, deprecated billing language.

---

## CC-2. Pre-submission/pre-deploy grep audits as standing process

**Pattern.** A class of bug — stalkerware code patterns, debug
affordances, hardcoded secrets, deprecated names, footer-link
inconsistencies, oversized native libs — is reliably caught by a small
grep against the artifact about to ship. Manual review catches it
unreliably. Grep catches it every time. The audit must run before
*every* submission, not only after a rejection.

**Source lessons:**
- `securityspy-LL-001` — stalkerware pattern code (`setComponentEnabledSetting`) survived in dead code.
- `securityspy-LL-009` — `SYSTEM_ALERT_WINDOW` and other "defensive" over-declarations as stalkerware signals.
- `securityspy-LL-010` — 50+ grep-pattern audit ran against rejection-email text caught what eyeballing missed.
- `vibespin-LL-002` — `android.permission.CAMERA` auto-declared by unused Capacitor plugin.
- `vibespin-LL-004` — DEV tier-cycling button shipped to production three times.
- `roretech-website-LL-002` — filename whitespace shipped via git rename slip.
- `roretech-website-LL-003` — HTML referenced PNGs not committed.
- `roretech-website-LL-004` — footer privacy link without `.html` extension.
- `roretech-website-LL-008` — Delaware references in legal pages.
- `xagent-LL-007` — real API keys pasted into chat code examples.

**Rule (becomes HQ STANDARDS).** Every product repo carries a versioned
`.audit/` directory of grep patterns. The audit runs as a pre-commit
hook (fast subset) and as a pre-submission gate (full audit). New
patterns flow from HQ when surfaced anywhere. Adding a pattern is a
1-line PR; cost is near zero, value compounds.

**Specific HQ artifacts this drives.**
- `eos/audit/` — versioned grep-pattern files by category (stalkerware-patterns, deprecated-strings, hardcoded-secrets, debug-affordances, asset-existence).
- `eos/checklists/PRE_SUBMISSION_AUDIT.md` — when to run the full audit.

---

## CC-3. Loud failure beats silent skip

**Pattern.** A code path encounters something it doesn't recognize and
silently does nothing — drops the row, returns the raw input, defaults
the year, swallows the exception. The user sees "missing data" or
"no result" with no signal of why. Silent skips are the most
expensive bug class because they're invisible at write-time, expensive
at read-time, and impossible to retroactively detect.

**Source lessons:**
- `roreedge-LL-007` — Robinhood SPR/MRGS/SCXL/REC corporate-action rows silently dropped.
- `roreedge-LL-008` — Schwab "7-Mar" date silently parsed as year 2001.
- `roreedge-LL-009` — TDA option rows passed through as equity trades.
- `roreedge-LL-021` — sells with no buy in window silently skipped (still OPEN).
- `tradeedge-LL-008` — hardcoded econ calendar silently dropped past-dated events.
- `tradeedge-LL-004` — `rss-parser` failures hidden inside structural exceptions.
- `xagent-LL-005` — Railway env-var propagation failures with no UI signal.
- `xagent-LL-013` — local `index.html` drift produced silent client-server skew.
- `xagent-LL-016` — Railway auto-deploy silently skipped a push.
- `roreedge-LL-001` — `side === "BUY"` silently dropped 100% of trades when broker used compound action verbs.

**Rule (becomes HQ STANDARDS).** Every fall-through, default, skip, or
"unknown input" branch produces a user-visible record. Either fail
loudly (throw with a clear message), log + count + surface to the
user, or — at minimum — emit a "skipped: N items, here's the list"
report. "Silently dropped" is never an acceptable outcome.

**Specific HQ artifacts this drives.**
- HQ STANDARDS rule.
- Item in every importer/parser checklist.
- Item in every backend-deploy checklist (`/health` and `/diag` endpoints, every required env var booleans).

---

## CC-4. Real samples, real devices, real artifacts before declaring "done"

**Pattern.** A spec, a build, a test, or a fix is declared done based
on something proxied — a hand-written example, a passing CI gate, a
local dev build, a Python script, a pre-launch report severity. The
real thing then surfaces a failure the proxy couldn't catch.

**Source lessons:**
- `roreedge-LL-001` — parser spec written from a hand-written sample, real broker exports broke it.
- `roreedge-LL-002` — P&L math change shipped without reconciling against real historical data.
- `roreedge-LL-014` — PDF parser tested against visual layout, real text-extraction reflowed lines.
- `securityspy-LL-004` — "Medium" severity warning in pre-launch report became hard-blocking error at production submission.
- `securityspy-LL-017` — fresh-install onboarding bug invisible during dev iteration.
- `tradeedge-LL-013` — JS data-pipeline fix verified by reload, but cached JS + stale localStorage defeated it.
- `vibespin-LL-019` — shake bug fixed twice across rebuild because no real-device verification of deployed artifact.
- `VibeFire Gap 7` — Phase 1 declared done with passing CI gates; never run on a real device, app crashed on first launch.
- `VibeFire Gap 8` — implementation didn't match the plan; real end-to-end test would have caught it.

**Rule (becomes HQ STANDARDS).** A phase is not done until the deployed
artifact runs end-to-end against the real input on the real target.
"CI passes" is necessary, not sufficient. Real-device smoke test on
real data is non-skippable for any phase shipping user-facing
behavior. Reconciliation against a known-good external source is
required for any phase touching financial math, user data integrity,
or external compliance.

**Specific HQ artifacts this drives.**
- Universal Phase Exit Gate Section 3 (build-test-run) and Section 6 (compliance) are derived from this.
- New gate item (to add): "Reconciled against real input" for data-touching phases.

---

## CC-5. Per-endpoint, per-operation, per-platform compliance is per-X, not per-app

**Pattern.** A compliance, billing, permission, or disclosure
arrangement that's "approved" or "in place" is treated as covering
everything adjacent to it. It doesn't. Every API endpoint has its own
tier. Every sensitive API has its own disclosure. Every payment
provider has its own platform rules. Every platform has its own
review.

**Source lessons:**
- `xagent-LL-001` — Anthropic API billing separate from Claude.ai Pro.
- `xagent-LL-002` — X API automated-posting tier separate from API-access tier.
- `xagent-LL-003` — OAuth permissions baked into tokens at generation; bounce-then-regenerate.
- `tradeedge-LL-001` — Finnhub API key works for some endpoints, not for `/candles`.
- `securityspy-LL-002` — one prominent disclosure does not cover all sensitive APIs.
- `securityspy-LL-003` — in-app disclosure does not cover store-listing disclosure.
- `vibespin-LL-005` — Stripe OK on web, never on Google Play (must use Google Play Billing).
- `vibespin-LL-010` — 14-day closed-test rule is per-app, not per-account, on personal accounts.
- `roretech-website-LL-010` — SUB-003 billing language only applies to Google Play products.
- `roretech-website-LL-013` — IARC content rating ≠ Target Audience setting.

**Rule (becomes HQ STANDARDS).** At kickoff for any project that
touches an external service, a compliance regime, or a payment
surface, the operator writes the per-endpoint / per-operation /
per-platform matrix before integration code begins. "We have the API
key" is not the matrix. The matrix names: which dashboard owns the
billing, which scope is required for which operation, which
disclosure surface covers which API, which billing provider is
allowed on which platform.

**Specific HQ artifacts this drives.**
- `org/BILLING_MATRIX.md` (already named in CC-1).
- `eos/checklists/EXTERNAL_SERVICE_KICKOFF.md` (per-service matrix template).
- Items in Play Store, Apple App Store, and AI publishing checklists.

---

## CC-6. Single architectural concern per Claude Code session

**Pattern.** Bundling "while we're in here" changes into one Claude
Code session multiplies the failure surface. A session that "replaces
persistence layer AND wraps in Electron shell" has compounding risk
of either change failing. Sessions with one architectural concern
ship; sessions with two concerns produce regressions or have to be
backed out.

**Source lessons:**
- `roreedge-LL-022` — localStorage → electron-store deferred to its own session, correctly.
- `vibespin-LL-018` — prescriptive prompts encoded current hypothesis; descriptive bug-report prompts produced durable fixes.
- `tradeedge-LL-014` — splitting HTML into HTML+JS in one session left stray `</script>` tags that nuked parsing.
- `xagent-LL-006` — temporary hardcoded keys workaround never re-secured because no follow-up ticket attached.

**Rule (becomes HQ STANDARDS).** Every Claude Code session has one
architectural concern. Bug fixes use the BUG REPORT format (Symptom /
History / Requirement / Acceptance Test) — descriptive, not
prescriptive. Any "temporary" workaround creates a P1 follow-up
ticket in the same commit, not later.

**Specific HQ artifacts this drives.**
- Item in HQ STANDARDS.
- `eos/templates/BUG_REPORT_PROMPT.md` for Claude Code.
- Phase Protocol "session log" section.

---

## CC-7. Health/version endpoints with deployed git SHA

**Pattern.** Client-server skew, stale deploys, deploy-on-push that
silently didn't deploy, local dashboard that doesn't match the live
backend — all of these are invisible without a `/health` or `/version`
endpoint that returns the deployed git commit SHA. The check goes from
"reasoning about whether the push landed" to "compare two strings."

**Source lessons:**
- `xagent-LL-005` — Railway env vars failing silently; needed a `/diag` endpoint.
- `xagent-LL-013` — local `index.html` vs Railway backend skew; needed `/version` check on every load.
- `xagent-LL-016` — Railway auto-deploy silently skipped a push; needed SHA on `/health`.

**Rule (becomes HQ STANDARDS).** Every deployable service ships with
a `/health` endpoint that returns: `{deployed_git_sha, deployed_at,
required_env_vars: {KEY: bool}}`. After every deploy, the workflow is
*wait 60s, hit `/health`, compare SHA against local HEAD*. Treat
auto-deploy as advisory.

**Specific HQ artifacts this drives.**
- HQ STANDARDS rule.
- Item in `eos/checklists/BACKEND_SERVICE_HARDENING.md`.
- Required for any backend phase exit gate.

---

## CC-8. Credentials and signing material at moment of creation, not after

**Pattern.** Credentials and signing material (Android keystores, API
keys, OAuth tokens, code-signing certs) get created in the rush of a
"first build" or "first deploy." Backup, password storage, and
rotation discipline are deferred. Some are unrecoverable if lost
(Android keystore, code-signing keys); some are exposable if leaked
(API keys, OAuth tokens). The risk window is the gap between creation
and discipline.

**Source lessons:**
- `vibespin-LL-017` — keystore created on `~/Desktop/`, password uncertainty, no immediate backup.
- `xagent-LL-007` — API keys pasted as live values into chat code examples.
- `xagent-LL-006` — hardcoded keys committed and left as security debt without a rotation ticket.
- `roreedge-LL-017` — code-signing / notarization not in Phase 0 lead-time planning.

**Rule (becomes HQ STANDARDS).** Credential and signing-material
creation is its own checklist, run at the moment of creation. Backup,
password manager entry, and (for irrecoverable material) two-location
storage are completed before the next action. Hardcoded credentials
in code create an immediate rotation ticket with the same commit; not
deferred. AI assistants never echo a real credential value into a
code example, regardless of context.

**Specific HQ artifacts this drives.**
- `eos/checklists/SIGNING_KEY_BIRTH_CERTIFICATE.md` (covers Android keystores, Apple Developer enrollment, Windows EV certs).
- `eos/checklists/CREDENTIAL_HYGIENE.md`.
- Hard rule in HQ STANDARDS: AI assistants never echo real credentials.

---

## CC-9. Privacy commitments are architectural constraints, not legal copy

**Pattern.** A product makes a strong privacy or trust commitment
("data stays on your device," "your data, your edge"). The next
"small feature" — a sample mode, an AI feature, a telemetry hook, a
shared codepath — silently undermines the commitment. The commitment
gets defended by legal/privacy copy after the fact, when it should
have been defended at design time.

**Source lessons:**
- `roreedge-LL-015` — sample data must never share localStorage with real user data.
- `roreedge-LL-016` — AI Review feature requires dedicated consent surface, not buried ToS.
- `securityspy-LL-015` — privacy policy framing must match product framing; "silently captures" surveillance language was a code change, not legal hygiene.
- `vibespin-LL-002` — Capacitor Camera plugin auto-declared CAMERA permission for an app that never opens the camera.
- `securityspy-LL-009` — "defensive" permission over-declarations as stalkerware signals.

**Rule (becomes HQ STANDARDS).** Any feature that touches data flow,
permissions, telemetry, AI integration, or sample/demo data is
reviewed against the product's privacy commitments at *design* time,
not at compliance-page time. A feature that violates a commitment
either gets a dedicated, in-context consent surface (not buried
disclosure) or it doesn't ship. Permissions and capabilities are
declared minimally — never "defensively."

**Specific HQ artifacts this drives.**
- HQ STANDARDS rule.
- Item in `eos/checklists/PRIVACY_DESIGN_REVIEW.md`.
- Roundtable User Advocate chair already covers this — push-back rules are aligned.

---

## CC-10. PWA / service worker scope on multi-product domains

**Pattern.** Multiple products under one domain (`roretech.com/`,
`/games/vibespinner/`, `/journal/`, `/security-spy/`). Any service
worker registered with too-wide scope hijacks sibling products.
`manifest.json` `start_url` and SW registration paths default to the
script's directory. The failure manifests as "the homepage was
overwritten" — but it's the SW intercepting requests in the browser,
not anything in the repo.

**Source lessons:**
- `vibespin-LL-003` — SW at root scope cached spinner page, served it for `roretech.com/`.
- `vibespin-LL-014` — SW cache name not bumped on deploy.
- `vibespin-LL-016` — SW scope catastrophic on multi-product domain.
- `roretech-website-LL-007` — `/games/vibespinner/` PWA needed explicit "do not touch" in every prompt.

**Rule (becomes HQ STANDARDS).** Every product hosted under a shared
domain registers its SW with an explicit `scope:` parameter equal to
its subfolder. Cache name includes a version. Every deploy that
changes a cached file bumps the version. A `unregister-sw.html`
recovery page exists at the product's path. The HQ repo maintains a
domain-level SW-scope registry naming which scope each product owns.

**Specific HQ artifacts this drives.**
- `eos/checklists/PWA_DEPLOYMENT.md`.
- `org/DOMAIN_REGISTRY.md` listing every product's SW scope on shared domains.

---

## CC-11. Storefront truth — every claim maps to a built feature

**Pattern.** Marketing copy, paywall modals, paid-tier descriptions,
and store-listing feature lists drift to include items that aren't
built yet, items that were renamed, or items framed in ways that
aren't accurate. The drift is invisible internally but visible to
reviewers and users. For paid features, this crosses the line from
hygiene into "Misleading Behavior" policy territory.

**Source lessons:**
- `vibespin-LL-006` — MAX tier modal listed "Speed Run Challenge" and "Global Leaderboard" — neither was built.
- `securityspy-LL-014` — "- Silent Lens" suffix in app name was the most prominent policy-relevant word.
- `securityspy-LL-003` — store description didn't document AccessibilityService API use case.
- `roretech-website-LL-005` — self-drawn Google Play badge attempted before clarifying brand-guideline rules.

**Rule (becomes HQ STANDARDS).** Every feature listed in store
metadata, paywall modals, or paid-tier descriptions maps to a
specific function or screen in the current build. The mapping is
documented in the Phase Protocol for the release. Unbuilt items are
labeled "Coming soon" with a target version, or removed. Brand
assets (badges, logos, trademarks) come from official sources only —
never redrawn, never approximated.

**Specific HQ artifacts this drives.**
- Item in `eos/checklists/PLAY_STORE_SUBMISSION.md` and `APP_STORE_SUBMISSION.md`.
- Storefront-truth gate in Phase Exit Gate Section 6.
- `eos/checklists/BRAND_AND_BADGE_USAGE.md` covering trademark usage rules across stores.

---

# Section 2 — Domain Clusters

> Patterns that recur within a specific stack, surface, or product
> type. These become domain-specific HQ checklists. Each lesson cited
> in a cluster is *not* recited in cross-cutting Section 1 — clusters
> are the second home for lessons whose primary application is
> domain-specific.

---

## DC-A. Play Store submission for surveillance-adjacent and standard apps

**Why this is its own cluster.** Eight rejection-related lessons in
SecuritySpy alone, plus seven setup/process lessons in Vibe Spinner,
plus five hosting/branding/listing lessons on the website. Play Store
is the densest single domain in the inventory. Apple App Store will
parallel many of these when iOS submissions begin.

**Source lessons:**

*Stalkerware and surveillance-adjacent app patterns:*
- `securityspy-LL-001` — dead stalkerware-pattern code triggers auto-enforcement.
- `securityspy-LL-009` — `SYSTEM_ALERT_WINDOW` and accessibility-config over-declarations are stalkerware signals.
- `securityspy-LL-014` — app-name field is a policy surface (avoid "silent," "hidden," "covert").
- `securityspy-LL-015` — privacy policy framing is part of compliance posture.
- `securityspy-LL-022` — rebuild beats appeal when cited code/pattern is present.

*Disclosure architecture:*
- `securityspy-LL-002` — one prominent disclosure per sensitive API (not per app).
- `securityspy-LL-003` — store-listing description must document each sensitive API use case.

*Native lib and build:*
- `securityspy-LL-004` — 16 KB alignment hard-blocks production submission.
- `securityspy-LL-005` — AAR transitive `.so` files exist even with no custom native code.
- `securityspy-LL-007` — ML Kit dynamic-download module unavailable on Pixel; bundle for sensitive-trigger apps.
- `securityspy-LL-008` — Samsung One UI battery management requires foreground-service promotion.

*Submission process:*
- `securityspy-LL-006` — first release on Play Console has no staged-rollout option.
- `securityspy-LL-010` — pre-submission grep audit catches what eyeballing misses.
- `securityspy-LL-019` — D-U-N-S required for Individual → Organization upgrade; gates multi-app strategy.
- `securityspy-LL-020` — W-9 for single-member disregarded LLC requires SSN, not LLC EIN.
- `securityspy-LL-021` — email infra (Zoho + SPF/DKIM/DMARC) gates Play Console contact email.
- `vibespin-LL-007` — `versionCode` collisions cost rebuild cycles.
- `vibespin-LL-008` — display name + package name drift across config files.
- `vibespin-LL-009` — Android adaptive-icon pipeline (legacy + adaptive XML).
- `vibespin-LL-010` — 14-day / 12-tester closed-test rule is per-app on personal accounts.
- `vibespin-LL-021` — Play Console deobfuscation warning is benign but reads as blocker.

*Auth and lifecycle for native Android:*
- `securityspy-LL-016` — companion-object flag for cross-activity auth state; BiometricPrompt itself causes pause/resume.
- `securityspy-LL-017` — PIN-creation lockout race; onboarding-flow integration test required.
- `securityspy-LL-018` — AccessibilityService events fire multiple times per app open (debounce required).

*Trade-relevant Vibe Spinner submission lessons:*
- `vibespin-LL-002` — Capacitor plugins auto-declare permissions at install time.
- `vibespin-LL-005` — Stripe payment links → must be Google Play Billing on Android.
- `vibespin-LL-006` — paywall feature claims must map to built features.
- `vibespin-LL-017` — keystore creation discipline (also CC-8).

*Listing-side and storefront from website inventory:*
- `roretech-website-LL-005` — self-drawn Google Play badge → use official assets only.
- `roretech-website-LL-013` — content rating (IARC) ≠ Target Audience setting.
- `roretech-website-LL-014` — developer name + home address publicly visible on listing.
- `roretech-website-LL-015` — privacy policy material edits trigger re-review on next submission.

**Becomes HQ artifact:** `eos/checklists/PLAY_STORE_SUBMISSION.md`

The checklist will be structured in five sections matching the
Firebase Setup Checklist's five-section template (CC-2 + CC-5 +
CC-11):
1. Account and entity provisioning (one-time per developer account)
2. App creation and identity (per-app, locked early)
3. Build and native-lib audit (per-release)
4. Disclosure, listing, and trademark (per-release; sensitive-app variant adds stalkerware grep)
5. Submission and post-submission verification (per-release)

A separate variant adds the surveillance-adjacent app section (5 of
the 22 SecuritySpy lessons) for products in that category.

---

## DC-B. External data importers (CSV, PDF, broker exports, RSS feeds)

**Why this is its own cluster.** Twelve lessons across Edge Journal
(broker CSVs and PDFs) and Trade Edge (CSV journals, RSS feeds). The
common thread is that user-supplied or vendor-supplied data has every
edge case, and the parser finds them all. Multiple lessons here are
the kind that destroy financial integrity if shipped — wrong P&L,
phantom positions, blended cost basis.

**Source lessons:**

*Vocabulary, encoding, and format:*
- `roreedge-LL-001` — exact-match (`=== "BUY"`) vs compound action verbs.
- `roreedge-LL-003` — UTF-8 BOM broke broker auto-detection.
- `roreedge-LL-008` — Schwab "7-Mar" date silently parsed as year 2001.
- `roreedge-LL-014` — PDF text-extraction reflowed lines; position-based parsing was brittle.
- `tradeedge-LL-011` — broker CSV multiline quoted fields require quote-aware parsing.

*Exhaustive enumeration and silent skips:*
- `roreedge-LL-007` — Robinhood corporate-action codes (SPR/MRGS/SCXL/REC) silently dropped.
- `roreedge-LL-009` — TDA option rows passed through as equity trades.
- `roreedge-LL-021` — sells with no buy in window silently skipped.

*Dedup, hash, and idempotency:*
- `roreedge-LL-006` — overlapping CSVs imported twice; needed file-hash guard.
- `tradeedge-LL-012` — tolerance dedup collapsed legitimate corporate-action records.

*State and key consistency:*
- `roreedge-LL-004` — two functions reading same data with different grouping keys.
- `roreedge-LL-005` — same-symbol positions on different brokers blended; isolation unit is `(broker, account, symbol)`.
- `roreedge-LL-010` — active filter state lost on page reload; persist UI state.
- `tradeedge-LL-009` — localStorage is per-origin, not per-tab.
- `tradeedge-LL-010` — `Array.sort()` not guaranteed stable; deterministic tiebreaker required.

*Math and reconciliation:*
- `roreedge-LL-002` — synthetic sell at $0.0001 generated multi-million-dollar fake losses (P&L math at wrong stage).

**Becomes HQ artifact:** `eos/checklists/EXTERNAL_DATA_IMPORTER.md`

Five-section structure:
1. Real samples before spec (CC-4 application)
2. Encoding and ingestion normalization (BOM, line endings, quote-aware)
3. Vocabulary and exhaustive enumeration (every code has an explicit handler)
4. State, isolation, and dedup (file-hash at intake, single grouping-key helper, deterministic sort, persisted UI selection)
5. Math correctness (reconcile against known-good external source before merge)

---

## DC-C. AI publishing pipelines (LLM content + external publication)

**Why this is its own cluster.** Ten lessons across XAGENT, Trade
Edge, and Edge Journal that only exist because the product publishes
LLM-generated content externally or consumes copyrighted source
material into an AI pipeline. This is genuinely new surface area —
none of these lessons existed pre-AI products.

**Source lessons:**

*Hallucination and grounding:*
- `xagent-LL-008` — single-call generation hallucinated specific numbers, dates, "yesterday" framings.
- `xagent-LL-009` — web search returns popular content, not necessarily recent; need recency floor.
- `xagent-LL-010` — verifier strictness must be tunable per pipeline level.

*Human review and release discipline:*
- `xagent-LL-019` — every AI-generated tweet auto-published; no human review for first 100.
- `tradeedge-LL-019` — "ship and use solo before evangelizing" gate.

*IP and source vetting:*
- `xagent-LL-017` — close-paraphrase risk on copyrighted source material.
- `tradeedge-LL-016` — `thepatternsite.com` had explicit AI-training prohibition; statistics had to be removed.
- `tradeedge-LL-017` — claim-level source tagging required for AI reference docs.

*Cost and UI:*
- `xagent-LL-014` — Preview button silently consumed Anthropic credits at full pipeline cost.

*Consent surface for AI feature in privacy-first product:*
- `roreedge-LL-016` — AI Review needs dedicated consent modal (also CC-9).

**Becomes HQ artifact:** `eos/checklists/AI_PUBLISHING_PIPELINE.md`

Five-section structure:
1. Source and IP vetting (terms-of-use check before any source enters the pipeline)
2. Pipeline architecture (research → draft → verify → human-review → publish; recency floors; claim-level verification)
3. Consent and disclosure (dedicated consent surface for AI features in privacy-first products)
4. Cost and UI (per-call cost band displayed; cheapest path for preview)
5. Release graduation (first N outputs human-reviewed; auto-publish is a graduation, not a default)

---

## DC-D. Desktop / Electron distribution

**Why this is its own cluster.** Five lessons in Edge Journal that
all come from "desktop distribution is not web distribution." Web
intuition (push and it works) doesn't transfer; OS-level trust gates
(Gatekeeper, SmartScreen) are hard requirements; cross-platform CI is
non-trivial.

**Source lessons:**
- `roreedge-LL-012` — large video files in git history blocked GitHub push (gitignore on day one).
- `roreedge-LL-013` — `electron-window-state` package didn't persist; manual JSON simpler.
- `roreedge-LL-017` — Mac Gatekeeper / Windows SmartScreen kill conversion without code-signing.
- `roreedge-LL-018` — cross-platform Electron build needs CI matrix from day one.
- `roreedge-LL-022` — localStorage vs electron-store decision deferred correctly (one architectural concern per session, also CC-6).

**Becomes HQ artifact:** `eos/checklists/ELECTRON_DESKTOP_DISTRIBUTION.md`

Five-section structure:
1. Phase 0 readiness (Apple Developer enrollment, Windows EV cert ordering, gitignore)
2. Build configuration (cross-platform CI matrix from first build)
3. Signing and notarization (per-platform, lead times measured in weeks)
4. Distribution UX (unsigned-download warnings → signed; auto-update strategy)
5. State and persistence (localStorage vs electron-store decision is its own session)

---

## DC-E. Backend service hardening (Node + Express + Railway/PaaS patterns)

**Why this is its own cluster.** Seven lessons across Trade Edge and
XAGENT that share a backend-service-hardening theme: env vars, rate
limits, auth posture, dependency hygiene, deploy verification.

**Source lessons:**
- `xagent-LL-005` — Railway env-var propagation silently fails; `/diag` endpoint required (also CC-7).
- `xagent-LL-015` — browser-side scheduler stops on laptop sleep; servers run servers.
- `xagent-LL-016` — Railway auto-deploy silently skipped a push (also CC-7).
- `xagent-LL-018` — in-memory state lost on every redeploy; persistence is a Definition-of-Done item.
- `tradeedge-LL-002` — parallel API fan-out blew rate limit; queue from day one.
- `tradeedge-LL-005` — `nano env` created `env`, not `.env`; setup script + startup validator.
- `tradeedge-LL-006` — exact pinning, no carets in `package.json`.
- `tradeedge-LL-007` — supply-chain malware checks: installed version, not declared.
- `tradeedge-LL-018` — no-auth backend mutating routes need explicit `127.0.0.1` binding in code.

**Becomes HQ artifact:** `eos/checklists/BACKEND_SERVICE_HARDENING.md`

Five-section structure:
1. Configuration (env-var validators that fail loudly, `.env.example` discipline)
2. Dependencies (exact-pin in `package.json`, supply-chain incident protocol, prefer-direct-HTTP-over-SDK)
3. Architecture (server-side primitives for anything needing to survive sleep/close, persistence is opt-in not afterthought)
4. Rate limits and external APIs (queue from day one, per-endpoint tier verification)
5. Deploy verification (`/health` with SHA, post-deploy SHA-comparison ritual)
6. Security posture (bind to `127.0.0.1` for unauthenticated mutating routes; no exception)

---

## DC-F. Web hosting and static-site deploy hygiene

**Why this is its own cluster.** Eight lessons in the website
inventory plus three from Vibe Spinner about the marketing site
specifically. Different from backend hardening — the failure modes
here are content drift, asset wiring, deploy verification, and
multi-product-domain SW scope.

**Source lessons:**

*Content and asset wiring:*
- `roretech-website-LL-002` — filename whitespace shipped via git rename slip.
- `roretech-website-LL-003` — HTML referenced PNGs not committed.
- `roretech-website-LL-004` — footer links without `.html` extension; netlify-fallback masking.
- `roretech-website-LL-006` — nested `<a>` tags from product card pattern (HTML validity).
- `roretech-website-LL-011` — SVG curved text needed viewBox padding and cross-browser smoke test.

*Multi-product domain hygiene (also CC-10):*
- `roretech-website-LL-007` — `/games/vibespinner/` "do not touch" needed every prompt.
- `vibespin-LL-003` / `LL-014` / `LL-016` — SW scope on multi-product domain.

*Deploy verification:*
- `roretech-website-LL-017` — verification was "implicit, not documented"; needs `DEPLOY_CHECKLIST.md`.
- `roretech-website-LL-012` — Search Console "errors" that are correct behavior; SEO triage reference.

**Becomes HQ artifact:** `eos/checklists/WEB_DEPLOY.md` and supporting:
- `eos/runbooks/SEO_TRIAGE.md`
- `eos/checklists/PWA_DEPLOYMENT.md` (already named in CC-10)

---

## DC-G. Firebase + Flutter setup (the original ask)

**Why this is its own cluster.** The eight VibeFire Phase 1 gaps,
already analyzed and structured by the operator. The dump's own
"Pattern analysis" identifies four shapes (A: missing manual setup
steps; B: missing canonical-tool execution — `flutterfire configure`;
C: boilerplate refactor footguns; D: implementation didn't match plan).

**Source items:**
- VibeFire Gap 1 — Cloud Functions deploy permission missing.
- VibeFire Gap 2 — Artifact Registry cleanup policy not auto-configured.
- VibeFire Gap 3 — Android app never registered in Firebase Console.
- VibeFire Gap 4 — Debug SHA-1 fingerprint not added to Firebase.
- VibeFire Gap 5 — Debug SHA-256 fingerprint not added to Firebase.
- VibeFire Gap 6 — `google-services.json` was stub or fabricated.
- VibeFire Gap 7 — `MainActivity.kt` package path mismatch with AndroidManifest.
- VibeFire Gap 8 — `ActionCodeSettings` missing the `url` field for Magic Link.

**Cross-cutting hooks:** Gap 7 and Gap 8 are also CC-4 (real device
end-to-end test as non-skippable gate). Gap 8 is also CC-6
(implementation didn't match plan; this is what "verify implementation
matches plan" gate solves).

**Becomes HQ artifact:** `eos/checklists/FIREBASE_FLUTTER_SETUP.md`

The dump itself contains a draft v1.0 structure — the HQ checklist
will refine the wording and absorb cross-cutting items. Five-section
structure (matches the template the dump's pattern analysis derived):
1. Cloud-side provisioning (one-time, manual; IAM, cleanup policy, Blaze)
2. SDK / canonical-tool execution (`flutterfire configure` is the canonical command)
3. Authentication / signing material (SHA-1 + SHA-256 both required)
4. Service-specific configuration (Magic Link `ActionCodeSettings`)
5. End-to-end smoke test (non-skippable Phase 1 exit gate)

Plus: an Android-boilerplate-after-Flutter-create section for Gap 7
(`MainActivity.kt` path matching).

This becomes the *template* for all future service-setup checklists
(AWS, Stripe, OAuth Provider, etc.) — same five-section shape.

---

# Section 3 — Singleton Lessons

> Lessons that are high-value but don't cluster with 2+ others. Kept
> here so the project that hits the same situation can find them. They
> may move into a cluster as more lessons accumulate.

- `roreedge-LL-019` — splitting monolithic file cuts AI session token use ~60%. Cross-applies to `tradeedge-LL-020`. **Singleton becoming a pair → flag for promotion to a cross-cutting pattern when a third lesson lands.**
- `xagent-LL-004` — Claude.ai artifact viewer CSP blocks fetch to external backends; test in real browser tab from disk.
- `xagent-LL-011` — verifier needs to handle "no recent news" gracefully (LL-009 partial overlap).
- `xagent-LL-012` — nano editing introduced syntax errors that crashed deploy; pre-push syntax check.
- `xagent-LL-020` — multi-day build with no persistent project doc; lessons-as-you-go.
- `tradeedge-LL-003` — prefer direct HTTP over SDK when the project has an HTTP client (also touches DC-E).
- `tradeedge-LL-004` — `rss-parser` failures masked as syntax errors; manual parsing for controlled-shape feeds.
- `tradeedge-LL-015` — auto-firing network calls block first paint; defer with `setTimeout`.
- `vibespin-LL-001` — `touch-action: none` on global selector breaks WebView taps; element-scoped only.
- `vibespin-LL-011` — "Coming Soon" placeholder pages without rendering bug fixed.
- `vibespin-LL-012` — Capacitor `cap sync` overwrites generated assets; never edit `assets/public/`.
- `vibespin-LL-013` — Android adaptive-icon pipeline (also DC-A `vibespin-LL-009`).
- `vibespin-LL-015` — Capacitor sync directionality (`www/` is source).
- `vibespin-LL-026` — Capacitor 8 uses Swift Package Manager not CocoaPods; no `.xcworkspace` file. Time-saver on every new iOS project.
- `vibespin-LL-027` — macOS keychain GUI dialogs reject valid passwords that `security unlock-keychain` accepts in terminal. High severity for iOS dev sessions.
- `vibespin-LL-033` — Capacitor 8 iOS scaffold produces 60+ files across SPM directory structure; project-map reference needed before reviewing diff. Cross-applies to any future Capacitor-Android-from-scratch session.
- `vibespin-LL-039` — macOS Finder auto-renames duplicates via drag-drop (` 2.md`, ` 3.xml`); periodic `git status` discipline + `.audit/` grep pattern catches.
- `roreedge-LL-011` — JS temporal dead zone (`const` before declaration); lint from day one.
- `roreedge-LL-013` — `electron-window-state` package replaced with manual JSON.
- `securityspy-LL-011` / `LL-012` / `LL-013` — *Note: not numerically present in the inventory I read; these IDs were referenced in a Theme that listed LL-009/010/013/014/015 — verify on next pass.*
- `roretech-website-LL-018` — `.gitignore` rationale should be inline comment.

---

# Section 4 — Lesson ID Index

> Every source lesson, listed once, with where it's absorbed. Use this
> as the audit trail when verifying any HQ checklist item against the
> lesson it derives from.

## Security SPY (22 lessons)

| ID | Title (short) | Absorbed in |
|---|---|---|
| LL-001 | Stalkerware-pattern dead code | CC-2, DC-A |
| LL-002 | Per-API prominent disclosures | CC-5, DC-A |
| LL-003 | Store listing API documentation | CC-5, CC-11, DC-A |
| LL-004 | 16 KB native lib alignment | CC-4, DC-A |
| LL-005 | AAR transitive `.so` files | DC-A |
| LL-006 | First release no staged rollout | DC-A |
| LL-007 | ML Kit dynamic vs bundled | DC-A |
| LL-008 | Samsung One UI battery | DC-A |
| LL-009 | Defensive permission over-declarations | CC-2, CC-9, DC-A |
| LL-010 | Pre-submission grep audit | CC-2, DC-A |
| LL-011 | (not yet read in detail) | — |
| LL-012 | (not yet read in detail) | — |
| LL-013 | (not yet read in detail) | — |
| LL-014 | App-name field as policy surface | CC-11, DC-A |
| LL-015 | Privacy policy framing | CC-9, DC-A |
| LL-016 | Companion-object flag for auth | DC-A |
| LL-017 | PIN lockout race; onboarding test | CC-4, DC-A |
| LL-018 | AccessibilityService event debounce | DC-A |
| LL-019 | D-U-N-S for Org account | DC-A |
| LL-020 | W-9 for disregarded LLC | DC-A |
| LL-021 | Email infra DNS migration | DC-A |
| LL-022 | Rebuild beats appeal | DC-A |

## Vibe Spinner (39 lessons)

| ID | Title (short) | Absorbed in |
|---|---|---|
| LL-001 | `touch-action: none` global | Singleton |
| LL-002 | Capacitor permission auto-decl | CC-9, DC-A |
| LL-003 | SW scope on multi-product domain | CC-10, DC-F |
| LL-004 | DEV button shipped to production | CC-2 |
| LL-005 | Stripe vs Google Play Billing | CC-5, DC-A |
| LL-006 | Paywall feature claims | CC-11, DC-A |
| LL-007 | `versionCode` collisions | DC-A |
| LL-008 | App identity drift | CC-1, DC-A |
| LL-009 | Adaptive icon pipeline | DC-A |
| LL-010 | 14-day per-app closed test | CC-5, DC-A |
| LL-011 | Coming Soon placeholder | Singleton |
| LL-012 | Capacitor cap sync overwrite | Singleton |
| LL-013 | Adaptive icon pipeline (overlap) | Singleton |
| LL-014 | SW cache name versioning | CC-10, DC-F |
| LL-015 | Capacitor `assets/public/` | Singleton |
| LL-016 | Multi-product domain SW | CC-10, DC-F |
| LL-017 | Keystore ad-hoc handling | CC-8, DC-A |
| LL-018 | Descriptive vs prescriptive prompts | CC-6 |
| LL-019 | Same bug shipped twice | CC-4 |
| LL-020 | Two-folder www drift | CC-1 |
| LL-021 | Deobfuscation warning triage | DC-A |
| LL-022 | iOS pre-flight discipline (Apple Dev, xcode-select, Bundle ID) | CC-1, CC-6 — **CC-13 candidate** |
| LL-023 | Working-tree state before platform-add operation | CC-2, CC-6 |
| LL-024 | npm install protocol during supply-chain campaign | CC-2, DC-E — **new DC candidate** |
| LL-025 | Two-phase Claude Code prompt pattern with sentinel sentence | CC-6 — **CC-14 candidate** |
| LL-026 | Capacitor 8 uses SPM not CocoaPods | Singleton |
| LL-027 | macOS keychain GUI rejects valid password | Singleton |
| LL-028 | iOS plugin static analysis demands purpose strings | CC-5, DC-A — **iOS sibling of LL-002** |
| LL-029 | Xcode auto-increment writes to archive, not pbxproj | CC-1, CC-8, DC-A |
| LL-030 | Closed-testing signal beyond defect reports | CC-4 — **CC-15 candidate** |
| LL-031 | Manual version bumping (4 numbers × 2 files) | CC-1, DC-A — **App Identity Manifest target** |
| LL-032 | Release notes from CHANGELOG, never invented in dialog; storefront-truth propagates cross-surface | CC-1, CC-11, DC-A — **PLAY_STORE_SUBMISSION v0.3 + H18+H10+H9 cross-pattern** |
| LL-033 | Capacitor 8 iOS scaffold project map (60+ files, SPM model) | Singleton |
| LL-034 | iOS `CURRENT_PROJECT_VERSION` symmetric across Debug + Release configs | CC-1, DC-A — **iOS release-discipline twin of LL-029** |
| LL-035 | Network-tab verification on real device catches CDN leaks grep misses | CC-2, CC-4 — **H12 sub-rule extension** |
| LL-036 | Privacy Nutrition Label answers apply to submitted binary, not source | DC-A — **Pre-submission gate item** |
| LL-037 | Apple W-9 doesn't handle single-member LLC disregarded entities | CC-5 — **per-platform tax-form sub-rule of H13** |
| LL-038 | Multi-product legal pages share template, share template errors | CC-1, CC-11 — **legal-entity canonical source needed** |
| LL-039 | macOS Finder phantom duplicates in working tree | Singleton |

## RORE Edge Journal (22 lessons)

| ID | Title (short) | Absorbed in |
|---|---|---|
| LL-001 | Compound action verbs | CC-3, CC-4, DC-B |
| LL-002 | Synthetic sell P&L math | CC-4, DC-B |
| LL-003 | UTF-8 BOM detection | DC-B |
| LL-004 | Two functions, two grouping keys | CC-1, DC-B |
| LL-005 | Cross-broker cost basis | DC-B |
| LL-006 | Overlapping CSV file-hash dedup | DC-B |
| LL-007 | Corporate-action codes silent skip | CC-3, DC-B |
| LL-008 | Schwab "7-Mar" year 2001 | CC-3, DC-B |
| LL-009 | TDA option rows as equity | CC-3, DC-B |
| LL-010 | Active filter state lost | DC-B |
| LL-011 | JS temporal dead zone | Singleton |
| LL-012 | Large videos in git history | DC-D |
| LL-013 | electron-window-state replaced | Singleton |
| LL-014 | PDF text-extraction reflow | CC-4, DC-B |
| LL-015 | Sample data localStorage isolation | CC-9 |
| LL-016 | AI consent dedicated modal | CC-9, DC-C |
| LL-017 | Code-signing notarization Phase 0 | CC-8, DC-D |
| LL-018 | Cross-platform CI matrix | DC-D |
| LL-019 | Monolith → split for token use | Singleton (pair candidate) |
| LL-020 | Branding name late-correction | CC-1 |
| LL-021 | Sells without buys silent skip | CC-3, DC-B |
| LL-022 | Architectural concern per session | CC-6 |

## Trade Edge AI (20 lessons)

| ID | Title (short) | Absorbed in |
|---|---|---|
| LL-001 | Per-endpoint tier verification | CC-5, DC-E |
| LL-002 | Rate-limit queue from day one | DC-E |
| LL-003 | Prefer direct HTTP over SDK | Singleton |
| LL-004 | rss-parser hidden failures | Singleton |
| LL-005 | `nano env` not `.env` | DC-E |
| LL-006 | Exact-pin no carets | DC-E |
| LL-007 | Supply-chain installed version | DC-E |
| LL-008 | Hardcoded calendar staleness | CC-3 |
| LL-009 | localStorage per-origin | DC-B |
| LL-010 | Sort tiebreaker for money | DC-B |
| LL-011 | Multiline quoted CSV | DC-B |
| LL-012 | Tolerance dedup tolerance trap | DC-B |
| LL-013 | Browser cache + stale localStorage | CC-4 |
| LL-014 | HTML/JS split stray script tag | CC-6 |
| LL-015 | Defer network calls on init | Singleton |
| LL-016 | AI-training source vetting | DC-C |
| LL-017 | Citation tags for AI ref docs | DC-C |
| LL-018 | No-auth backend localhost-only | DC-E |
| LL-019 | Use solo before evangelizing | DC-C |
| LL-020 | Monolith split for AI context | Singleton (pair candidate) |

## XAGENT (20 lessons)

| ID | Title (short) | Absorbed in |
|---|---|---|
| LL-001 | Anthropic API billing separate | CC-5 |
| LL-002 | X API automated-posting tier | CC-5 |
| LL-003 | OAuth permission bounce-then-regen | CC-5 |
| LL-004 | Claude.ai artifact CSP | Singleton |
| LL-005 | Railway env vars `/diag` | CC-3, CC-7, DC-E |
| LL-006 | Hardcoded keys rotation ticket | CC-8, DC-E |
| LL-007 | Real keys in chat code examples | CC-8 |
| LL-008 | LLM hallucination grounding pipeline | DC-C |
| LL-009 | Web search recency floor | DC-C |
| LL-010 | Verifier strictness tunable | DC-C |
| LL-011 | "No recent news" graceful | Singleton |
| LL-012 | nano-introduced syntax errors | Singleton |
| LL-013 | Local file vs deploy skew | CC-3, CC-7 |
| LL-014 | Preview cost band UI | DC-C |
| LL-015 | Browser scheduler vs server | DC-E |
| LL-016 | Railway auto-deploy silently skipped | CC-3, CC-7, DC-E |
| LL-017 | Close-paraphrase IP risk | DC-C |
| LL-018 | In-memory state across redeploy | DC-E |
| LL-019 | Auto-publish before human review | DC-C |
| LL-020 | No persistent project doc | Singleton |

## RORE Tech Website (18 lessons)

| ID | Title (short) | Absorbed in |
|---|---|---|
| LL-001 | Two privacy.html files | CC-1 |
| LL-002 | Filename whitespace | CC-2 |
| LL-003 | HTML-referenced PNGs not committed | CC-2, DC-F |
| LL-004 | Footer link without .html | CC-2, DC-F |
| LL-005 | Self-drawn Play badge | CC-11, DC-A |
| LL-006 | Nested anchors in product card | DC-F |
| LL-007 | `/games/vibespinner/` do-not-touch | CC-10, DC-F |
| LL-008 | Delaware vs Massachusetts | CC-1, CC-2 |
| LL-009 | "Vibe Studios Spinner" drift | CC-1 |
| LL-010 | Per-product billing language | CC-1, CC-5 |
| LL-011 | SVG curved text viewBox | DC-F |
| LL-012 | Search Console false positives | DC-F |
| LL-013 | IARC vs Target Audience | CC-5, DC-A |
| LL-014 | Developer home address public | DC-A |
| LL-015 | Privacy policy re-review | DC-A |
| LL-016 | Pasted context vs CLAUDE.md | CC-1 |
| LL-017 | Implicit vs documented deploy verify | DC-F |
| LL-018 | .gitignore rationale comments | Singleton |

## VibeFire Phase 1 Gaps (8 gaps)

| ID | Title (short) | Absorbed in |
|---|---|---|
| Gap 1 | Cloud Functions deploy IAM | DC-G |
| Gap 2 | Artifact Registry cleanup policy | DC-G |
| Gap 3 | Android app not registered (`flutterfire configure`) | DC-G |
| Gap 4 | SHA-1 not added | DC-G |
| Gap 5 | SHA-256 not added | DC-G |
| Gap 6 | google-services.json fabricated | DC-G |
| Gap 7 | MainActivity package path | CC-4, DC-G |
| Gap 8 | ActionCodeSettings url missing | CC-4, CC-6, DC-G |

---

# What's next

This inventory is the foundation. The next artifacts derive from it
in this order:

1. **HQ STANDARDS update** — adds new H-sections to `CLAUDE_MD_TEMPLATE.md`
   for cross-cutting patterns CC-1 through CC-11. Becomes Phase 0.2 of
   the Manual.
2. **Firebase + Flutter Setup Checklist** (DC-G) — the most urgent,
   needed before VibeFire Phase 2.
3. **Play Store Submission Checklist** (DC-A) — high-traffic; Security
   SPY shipping under it; Vibe Spinner needs it next.
4. **External Data Importer Checklist** (DC-B) — needed when the Edge
   Journal next adds a broker.
5. **AI Publishing Pipeline Checklist** (DC-C) — needed before XAGENT
   moves further or any other AI-publishing product launches.
6. **Backend Service Hardening Checklist** (DC-E) — applies to XAGENT
   and any future backend.
7. **Web Deploy + PWA Deployment Checklists** (DC-F + CC-10) — applies
   to roretech.com and any future PWA.
8. **Electron Distribution Checklist** (DC-D) — applies to Edge Journal
   and any future desktop product.

Each checklist will cite the lesson IDs it derives from. New lessons
flow into this inventory first, then propagate to whichever
checklist(s) they touch.

---

*End of inventory.*

---

## v0.2 update — 2026-05-16

**Added.** 11 new Vibe Spinner lessons (LL-022 through LL-032)
from Phase 2 iOS scaffold → TestFlight (2026-05-14 → 2026-05-15)
and Phase 3 session 1 Top Speed feature (2026-05-16).

**Rich-content source.** Full lesson detail for LL-022 through
LL-032 lives in the additions document drafted 2026-05-16,
committed to HQ. This INVENTORY.md holds only the summary rows.

**Cross-cutting pattern candidates flagged** (decisions deferred
to next monthly review): CC-13 First-Platform Pre-Flight (LL-022),
CC-14 Structural vs instructional gates in Claude Code prompts
(LL-025), CC-15 Tester signal beyond defect reports (LL-030),
new DC candidate NPM_INSTALL_PROTOCOL (LL-024).

---

## v0.3 update — 2026-05-19

**Added.** 7 new Vibe Spinner lessons (LL-033 through LL-039)
from Phase 3 close-out (2026-05-19): the substantial privacy-
honesty work (font and image local-bundling), legal pages review
across three products, and App Store Connect admin completion.

**Richer content for existing entries.** LL-023, LL-025, LL-026,
LL-027, LL-028, LL-029, and LL-032 each gained richer treatment
in the 2026-05-19 source document — the underlying lessons are
the same, but the analysis (root cause, what would have prevented
it) is more developed. The summary rows in this INVENTORY.md were
updated to reflect the sharper framing; the full content lives in
the rich-content reference file committed alongside this update.

**Rich-content source.** Full lesson detail for LL-033 through
LL-039 (plus the richer treatment of LL-023/025/026/027/028/029/032)
lives in `eos/lessons/source/vibespin-LL022-LL035-from-handoff-2026-05-19.md`,
drafted from the Vibe Spinner Phase 4 handoff document during the
Phase 3 close-out.

**Net-new lessons.**

- **LL-033** — Capacitor 8 iOS scaffold project map. 60+ files
  across `ios/App/App/`, `ios/App/App.xcodeproj/`, `ios/App/CapApp-SPM/`.
  Singleton; companion to LL-022 (Apple Dev pre-flight) and
  LL-023 (working-tree state). Reference doc needed in HQ.

- **LL-034** — `CURRENT_PROJECT_VERSION` must be symmetric across
  Debug AND Release configs in `project.pbxproj`. Discovered after
  the second iOS archive when a Debug build showed wrong version
  on simulator. Pre-archive check item.

- **LL-035** — Network-tab verification on real device catches CDN
  data leaks that grep + static analysis miss. Surfaced two real
  privacy violations (Google Fonts CDN, Unsplash CDN) during
  Privacy Nutrition Label prep on 2026-05-19. Both were bundled
  locally before App Store submission. H12 sub-rule extension.

- **LL-036** — Privacy Nutrition Label answers apply to the
  submitted binary, not source on main. Easy to answer the App
  Store Privacy questionnaire honestly against future intent while
  the actual in-flight binary contradicts. Pre-submission gate
  item: build SHA must be ≥ SHA at which privacy answers were
  last verified accurate.

- **LL-037** — Apple W-9 form doesn't handle single-member LLC
  disregarded entities cleanly. RORE Tech LLC enrolled as
  Organization; W-9 offers Individual/sole-prop, LLC-C-Corp,
  LLC-S-Corp, LLC-Partnership — none match single-member-LLC-
  with-EIN-disregarded-entity. Apple Support ticket open. Per-
  platform tax-form sub-rule of H13.

- **LL-038** — Multi-product website legal pages share a template;
  they share the template's errors. Delaware governing-law claim
  was wrong (RORE Tech LLC is Massachusetts-domiciled), and the
  error propagated to three products. Vibe Spinner-specific
  Roundtable caught it first. H9 (canonical source) + H10 (audit
  pattern) cross-pattern. **CC-12 promotion candidate confirmed
  as second instance after Vibe Spinner CHANGELOG drift** — but
  note that the *pattern* is different (legal-template drift, not
  CHANGELOG drift). Worth surfacing at monthly review whether
  these are one cross-cutting pattern (canonical-source drift
  across products) or two separate patterns.

- **LL-039** — macOS Finder auto-renames create phantom duplicates
  (` 2.md`, ` 3.xml` suffixes) in working tree. Light lesson,
  singleton, `.audit/` grep pattern addition.

**Cross-cutting pattern observations** (decisions still deferred):

- **CC-12 candidate (CHANGELOG drift) — first instance from
  Vibe Spinner adoption 2026-05-12, but no second instance has
  surfaced. LL-038 (legal template drift) is a *related* pattern
  but not the same.** Monthly review should consider whether
  CC-12 is "CHANGELOG drift specifically" or broader "canonical-
  source drift across N surfaces" — the latter captures both
  CHANGELOG drift and legal-template drift and is the more
  durable framing.

- **CC-14 candidate (structural vs instructional gates in
  Claude Code prompts) — strongly reinforced by LL-025's
  richer content.** The two-phase prompt with sentinel sentence
  pattern is now the working countermeasure across both feature
  work and bug-fix work. Promote to CC-14 at next monthly review
  unless an alternative pattern emerges.

- **App Identity Manifest tooling target** (LL-031) gains LL-034
  as another instance. Tooling task remains queued.

**Process note — ID collision resolved.** This v0.3 update
incorporates a new lesson file (`lessons-LL022-LL035-for-HQ.md`)
that used a different ID numbering scheme than v0.2's INVENTORY.md.
The merge preserved v0.2's IDs as canonical, integrated richer
content from the new file where lessons matched conceptually, and
gave net-new lessons new IDs (LL-033 through LL-039). The
collision is itself a lesson: **lesson IDs must be assigned by
HQ at filing time, not by the product project at drafting time.**
Product-side drafts should use placeholder IDs (LL-NEXT-1,
LL-NEXT-2, ...) and HQ assigns final IDs during merge. Otherwise
two parallel sessions inevitably collide. A meta-intake captures
this for next monthly review.

**Carry-over from v0.1.** Two minor follow-ups remain:
(a) re-read the SecuritySpy inventory section LL-011/012/013
which were elided in the truncated read,
(b) watch for a third "monolith split for token use" lesson
which would promote the Edge Journal LL-019 / Trade Edge LL-020
pair into a cross-cutting pattern.

**Total now.** 139 cross-product lessons + 8 VibeFire gaps = 147
absorbed.
