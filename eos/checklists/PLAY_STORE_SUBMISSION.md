# Play Store Submission Checklist

> **Version:** 0.1
> **Owner:** RORE Tech HQ (`rore-tech-hq/eos/checklists/PLAY_STORE_SUBMISSION.md`)
> **When to use.** Every Play Store submission, including
> resubmissions. Walked before pressing Submit in Play Console.
>
> **What this catches.** All 22 SecuritySpy submission lessons,
> plus 7 Vibe Spinner submission lessons, plus 5 website-to-store
> integration lessons. The largest single domain in the inventory.
> Apple App Store will get a parallel checklist when iOS
> submissions begin.
>
> **The bar.** Would walking this checklist have prevented:
> - The v1.0.8 stalkerware-pattern rejection? Section 4.
> - The v1.0.8 missing-second-disclosure rejection? Section 4.
> - The 16 KB alignment hard-block at production submission?
>   Section 3.
> - The Stripe-on-Android billing-policy violation? Section 4.
> - The 14-day closed-test surprise on Vibe Spinner? Section 1.
> - The home-address public-listing? Section 1.
>
> Yes to all six. Section by section.
>
> **Lesson trace.** DC-A in `eos/lessons/INVENTORY.md`.
> Specifically: `securityspy-LL-001` through `LL-022`;
> `vibespin-LL-002`, `LL-005`, `LL-006`, `LL-007`, `LL-008`,
> `LL-009`, `LL-010`, `LL-017`, `LL-021`; `roretech-website-LL-005`,
> `LL-013`, `LL-014`, `LL-015`. Plus cross-cutting CC-2, CC-5,
> CC-11, H10, H13, H18.
>
> **Surveillance-adjacent variant.** Products in the
> surveillance-adjacent category (Security SPY profile) walk
> *all* sections plus the additional Section 4-Sensitive items
> marked with **[SENS]**. Standard apps (Vibe Spinner profile)
> skip the [SENS] items. The category is named in the product's
> CLAUDE.md P3 (per-product hard rules).
>
> **Prologue — External Service Kickoff matrix.** Before walking
> Sections 1–6 below, complete the matrix below for the Play
> Console / Google Play surface. *(H13 application.)*

---

## Prologue — Play Store / Google Play matrix

| Question | Answer |
|---|---|
| Developer account type | [Individual / Organization] |
| D-U-N-S number on file | [Yes (date issued) / No / Pending] |
| Account creation date | [YYYY-MM-DD — for closed-test policy implications, see Section 1] |
| App distribution model | [Free / Paid / Free with subscription / Free with IAP] |
| Payment provider for IAP/subs (Android) | [Google Play Billing — required, no other option] |
| Sensitive APIs declared | [List — Accessibility, Camera, Location, etc.] |
| Surveillance-adjacent classification | [Yes / No — drives whether [SENS] items apply] |

---

## Section 1 — Account and entity provisioning (one-time per developer account)

> Items that are one-time-per-account but easy to miss because
> they appear during the first app submission. Locking these
> early saves the rest of the surface.

- [ ] **Account-type decision made deliberately.** *(`securityspy-LL-019`.)*
  - Individual: simpler enrollment, but on personal accounts
    created after Nov 2023, every new app is subject to the
    14-day / 12-tester closed-test rule.
  - Organization: requires D-U-N-S, but exempt from the per-app
    closed-test rule.
  - *Decision tree:* if planning more than one app within 6
    months, apply for D-U-N-S *before* creating the Play
    Console account. The 30-day D-U-N-S delay saves 14 days
    per subsequent app.

- [ ] **D-U-N-S applied for if needed.** D&B issues in ~30 days.
  Track in `RORE_TECH_ORG.md` Section 9 open items until issued.

- [ ] **W-9 (or equivalent tax form) submitted with correct TIN.**
  *(`securityspy-LL-020`.)* For RORE Tech LLC (single-member
  disregarded LLC, no Form 8832 filed): personal SSN as TIN,
  personal legal name on Line 1, "RORE Tech LLC" on Line 2,
  "Individual/sole proprietor or single-member LLC" on Line 3.
  EIN entry triggers TIN-name mismatch and forces manual ID
  verification.

- [ ] **Public developer address is non-residential.**
  *(`roretech-website-LL-014`.)* Play Console → Account Details.
  Use registered LLC address, registered agent, mail forwarding,
  or UPS Store mailbox. Home address publicly indexed alongside
  a paid app is a doxxing risk.

