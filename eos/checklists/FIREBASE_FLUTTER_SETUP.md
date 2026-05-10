# Firebase + Flutter Setup Checklist

> **Version:** 0.1
> **Owner:** RORE Tech HQ (`rore-tech-hq/eos/checklists/FIREBASE_FLUTTER_SETUP.md`)
> **Synced into product projects:** at phase kickoff for any product
> using Firebase + Flutter, or when the operator runs the bootstrap
> script for a new such project.
>
> **What this catches.** The eight gaps that surfaced in VibeFire
> Phase 1 (May 9–10, 2026) — and the pattern-class each one represents.
> Built so a future RORE Tech project doing Firebase + Flutter setup
> walks this checklist before the first `firebase deploy` or `flutter
> run`, and ships Phase 1 without re-learning what VibeFire learned.
>
> **The bar.** Would walking this checklist have caught the eight gaps
> before they cost time? Section by section, yes. If anything below
> doesn't earn that bar, cut it.
>
> **How to use.** Copy this file into the product's `docs/checklists/`
> at phase kickoff. Walk it section by section. Mark each item PASS,
> WAIVE (with reason), or N/A (with reason). Sections 1–5 happen
> *before* any `firebase deploy` or `flutter run` against the project.
> Section 6 is the non-skippable end-to-end smoke test that gates
> phase exit.
>
> **Lesson trace.** This checklist derives from VibeFire Gaps 1–8 and
> cross-cutting patterns CC-4, CC-5, CC-6 in
> `eos/lessons/INVENTORY.md`.
>
> **Template role.** The five-section structure (cloud provisioning →
> canonical-tool execution → signing material → service-specific
> config → end-to-end smoke test) is the *standard shape* for all
> future service-setup checklists — AWS, Stripe, OAuth provider, etc.
> Each future checklist follows the same shape, even if the contents
> differ.

---

## Prerequisites (run before walking this checklist)

These items are not part of the checklist proper — they are the
state the project must already be in before this checklist applies.

- [ ] **Phase Protocol document for this phase exists** in
  `docs/protocols/`, with the Universal Phase Exit Gate populated
  from the current HQ template.
- [ ] **CLAUDE.md HQ STANDARDS section is at the current HQ version**
  (see version stamp at top of HQ STANDARDS section).
- [ ] **The project's `docs/checklists/` folder contains a synced
  copy of this Firebase Flutter Setup Checklist** at the version it
  was synced from.

If any prerequisite is not true, stop and resolve it before
proceeding. The bootstrap script (if it exists) handles all three
automatically; otherwise the operator does it manually.

---

## How items get marked

- **PASS** — verified, evidence cited (commit, screenshot, output
  log, file path).
- **WAIVE** — explicitly accepted as not done, with a one-sentence
  reason and a follow-up owner.
- **N/A** — does not apply to this phase or product, with a
  one-sentence reason.

A checklist with un-marked items is a checklist that hasn't been
walked. A checklist with more than two `WAIVE` entries is a signal
to pause and ask whether the project is actually ready.

---

## Section 1 — Cloud-side provisioning (one-time per project)

> Manual setup steps in the Firebase Console and Google Cloud
> Console that no SDK auto-configures. Done once per Firebase
> project. *(VibeFire Gaps 1, 2.)*

- [ ] **Firebase project created** at `console.firebase.google.com`.
  Project ID recorded in `CLAUDE.md` P4 (architecture overview).

- [ ] **Authentication providers enabled** in Firebase Console →
  Build → Authentication → Sign-in method. Document which providers
  in the Phase Protocol (Email/Password, Email link, Google,
  Apple, etc.).

- [ ] **Firestore enabled in LOCKED mode** (NOT test mode).
  Firebase Console → Build → Firestore Database → Create Database →
  Start in production mode (locked). Test mode default-allows reads
  and writes, which is a default-allow security posture and a
  Compliance push-back trigger. *(Cross-references H16 — privacy
  commitments are architectural constraints.)*

- [ ] **Cloud Storage rules set to authenticated-only or stricter.**
  Default-allow rules are a security posture violation regardless
  of intent.

- [ ] **Upgraded to Blaze plan.** Required for Cloud Functions, for
  many third-party integrations, and for reaching outside Google
  domains. Free tier (Spark) is insufficient past basic auth.

- [ ] **Monthly budget alert set.** Firebase Console → ⚙ → Usage
  and billing → Details & settings → Modify plan → Budget alerts.
  Recommended starting value: $25/month for solo dev, scale up as
  product proves out. *(Cross-references H13 — billing surface is
  per-product, per-platform.)*