- [ ] **Support contact email** has working SPF/DKIM/DMARC.
  Required by Play Console for app contact email.
  *(`securityspy-LL-021`.)* If migrating from a previous email
  provider: use `eos/runbooks/EMAIL_INFRA_MIGRATION.md` for the
  DNS sequencing.

---

## Section 2 — App creation and identity (per-app, locked early)

- [ ] **Package name (applicationId) chosen carefully** and
  documented in `org/PRODUCTS.md`. Once published, the package
  name is immutable. Locking it before the first AAB upload is
  critical. *(`vibespin-LL-008`.)*

- [ ] **App identity is consistent across all config files.**
  `strings.xml`, `capacitor.config.json` (if applicable),
  `manifest.json`, `index.html` `<title>`, `build.gradle`.
  Pre-build check that greps every config and asserts they all
  match. Drift across files is the most common identity bug.
  *(`vibespin-LL-008`.)*

- [ ] **App name in the Play Listing field is policy-audited.**
  *(`securityspy-LL-014`.)* For surveillance-adjacent products
  specifically: every word in the name field that connotes
  covert/hidden/silent capture is a policy risk. "Security SPY -
  Silent Lens" had "Silent" as the most prominent word in
  search results — higher policy risk than internal branding.
  Strip such words from the listing-name field; tag for
  in-app-only use.

- [ ] **Adaptive-icon pipeline complete.** *(`vibespin-LL-009`.)*
  Both legacy `ic_launcher.png` (all densities) AND the
  adaptive icon XML (`mipmap-anydpi-v26/ic_launcher.xml`) AND
  the foreground/background drawables it references. Replacing
  only the legacy PNGs misses adaptive icons on Android 8+.
  Use Android Studio's Image Asset Studio rather than `sips` —
  generates all required artifacts in one pass. After replacement:
  `Build → Clean Project` (Gradle cache) AND uninstall the app
  from the device before reinstalling (icon cache).

- [ ] **`versionCode` ledger started.** *(`vibespin-LL-007`.)*
  Maintain a version-code ledger in the Phase Protocol or
  RELEASE_PLAN.md showing which code went to which track. Treat
  `versionCode` as monotonically increasing; never reuse, never
  decrement to "fix" an upload error. Best: automate the bump
  in a release script that reads the highest used code from
  Play Console (or the local ledger) and increments by one.

- [ ] **Signing-key birth certificate run** for the release
  keystore. See `eos/checklists/SIGNING_KEY_BIRTH_CERTIFICATE.md`
  Section A (irrecoverable material). *(`vibespin-LL-017`.)*

---

## Section 3 — Build and native-lib audit (per-release)

> Native-library compliance hardens at *production submission*
> in ways that don't appear at closed-test. The pre-launch
> report severity does not reflect submission severity.

- [ ] **Native-library inventory taken on the release AAB.**
  *(`securityspy-LL-005`.)* Every project ships `.so` files
  through AAR transitive dependencies even when the project has
  no custom native code (CameraX, ML Kit, biometric libs).
  ```
  unzip -l app-release.aab | grep '\.so$'
  ```
  Document every native library, its source AAR, and its
  alignment status. Re-run after any dependency upgrade,
  including patch versions.

- [ ] **16 KB memory page alignment verified for every `.so`.**
  *(`securityspy-LL-004`.)* Google's Nov 1, 2025 policy makes
  16 KB alignment a hard error at production submission for apps
  targeting Android 15+. Any "Medium" 16 KB warning in the
  pre-launch report is a hard-block at production submission;
  fix pre-closed-test, not at submission time.
  ```
  llvm-readelf -S <unzipped-aab>/lib/arm64-v8a/<libname>.so
  ```
  Sections must align at 0x4000.

- [ ] **AGP and NDK versions current.** AGP 8.7.3+ and NDK
  r29 (29.0.14206865) for symbol stripping. Set
  `packaging.jniLibs.useLegacyPackaging = false` explicitly in
  `build.gradle`.

- [ ] **ML Kit choice documented.** *(`securityspy-LL-007`.)*
  Dynamic-download (smaller APK, fragile module resolution; can
  fail on Pixel) vs bundled (larger APK, universal). For any
  sensitive-trigger app, default to bundled. Decision captured
  in an ADR.

- [ ] **Manufacturer-specific test matrix walked.**
  *(`securityspy-LL-008`.)* At minimum: Samsung One UI device,
  Pixel device. Both pre-Firebase-Test-Lab. Samsung's One UI
  battery management aggressively backgrounds non-foreground
  services; AccessibilityService apps need foreground-service
  promotion during sensitive operations.

- [ ] **Pre-submission audit (`.audit/`) ran clean on the AAB.**
  All standard categories: stalkerware-patterns,
  deprecated-strings, hardcoded-secrets, debug-affordances. See
  `eos/audit/README.md`.

---

## Section 4 — Disclosure, listing, and trademark

> The story the user (and the reviewer) sees. Drift between code
> and copy is the densest rejection-cause cluster.

### 4.1 Disclosure architecture (universal)

- [ ] **One affirmative-consent prominent disclosure per
  sensitive API.** *(`securityspy-LL-002`.)* Not "one disclosure
  per app." Each sensitive API (Accessibility, Camera, Microphone,
  Location, etc.) gets its own dedicated dialog with five
  sections (what, why, how, control, opt-out). Capture or
  invocation is gated on a per-API consent flag in
  SharedPreferences.

- [ ] **Each disclosure has a revocation surface.** A banner,
  a settings toggle, or both — visible affordance to revoke
  consent and stop the API's use.

- [ ] **Store listing description documents each sensitive API
  by name** with explicit use case, separate from the in-app
  disclosure. *(`securityspy-LL-003`.)* The in-app disclosure
  is *not* sufficient — Google checks the public listing
  separately.

- [ ] **Disclosure video re-recorded** if any in-app disclosure
  copy changed. URL updated in Play Console → App content →
  relevant declaration (Accessibility services, etc.).

### 4.2 [SENS] Surveillance-adjacent additional items

> Walk these for products classified surveillance-adjacent
> (Security SPY profile). Skip for standard apps (Vibe Spinner
> profile).

- [ ] **[SENS] Stalkerware-pattern grep ran on the release AAB.**
  *(`securityspy-LL-001`, `LL-009`.)* Patterns include:
  `setComponentEnabledSetting`, `COMPONENT_ENABLED_STATE_DISABLED`,
  `excludeFromRecents`, hidden-icon, dialer-code-launch, device
  admin receivers, `SYSTEM_ALERT_WINDOW`. Dead code in this
  category is not dead to the reviewer. If a symbol exists in
  the AAB, it is a declared capability.

- [ ] **[SENS] Permission and capability minimization audited.**
  *(`securityspy-LL-009`.)* For each declared permission and
  each accessibility config flag, prove via grep that the API
  is actually called. If not, delete it. `SYSTEM_ALERT_WINDOW`
  in particular: never declare unless explicitly used by app
  code, not framework code. Defensive declarations are
  stalkerware signals.

- [ ] **[SENS] Privacy policy framing matches anti-X (not X-tool)
  posture.** *(`securityspy-LL-015`.)* "Anti-theft" and
  "personal-device-security" framing rather than "captures
  silently." Includes intended-use warning card, jurisdictional
  notice (BIPA, CUBI, GDPR Art. 9, LGPD), explicit
  third-party-capture acknowledgment, and an "absent
  capabilities list" naming what the app does not do.

### 4.3 Storefront truth (universal)

- [ ] **Every feature in store metadata, paywall modals, and
  paid-tier descriptions maps to a built feature.**
  *(`vibespin-LL-006`; H18.)* Unbuilt items labeled "Coming
  soon" with target version, or removed. Reviewers test paid
  features.

- [ ] **Brand assets from official sources only.**
  *(`roretech-website-LL-005`; H18.)* Google Play badge from
  `https://play.google.com/intl/en_us/badges/`. Min height 60px,
  aspect ratio preserved, alt text "Get it on Google Play",
  badge wrapped in `<a target="_blank" rel="noopener">` to the
  canonical store URL. Never redrawn.