- [ ] **Compute service account has Storage Object Viewer IAM role.**
  Google Cloud Console → IAM → find
  `{project-number}-compute@developer.gserviceaccount.com` → grant
  Storage Object Viewer (and Storage Object Admin for newer
  projects per Google's post-2024 requirement). **This is the gap
  that broke VibeFire's first `firebase deploy --only functions`.**
  *(VibeFire Gap 1.)*

  **Verification:** Google Cloud Console → IAM → search the
  compute service account → confirm Storage Object Viewer is in
  the role list. Screenshot or copy the role list into the Phase
  Protocol.

- [ ] **Artifact Registry cleanup policy decided in advance, not at
  the deploy prompt.** When the first `firebase deploy --only
  functions` runs, the CLI prompts: *"No cleanup policy detected
  for repositories in us-central1."* Default value at the prompt
  is "1" (1 day) which is too aggressive. Recommended value: **30
  days**. Type 30 when the prompt appears. *(VibeFire Gap 2.)*

  **Cross-reference:** an *expected interactive prompts during
  first Firebase deploy* runbook would catch this even better. Add
  to `docs/runbooks/` if this team will deploy to Firebase more
  than once.

---

## Section 2 — Canonical-tool execution (`flutterfire configure`)

> The single command that registers the Flutter app with the Firebase
> project, generates `firebase_options.dart`, downloads
> `google-services.json` (Android) and `GoogleService-Info.plist`
> (iOS), and prompts for SHA fingerprints. Skipping this command
> caused four of VibeFire's eight Phase 1 gaps. *(VibeFire Gaps
> 3, 4, 5, 6.)*

**The rule:** when one canonical tool exists for a setup task, the
checklist mandates the tool. Manual steps are an escape hatch for
when the tool fails — not a default workflow. *(Cross-references
inventory pattern CC-6 — canonical-tool-first.)*

- [ ] **From the Flutter project root, run
  `flutterfire configure --project=<project-id>`.** Replace
  `<project-id>` with the actual Firebase project ID (visible in
  Firebase Console → ⚙ → Project settings → General).

- [ ] **Select platforms.** For Android-only Phase 1, select
  Android. iOS is added when iOS phase begins (typically Phase 7+
  per the SecuritySpy pattern, when Apple Developer enrollment is
  complete).

- [ ] **VERIFY: Firebase Console → Project Settings → Your apps
  shows the app**, with the correct package name (e.g.
  `app.vibefire.android`). If the apps list says "There are no
  apps in your project," the registration failed — re-run
  `flutterfire configure` from the Flutter project root, not from
  somewhere else. *(VibeFire Gap 3.)*

- [ ] **VERIFY: `lib/firebase_options.dart` exists** and its
  `projectId` field matches the actual project. This file is what
  the Flutter app uses to initialize Firebase. If it doesn't exist
  or contains placeholder values, `flutterfire configure` failed
  silently. Re-run.

- [ ] **VERIFY: `app/android/app/google-services.json` is the real
  file**, not a stub or fabricated copy. Open the file, find the
  `project_info.project_id` field, and confirm it matches
  `firebase projects:list` output. *(VibeFire Gap 6.)*

  **Why this verification exists:** Claude Code has been observed
  to create `google-services.json` as a placeholder when it
  expects Firebase data but the project isn't actually registered.
  The file *exists* but is fabricated. The 5-second
  `project_id` check catches this in seconds. *(General pattern:
  any time an external service is configured, a "verify the
  config file is the real thing" step belongs in the
  checklist.)*