- [ ] **Content rating questionnaire vs Target Audience setting
  filled correctly.** *(`roretech-website-LL-013`.)* These are
  two distinct systems. IARC content rating rates *content* (no
  violence, no gambling, no profanity → "Everyone" / "3+");
  Target Audience names the audience (drives the "Designed for
  Families" eligibility and other policy gates). Filling both
  requires understanding which question controls which displayed
  badge.

### 4.4 Payment policy

- [ ] **Payment provider matches platform policy.**
  *(`vibespin-LL-005`.)* Android digital purchases: Google Play
  Billing only. Stripe (or any external provider) for digital
  goods is grounds for rejection. Code that hardcodes a payment
  URL is conditionalized on `Capacitor.getPlatform()` (or
  equivalent) at build time. Web → Stripe/Paddle fine. Apple →
  StoreKit required.

---

## Section 5 — Submission and post-submission

- [ ] **First production release strategy decided.**
  *(`securityspy-LL-006`.)* First releases on Play Console have
  no staged-rollout option. Rollout works by replacing existing
  installs; with zero existing installs there is nothing to
  gradually replace. Velocity control alternative:
  delayed-marketing-seed (app live but quiet for 3-5 days, ramp
  marketing only after Vitals confirm clean).

- [ ] **Closed test cohort recruited if required.**
  *(`vibespin-LL-010`.)* For personal accounts created after
  Nov 2023: 14 days, 12 testers, per-app. Plan from Day 0 of
  submission. Tester pool from prior apps may be reusable. Once
  D-U-N-S issues and account upgrades to Organization,
  exemption applies for new apps.

- [ ] **Privacy policy diff log updated** if material edits
  shipped. *(`roretech-website-LL-015`.)* Every material edit
  gets logged in `org/PRIVACY_CHANGES.md` (or per-product). Next
  submission expects +1 review cycle even though the URL
  didn't change. Set expectation rather than be surprised
  mid-review.

- [ ] **Deobfuscation file decision made.** *(`vibespin-LL-021`.)*
  Optional but informational; benign warning. Not a blocker.
  Triage card available in `eos/runbooks/PLAY_CONSOLE_WARNINGS.md`.

### 5.1 Rejection-response decision rule

- [ ] **If rejection cite names a code/pattern present in the
  AAB or listing: rebuild and resubmit, don't appeal.**
  *(`securityspy-LL-022`.)* Appeal only when the cite is
  factually wrong. "The code exists but isn't called" is a
  weaker argument than "the code is gone." Bundle audit-driven
  proactive fixes into the rebuild — never ship a "minimum-fix"
  resubmission.

---

## Section 6 — Authentication and lifecycle (when applicable)

> Only walked if this submission ships any auth or lifecycle
> changes. Otherwise N/A.

- [ ] **AccessibilityService events use debounce by default.**
  *(`securityspy-LL-018`.)* `COOLDOWN_MS = 5000L` or similar.
  Treat single-event triggers as the buggy default; require
  explicit reasoning before removing the debounce. Multi-window
  apps fire 3+ state-changed events per open.

- [ ] **Auth-on-resume uses companion-object flag, not Intent
  extras.** *(`securityspy-LL-016`.)* Intent extras persist
  across recents/dock relaunches in unexpected ways.
  BiometricPrompt itself triggers a pause/resume cycle, so any
  defensive lock in `onResume()` will fight the biometric flow.

- [ ] **Onboarding-flow integration test in closed-test exit
  criteria.** *(`securityspy-LL-017`.)* Fresh install + camera
  permission dialog + first auth. PIN-creation lockout race and
  similar bugs are invisible during dev iteration; they only
  show on fresh installs.

---

## Gate decision

At the end of the walk, one of the following is recorded:

- **GATE PASSED** — all items PASS, N/A, or WAIVE with reason;
  submission is ready.
- **GATE PASSED WITH WAIVERS** — same, with explicit waivers
  carrying named follow-up owners and target dates. Waivers in
  Section 3 (16 KB alignment) or Section 4 (disclosure
  architecture, [SENS] items) are particularly high-risk;
  review carefully.
- **GATE FAILED** — one or more items cannot be marked.
  Submission is not ready. Specifically: no surveillance-
  adjacent app submits without all [SENS] items PASS.

---

## What's intentionally not in this checklist

- **iOS / App Store submission.** Will get its own checklist
  when iOS submissions begin. Many parallel concepts (review
  process, age rating, privacy nutrition labels) but enough
  Apple-specific differences to warrant a separate document.
- **Pre-launch report walkthrough.** Owned by the platform; this
  checklist names which report findings matter (16 KB warnings)
  and which are noise (deobfuscation file).
- **Post-launch monitoring.** Lives in the Launch Plan template,
  not here.
- **Marketing strategy.** Out of scope. The checklist verifies
  the *truthfulness* of marketing copy (Section 4.3), not the
  copy itself.

---

*Source-of-truth checklist. Maintained in
`rore-tech-hq/eos/checklists/PLAY_STORE_SUBMISSION.md`. v0.1
absorbs DC-A lessons listed in the lesson trace above. Largest
single-domain checklist; will likely split into a base
checklist plus a [SENS] supplement if it grows past 8 sections.*