- [ ] **Add `google-services.json` to `.gitignore`** if it contains
  any restricted-distribution credentials. (Most Firebase
  configurations are safe to commit; check Google's current
  guidance for the project's auth setup.)

---

## Section 3 — Signing fingerprints (Android)

> SHA-1 and SHA-256 fingerprints from the debug keystore (Phase 1)
> and the release keystore (production phases) are required for
> Magic Link deep link verification, App Links, Google Sign-In,
> and other Firebase features that rely on App Links / Smart Lock.
> SHA-1 alone is insufficient on Android 13+. Both are mandatory.
> *(VibeFire Gaps 4, 5.)*

- [ ] **Generate debug signing report.**
  ```
  cd android && ./gradlew signingReport
  ```
  Captures both SHA-1 and SHA-256 for the debug variant. Output
  also includes `Variant`, `Config`, `Store`, `Alias`, and `Valid
  until` — copy the entire `Variant: debug` block into the Phase
  Protocol so it's not regenerated on next phase.

- [ ] **Add debug SHA-1 to Firebase Console.** Firebase Console →
  Project Settings → Your apps → Android → SHA certificate
  fingerprints → Add fingerprint. *(VibeFire Gap 4.)*

- [ ] **Add debug SHA-256 to Firebase Console.** Same path. **Both
  required.** *(VibeFire Gap 5.)*

- [ ] **Re-download `google-services.json`** after adding
  fingerprints. Firebase regenerates the file with the new SHAs
  embedded. The downloaded file replaces
  `app/android/app/google-services.json`.

- [ ] **VERIFY: re-grep the project ID in the new
  `google-services.json`** matches `firebase projects:list`
  output. (Same check as Section 2, repeated because the file
  just changed.)

- [ ] **For release phases (not Phase 1):** repeat the same five
  steps for the release keystore — generate signing report, add
  release SHA-1 + SHA-256, re-download `google-services.json`.
  *(Cross-references H15 — credentials at moment of creation;
  release keystore is irrecoverable, has its own birth-certificate
  checklist.)*

---

## Section 4 — Service-specific configuration

> The API-call boilerplate that's easy to get wrong because the
> field is optional in the SDK type signature but required by the
> service at runtime. *(VibeFire Gap 8 was an instance of this
> exact pattern — `ActionCodeSettings.url` is "optional" in the
> Flutter SDK but required by the receiving end.)*

### Magic Link / Email Link Authentication

- [ ] **`ActionCodeSettings` passed to `sendSignInLinkToEmail`
  includes all of the following fields**, even those that look
  optional in the type signature:
  - `url`: `https://{project-id}.firebaseapp.com/__/auth/action`
  - `handleCodeInApp`: `true`
  - `androidPackageName`: the actual package name
  - `androidMinimumVersion`: `'1'` (or higher per app's
    `minSdkVersion`)
  - `dynamicLinkDomain`: **NOT SET.** Firebase Dynamic Links is
    deprecated. Setting this on a new project is wrong.

  *(VibeFire Gap 8 was specifically the missing `url` field.)*

- [ ] **Receive-side handler calls
  `signInWithEmailLink(emailLink: <captured deep link URL>)`.**
  The captured deep link URL is the full URL Android passed to
  the app via the Intent — not a parsed substring.

- [ ] **Authorized domains in Firebase Console include
  `{project-id}.firebaseapp.com`.** Auto-added on project creation
  but verify. Firebase Console → Authentication → Settings →
  Authorized domains.

- [ ] **For production with custom domain:** `assetlinks.json` is
  hosted at `<your-domain>/.well-known/assetlinks.json` with the
  SHA-256 fingerprint of the **production** signing key
  (not debug). Without this, App Links won't auto-verify and the
  link will open in a browser instead of the app.

### Cloud Functions (if used in this phase)

- [ ] **Functions deployed successfully on first attempt.** If the
  first deploy fails with a permission error, see Section 1's
  Storage Object Viewer requirement.

- [ ] **No `functions` directory committed without an explicit
  decision in the Phase Protocol.** Cloud Functions on Blaze plan
  charge per-invocation; deploying functions that aren't intended
  to run yet creates a small but real recurring cost.

### Firestore (if used in this phase)

- [ ] **Security rules deployed and not in test mode.** Test mode
  is `allow read, write: if request.time < timestamp.date(...)`
  with a 30-day expiry — fine for one weekend of dev, dangerous
  thereafter. Rules in production mode require explicit
  `allow read: if <condition>` for each operation.

---

## Section 5 — Android boilerplate after Flutter create

> Tool-specific gotchas that Flutter's tooling doesn't auto-handle
> when the org or package is renamed. Flutter sets `--org`-derived
> values in Gradle config but doesn't relocate Kotlin source files.
> The result is `ClassNotFoundException` on app launch — the build
> succeeds, the install succeeds, the launch crashes within
> milliseconds. *(VibeFire Gap 7.)*

- [ ] **`AndroidManifest.xml` declares the launch activity at the
  correct package path.** Open
  `android/app/src/main/AndroidManifest.xml` and find the
  `<activity android:name="..." />` for the launch activity.

- [ ] **`MainActivity.kt` exists at the file path matching the
  declared package.** If the manifest says
  `app.vibefire.android.MainActivity`, the file lives at
  `android/app/src/main/kotlin/app/vibefire/android/MainActivity.kt`.

- [ ] **The `package` declaration at the top of `MainActivity.kt`
  matches the path.** First line of the file should be `package
  app.vibefire.android` (or the actual package). A mismatched
  package declaration crashes the launch even when the file is in
  the right path.

- [ ] **Run `flutter clean && flutter pub get`** after any package
  rename. Flutter caches the previous build's structure aggressively.

---

## Section 6 — End-to-end smoke test (NON-SKIPPABLE phase exit gate)

> Real device, real artifact, real input. CI passes is necessary,
> not sufficient. Phase is not done until this section passes.
> *(Cross-references H12 — real samples, real devices, real
> artifacts; VibeFire Gap 7 and Gap 8 would both have been caught
> here if the section had existed and been mandatory.)*

- [ ] **Connected Android device or emulator with Phase 1's target
  Android version.** For VibeFire Phase 1, this was a Pixel 9
  on Android 15. The smoke test that's run on a stale-API
  emulator doesn't catch the bugs that bite real users.

- [ ] **`flutter run` executes against the connected device.**
  Build succeeds, install succeeds, app launches, app stays open.
  *(If the app crashes on launch with `ClassNotFoundException`,
  Section 5 wasn't completed — return there.)*

- [ ] **No errors in `flutter logs` during launch.** Specifically
  watching for: `Firebase init failed`, `No app registered`,
  package-name mismatches, asset-loading failures.

- [ ] **Primary user flow added or changed this phase runs
  end-to-end.** For VibeFire Phase 1, the flow was: enter email →
  tap "Send Link" → email arrives → tap link from device → app
  authenticates → lands on Hearth. Define the equivalent flow for
  the current phase in the Phase Protocol; the smoke test walks
  *that specific flow*, not "the app generally works."

- [ ] **For Magic Link / Email Link flows specifically:**
  - [ ] Email arrives in inbox within 30 seconds (check spam folder).
  - [ ] Tapping link from device opens the app (NOT a browser).
  - [ ] App authenticates user successfully.
  - [ ] App lands on the correct post-auth screen.
  - [ ] Sign-out works and returns to sign-in screen.
  - [ ] Cold restart preserves authenticated state.

- [ ] **Implementation matches the plan articulated in the Phase
  Protocol kickoff.** Specifically: every value the kickoff plan
  named (URLs, package names, field values, threshold numbers)
  appears in the implementation as written. *(Cross-references H12
  — implementation didn't match plan was VibeFire Gap 8's exact
  pattern. The plan correctly named the `ActionCodeSettings.url`
  value; implementation skipped it.)*

  **How to verify:** open the kickoff plan section of the Phase
  Protocol; for each named value, grep the implementation for
  that value. If a named value is absent from the implementation,
  either the plan changed (update the protocol) or the
  implementation skipped it (fix the implementation).

---

## Gate decision

At the end of the walk, one of the following is recorded in the
Phase Protocol:

- **GATE PASSED** — all items PASS, N/A, or WAIVE with reason; the
  Firebase + Flutter setup is complete and the phase can proceed
  to its next gates (the Universal Phase Exit Gate's other
  sections).
- **GATE PASSED WITH WAIVERS** — same, but with explicit waivers
  carrying named follow-up owners and target dates.
- **GATE FAILED** — one or more items cannot be marked. The
  Firebase + Flutter setup is not complete. The phase does not
  proceed until they can be.

A GATE FAILED is not a problem. A gate that was never walked is.

---

## What's intentionally not in this checklist

- **iOS-specific items.** When iOS phase begins, iOS-specific
  sections will be added (or a separate Apple Developer + iOS
  Setup Checklist will be sourced from the Apple Developer lessons
  inventory once enough lessons accumulate).
- **Production keystore handling.** Lives in
  `eos/checklists/SIGNING_KEY_BIRTH_CERTIFICATE.md` (per H15) —
  not duplicated here.
- **Cost-control runbooks.** A future
  `eos/runbooks/FIREBASE_COST_CONTROL.md` will cover budget
  alerts, quota investigations, and unexpected billing
  responses. Not in scope for setup.
- **Firestore data modeling, Functions architecture, Authentication
  flow design.** Those are product design decisions, captured in
  ADRs in `docs/decisions/`, not in setup checklists.

---

## What this checklist is the template for

The five-section structure here is the standard shape for all
future service-setup checklists. When AWS, Stripe, or an OAuth
provider needs its own checklist:

1. **Cloud-side provisioning** (one-time, manual)
2. **SDK or canonical-tool execution** (the one command that
   does the registration correctly; all manual steps go here only
   if the canonical tool doesn't exist)
3. **Authentication / signing material** (keys, tokens,
   fingerprints, certificates)
4. **Service-specific configuration** (the API-call boilerplate
   that's easy to get wrong; SDK type signatures that lie about
   required fields)
5. **End-to-end smoke test** (non-skippable phase exit gate)

If a future service-setup checklist doesn't fit this shape, that's
information — either the checklist is structured wrong, or the
service has a sixth category we haven't seen yet, in which case
the template gets revised here.

---

*Source-of-truth checklist. Maintained in
`rore-tech-hq/eos/checklists/FIREBASE_FLUTTER_SETUP.md`. v0.1
absorbs VibeFire Gaps 1–8 and cross-cutting patterns CC-4, CC-5,
CC-6 from `eos/lessons/INVENTORY.md`. Updates flow to product
projects via the standard cycle.*
