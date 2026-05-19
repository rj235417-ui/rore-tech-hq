# Vibe Spinner — Lessons LL-022 through LL-035 (append file for HQ)

**Purpose.** Lessons surfaced during Vibe Spinner Phase 2 close (LL-022 →
LL-029) and Phase 3 close (LL-030 → LL-035), drafted in full
`lessons-inventory.md` format for filing into HQ's
`eos/lessons/INVENTORY.md`. Format matches the existing LL-001 →
LL-021 entries in `vibespin-native/lessons-inventory.md`.

**How to use.** Append directly to HQ's INVENTORY.md, then cross-
reference into the relevant HQ STANDARDS (H1–H18) where each lesson's
"What would have prevented it" line implies a standard update.
Several of these lessons already justify standards that are written
into CLAUDE.md's HQ STANDARDS section (e.g. LL-025 → H14, LL-026/027
→ ios-pre-submission discipline, LL-030 → H12 sub-rule); the trace is
already in place in HQ docs.

**Source.** Phase 4 handoff document §5 (LL-030-035 drafted in compact
form) + handoff §6 (LL-022-029 as one-line summaries) + corroborating
detail from `CLAUDE.md` P3/P6/P10 (purpose strings, SPM model,
keychain workaround, two-phase prompt pattern) and `CHANGELOG.md`
v1.0.5 entry (Build 1 ITMS-90683 rejection).

**Bar applied.** Same as the original inventory: would this checklist
item have prevented a future me from losing >2 hours? Everything below
clears that bar; nothing has been invented to pad the count.

---

## Lessons

---

ID: vibespin-LL-022
Title: Working-tree state must be understood before any platform-add operation
Type: process-gap
Area: ci-cd / capacitor
Severity: medium
Phase encountered: Phase 2 — adding iOS platform to vibespin-native
What happened: Before running `npx cap add ios`, the working tree had
uncommitted changes from in-progress Android work and at least one
stale untracked file. `cap add ios` scaffolded an entire iOS project
on top of that state, mixing scaffold output with pre-existing
in-progress changes in the same `git status`. Sorting which files
were Capacitor-generated vs operator-authored ate session time and
created uncertainty about whether to commit the iOS scaffold as one
commit or split it. Eventually consolidated into a clean iOS scaffold
commit, but only after extra `git stash` / restore work.
Root cause: Capacitor's `cap add` operation generates dozens of files
across a new top-level directory plus modifies `package.json`,
`capacitor.config.json`, and lockfiles. It treats the current branch
as a clean working surface and gives no warning when uncommitted
changes are present. Without operator discipline to ensure a clean
working tree, the scaffold output and the operator's work end up
visually indistinguishable in `git status`.
What we did: After the fact, used `git stash` + careful `git add -p`
to separate scaffold output from operator work. Committed the iOS
scaffold as its own commit. Carried forward the discipline of
running `git status` and confirming clean before any
platform-modifying command.
What would have prevented it: HQ "Platform-Modifying Operation"
checklist: before any of `cap add`, `cap update`, `cap sync` with
new plugins, `npm install` of a Capacitor plugin, or equivalent,
require the working tree to be clean. Either commit, stash, or
explicitly accept the mixing. The pre-operation step is
`git status` → confirm clean → proceed. Make this a one-line
addition to any cap-related runbook.
Playbook-worthy: yes
Tags: capacitor, cap-add, working-tree, git-discipline, scaffold-mixing

---

ID: vibespin-LL-023
Title: Capacitor 8 iOS scaffold lands an entire native project — the diff is unreadable without explicit categorization
Type: process-gap
Area: capacitor / native-ios
Severity: low (related to LL-022)
Phase encountered: Phase 2 — first iOS scaffold commit
What happened: `npx cap add ios` on Capacitor 8 produced 60+ files
across `ios/App/App/`, `ios/App/App.xcodeproj/`, `ios/App/CapApp-SPM/`,
plus `Info.plist`, `AppDelegate.swift`, `Assets.xcassets/`,
`Base.lproj/`, `Package.swift`, `.gitignore`, `debug.xcconfig`. A
single `git status` listing it as untracked is not useful — no way
to know at a glance what is "the iOS project shell" vs what is "the
parts I will customize." First read took ~20 minutes to understand
the layout enough to commit confidently.
Root cause: Native scaffold output is normal for any cross-platform
tool, but Capacitor 8's SPM model (vs Capacitor 6's CocoaPods model)
adds `CapApp-SPM/` as a sibling structure that pre-2025 docs don't
mention, increasing the unfamiliarity.
What we did: Reviewed the Capacitor 8 docs and the generated
structure file-by-file before committing. Documented the
"never edit" subset in CLAUDE.md P5: `ios/App/App/public/`,
`xcuserdata/`, `*.xcuserstate`, etc.
What would have prevented it: HQ "Capacitor 8 iOS Project Map"
reference doc — one-pager listing every directory `cap add ios`
produces and categorizing each as (a) scaffold (don't touch),
(b) editable (you'll customize this), or (c) generated (output of
`cap sync`, never edit). Read this before reviewing the diff. Same
map should exist for Capacitor 8 Android.
Playbook-worthy: yes
Tags: capacitor-8, ios-scaffold, spm-model, project-map, onboarding

---

ID: vibespin-LL-024
Title: macOS Keychain GUI password dialogs reject the same password that `security unlock-keychain` accepts in terminal
Type: integration-gap
Area: native-ios / signing
Severity: medium
Phase encountered: Phase 2 — first signed iOS archive; recurred at every archive in the phase
What happened: When archiving in Xcode for upload to App Store
Connect, Xcode (and separately Keychain Access for cert/profile
work) presents a password dialog to unlock the login keychain so it
can sign. Repeatedly, the same Mac login password the operator was
using to log into the Mac was rejected by the GUI dialog —
"password was wrong" — even though it was demonstrably the right
password. Workaround discovered: run `security unlock-keychain
~/Library/Keychains/login.keychain-db` in Terminal. That command
accepts the same password, unlocks the keychain for the session,
and subsequent Xcode archive operations succeed without re-prompting.
Surfaced THREE times in Phase 2 alone; treated as a one-off the
first two times before being internalized as a real pattern.
Root cause: Unknown — appears to be a long-standing macOS
inconsistency between SecurityAgent's GUI password verification
path and the `security` command-line tool. The two enter the
password through different code paths; the CLI path is more
permissive about login-keychain unlocking. Not officially
documented by Apple as far as the operator could find.
What we did: Internalized terminal `unlock-keychain` as the default
first step before any archive operation. Documented in CLAUDE.md
P6 ("Keychain quirk (macOS)" subsection). Stopped treating it as
an error to debug; treat it as setup ritual.
What would have prevented it: HQ "Mac Signing Setup" pre-archive
checklist line: before opening Xcode for archive, run `security
unlock-keychain ~/Library/Keychains/login.keychain-db` in Terminal
and enter Mac password. Skip this step only at your peril. Two
sessions ate ~30 min each before this was internalized.
Playbook-worthy: yes
Tags: macos-keychain, codesigning, xcode, security-cli, gui-vs-terminal

---

ID: vibespin-LL-025
Title: Two-phase Claude Code prompt pattern with sentinel sentence holds where single-message "stop" gates do not
Type: process-gap
Area: ci-cd / agent-workflow
Severity: medium
Phase encountered: Phase 2 (iOS signing debug, twice); Phase 3 (font swap, image swap, twice more)
What happened: For non-trivial Claude Code tasks (feature
implementation, version bumps, refactors that touch multiple
files), operator initially used single-message prompts with embedded
"STOP — diagnosis only, do not edit" gates. The gate was bypassed in
practice multiple times — Claude Code would diagnose AND begin
editing in the same response, sometimes against the wrong hypothesis.
Operator then switched to a structural two-phase pattern: Phase 1
prompt asks for diagnosis + plan and MUST end with the literal
sentinel sentence "Phase 1 complete. Awaiting approval to proceed
to Phase 2." Phase 2 only happens after explicit operator approval
in a follow-up message. The two-message structural gate has held
cleanly on every prompt where it was used.
Root cause: A single message with multiple instructions ("diagnose
then stop") gives the agent latitude to interpret the boundary. A
structural break — Phase 1 message → wait for human → Phase 2
message — removes the interpretation surface. The sentinel sentence
makes the boundary checkable; Phase 1 isn't "complete" until that
literal sentence appears.
What we did: Adopted two-phase prompts for every non-trivial Claude
Code task in Phases 2 and 3. Documented the pattern in CLAUDE.md P10
("Two-phase Claude Code prompt pattern").
What would have prevented it: HQ "Claude Code Prompt Pattern"
standard already exists (H14: single architectural concern; BUG
REPORT format for bugs). Add the two-phase pattern as a sub-rule
under H14: for any task touching >1 file or requiring diagnosis,
the prompt must end Phase 1 with a sentinel sentence and wait for
approval before Phase 2. Document the exact sentinel ("Phase 1
complete. Awaiting approval to proceed to Phase 2.") so the gate
is uniformly checkable.
Playbook-worthy: yes
Tags: claude-code, prompt-pattern, two-phase, sentinel-sentence, agent-discipline

---

ID: vibespin-LL-026
Title: Capacitor 8 uses Swift Package Manager, not CocoaPods — every iOS plugin compat check must lead with that
Type: integration-gap
Area: native-ios / capacitor
Severity: medium
Phase encountered: Phase 2 (initial iOS setup); recurred when assessing `cordova-plugin-purchase` for v1.2.0 StoreKit
What happened: Capacitor 8 dropped CocoaPods support in favor of
Swift Package Manager (SPM). The iOS project opens via `App.xcodeproj`
(not `App.xcworkspace`) and dependencies are declared in
`Package.swift` (not `Podfile`). Most Capacitor iOS tutorials,
plugin READMEs, and Stack Overflow answers from before 2025 reference
the CocoaPods workflow — they say "open .xcworkspace," "run
`pod install`," "add to Podfile." Following those instructions on
Capacitor 8 either fails outright or wastes time tracing why a
non-existent file should exist. `cordova-plugin-purchase` specifically
flagged "not compatable with SPM" during `npx cap sync ios`; this
becomes a real architectural decision for v1.2.0 StoreKit IAP.
Root cause: Capacitor 8 is recent (late-2024 / 2025); the public
documentation ecosystem hasn't caught up. Default web-search results
are stale.
What we did: Verified SPM model by direct inspection of the
scaffolded project structure (Package.swift, CapApp-SPM/ directory,
no Podfile). Documented in CLAUDE.md P3 and P10 ("Critical gotchas —
iOS"). Logged `cordova-plugin-purchase` SPM-incompat as an open
Phase 4 architectural question — may need native StoreKit Swift
bridge.
What would have prevented it: HQ "Capacitor 8 Reference Card" doc:
short reference noting (a) SPM not CocoaPods, (b) .xcodeproj not
.xcworkspace, (c) Package.swift for deps, (d) plugin compat must
be checked against SPM specifically — Cordova plugins and old
Capacitor plugins may not have SPM packages. Update this card
whenever Capacitor releases a major version.
Playbook-worthy: yes
Tags: capacitor-8, spm, cocoapods, plugin-compatibility, stale-docs

---

ID: vibespin-LL-027
Title: iOS Info.plist purpose strings must cover ALL APIs linked by plugins, not just APIs the app's code uses
Type: policy-rejection
Area: native-ios / app-store
Severity: high
Phase encountered: Phase 2 — Build 1 rejected at upload (ITMS-90683)
What happened: First iOS upload (v1.0.5 Build 1) on 2026-05-15 was
rejected by Apple's static analyzer with ITMS-90683: "Missing
purpose string in Info.plist. Apps that collect data or use APIs
need a usage description for `NSPhotoLibraryUsageDescription`." The
app's user-facing code does NOT use the photo library — it only
opens the camera or accepts a file upload. But `@capacitor/camera`
links the PhotosUI framework even when only the camera API is
called. Apple's static analyzer flags any linked framework symbol
requiring a purpose string, regardless of whether the app's own
code paths reach that API.
Root cause: Apple's static analyzer operates on linked framework
symbols, not on call-graph reachability. Capacitor plugins link
multiple frameworks (PhotosUI, AVFoundation, etc.) to cover the
plugin's full API surface, even when the app uses only one
sub-API. Purpose strings must match what the plugin links, not
what the app uses.
What we did: Added `NSPhotoLibraryUsageDescription` (and
`NSPhotoLibraryAddUsageDescription` for symmetry) to Info.plist,
bumped Build number to 2, re-archived, re-uploaded. Build 2
accepted. Documented in CLAUDE.md P3 ("iOS: every Info.plist
purpose string covers ALL APIs linked by plugins").
What would have prevented it: HQ "iOS Plugin Audit" pre-archive
checklist: for each Capacitor plugin in `package.json`, list the
frameworks it links (from the plugin's `package.swift` or docs),
and require a corresponding `*UsageDescription` in Info.plist for
every privacy-sensitive framework. The list should be in the
plugin's README; if it isn't, treat that as a documentation gap
and verify by inspection. Run this audit BEFORE first archive,
not after Apple flags it.
Playbook-worthy: yes
Tags: ios-info-plist, purpose-strings, itms-90683, capacitor-plugins, static-analyzer

---

ID: vibespin-LL-028
Title: Xcode "Manage Version and Build Number" auto-increment writes to archive bundle only, not source files
Type: integration-gap
Area: native-ios / release-discipline
Severity: medium
Phase encountered: Phase 2 — third iOS upload (operator nearly enabled the auto-manage option)
What happened: Xcode's Distribute App dialog offers a checkbox
labeled "Manage Version and Build Number" that promises to
auto-increment build numbers between uploads. Looks attractive given
how often the operator has to manually edit `CURRENT_PROJECT_VERSION`
in `project.pbxproj`. Investigation revealed: the auto-management
writes the incremented number into the IPA bundle being uploaded
to Apple, but it does NOT write back to `project.pbxproj` in the
repo. Result: repo source thinks Build is N, Apple sees Build N+1,
next archive starts from N again, conflict on upload. Worse, the
repo's source-of-truth claim is broken — `git log -p project.pbxproj`
no longer reflects what shipped.
Root cause: Xcode's auto-management was designed for the workflow
where Xcode IS the source of truth (no external repo discipline,
no CI). On a repo-discipline workflow, it silently desynchronizes
source from artifact.
What we did: Caught BEFORE enabling. Documented in CLAUDE.md P3 and
P10: "Manage Version and Build Number: leave UNCHECKED." Build
numbers are bumped manually in `project.pbxproj` (both Debug AND
Release configs — see LL-029).
What would have prevented it: HQ "iOS Release Discipline" standard
gets a one-line rule: never enable Xcode's auto-management of Version
or Build number. Bump manually in `project.pbxproj` before archive.
The pre-archive checklist already includes this; HQ standard makes
it permanent across products.
Playbook-worthy: yes
Tags: xcode, version-bump, build-number, auto-management, source-of-truth, ios-release-discipline

---

ID: vibespin-LL-029
Title: iOS `CURRENT_PROJECT_VERSION` must be symmetric across Debug AND Release configs in `project.pbxproj`
Type: integration-gap
Area: native-ios / release-discipline
Severity: medium
Phase encountered: Phase 2 — second iOS archive
What happened: Bumped `CURRENT_PROJECT_VERSION` from 1 to 2 in
`project.pbxproj` before second archive — but only in the Release
config. Debug config still showed 1. The build succeeded and
uploaded fine (archive uses Release config), but later when running
on a simulator for debugging, the Debug build showed version 1
which created confusion about whether the debug session was on the
right version. Found by chance when checking on-device version
string.
Root cause: Xcode shows a single "Build" field in the General tab
that maps to the active scheme's config. Editing it through the
GUI updates only the visible config. Project files have separate
Debug and Release sections in `XCBuildConfiguration` entries, and
both must be kept in sync manually for source-of-truth integrity.
What we did: Bumped Debug to match Release. Standardized: every
Build number bump touches BOTH configs symmetrically. Documented
in CLAUDE.md P3 and P10.
What would have prevented it: HQ "iOS Release Discipline" pre-archive
checklist: verify `CURRENT_PROJECT_VERSION` is symmetric across Debug
and Release configs in `project.pbxproj`. A grep for the key in
pbxproj should return two identical values. If they differ, fix
before archive. Same rule for `MARKETING_VERSION` when version is
bumped.
Playbook-worthy: yes
Tags: ios-pbxproj, debug-release-symmetry, build-number, marketing-version, source-of-truth

---

ID: vibespin-LL-030
Title: Network-tab verification on real device catches CDN data leaks that grep + static analysis miss
Type: process-gap
Area: ci-cd / privacy
Severity: high (caught a privacy claim that would have shipped false)
Phase encountered: Phase 3 close — App Privacy questionnaire prep on 2026-05-19
What happened: While preparing the App Store Connect App Privacy
questionnaire, operator did a Safari Web Inspector Network-tab walk
on the iPhone-installed TestFlight build. Surfaced TWO active CDN
data leaks that previous grep / `cap sync` / Console-tab / visual
inspection had not caught: (a) Google Fonts (Orbitron + Rajdhani)
loading from `fonts.googleapis.com` and `fonts.gstatic.com` via
`@import` in `vibe.css`; (b) Unsplash images for all four skin
backgrounds loading from `images.unsplash.com`. Both were documented
in CLAUDE.md as third-party services, but their *implications* for
the privacy nutrition label ("Data Not Collected") were not in view
until the Network tab actually showed the requests. Without this
catch, the privacy questionnaire would have been answered as
"Data Not Collected" while the binary made real third-party HTTP
requests on every launch.
Root cause: Static-analysis checks (grep, lint, build success)
cannot catch runtime network requests. Console-tab inspection
doesn't surface successful requests; only failures show up there.
Cached requests don't appear on second launch unless the cache is
cleared first. The only reliable check is Network tab with cleared
cache on a fresh launch, listing every domain hit.
What we did: Two separate Claude Code sessions over 2026-05-19 to
bundle Orbitron + Rajdhani fonts locally (commit `520bfbe`, merged
`f785bf5`) and bundle the four Unsplash skin JPEGs locally (commit
`223feb4`, merged `71b6665`). Re-verified Network tab on rebuilt
binary — zero external domain requests on launch. Rewrote
`vibespinner/privacy.html` to reflect new reality.
What would have prevented it: HQ H12 ("real samples, real devices,
real artifacts") gains a specific sub-rule: privacy claims require a
Network-tab walk on real device with cleared cache, listing every
domain. Zero external domains = clean privacy claim. Any external
domain = either disclose accurately in the nutrition label or
remove the dependency before claiming "Data Not Collected." Run
the check before EVERY App Store / Play Store submission against
the actual submission binary, not source on `main`. (Combine with
LL-031 — submission-time binary verification.)
Playbook-worthy: yes
Tags: privacy-nutrition-label, network-tab, cdn-leak, runtime-vs-static-checks, real-device-verification

---

ID: vibespin-LL-031
Title: App Store Privacy Nutrition Label answers apply to the submitted binary, not source on main
Type: process-gap
Area: native-ios / app-store
Severity: medium (avoided by stockpile-then-submit discipline)
Phase encountered: Phase 3 close — considered answering App Privacy questionnaire while TestFlight Build 3 (stale) was the only live binary
What happened: Operator was preparing to answer App Store Connect's
App Privacy questionnaire ("Data Not Collected") on 2026-05-19,
*after* the font + Unsplash CDN removals had been merged to main
but *before* a new build (Build 4) carrying those removals had been
uploaded. The current TestFlight Build 3 still contained the CDN
links. Realized: the privacy questionnaire's answers apply to the
binary submitted for App Store review, not source on main. If
Build 3 were selected at submission time, the privacy claim would
be false for that binary even though it was true for main.
Operator's "do all admin work before any submission" discipline
neutralized the risk by ensuring no submission would happen until
Build 4 was uploaded and verified.
Root cause: App Store Connect's privacy questionnaire UI is
decoupled from binary selection — operator answers it independent
of which Build is selected for review. But at submission time, the
two are tightly coupled: the binary Apple reviews IS the binary
the questionnaire applies to. Easy to answer the questionnaire
honestly against a future binary (the "intent") while the actual
binary in flight contradicts it.
What we did: Caught BEFORE submission. Logged the rule: every App
Store / Play Store submission verifies that the build selected on
the submission page matches the privacy nutrition label answers.
Specifically — the build's commit SHA must be ≥ the SHA at which
the privacy answers were last verified accurate. Build 3 fails;
Build 4 passes.
What would have prevented it: HQ "Pre-submission Gate" checklist
item: at submission time, write down the SHA of the binary being
submitted, then verify the privacy questionnaire answers were
documented as accurate at or after that SHA. If not, EITHER
re-verify accuracy on the actual binary (Network-tab walk per
LL-030) OR don't submit. The questionnaire and the build are
inseparable at submission.
Playbook-worthy: yes
Tags: app-store-submission, privacy-nutrition-label, binary-vs-source, build-selection, pre-submission-gate

---

ID: vibespin-LL-032
Title: Storefront-truth violations propagate across multiple surfaces; a single fix in one surface leaves others stale
Type: process-gap
Area: play-store / app-store / website / docs
Severity: medium
Phase encountered: Phase 3 close — "priority support" surfaced in three places
What happened: "Priority support" as an unbuilt MAX feature claim
surfaced in *three* places during Phase 3 audit: (a) App Store
description, (b) in-app MAX paywall modal in `index.html`,
(c) CLAUDE.md P3 (Per-product hard rules). Same pattern as the
v1.0.0 → v1.0.1 fix of "Speed Run Challenge" and "Global Leaderboard"
(captured earlier as `vibespin-LL-006`). This session also caught
"Game Mode access (placeholder UI — full feature planned)" in MAX
tier of Vibe Spinner's website Terms §5 — fourth surface for the
same kind of violation. Each fix in one surface leaves the others
stale until grep finds them.
Root cause: Tier feature lists are duplicated across multiple
surfaces (store metadata, in-app modal, website Terms, internal
docs). There is no single source of truth. A single fix updates
one surface; nothing systematically catches the others.
What we did: Removed "priority support" from App Store description
and CLAUDE.md P3 in this session. In-app modal copy update queued
for Phase 4 (foldable into VS-017 revert session). Website Terms
"Game Mode" claim fixed in this session's website-repo handoff
work. Logged the cross-surface pattern explicitly.
What would have prevented it: HQ "Storefront Truth" standard (H18)
already names the principle but doesn't enforce cross-surface
consistency. Add: tier features must live in a single source of
truth (per-product canonical document — e.g.
`rore-tech-hq/org/PRODUCTS.md` keyed by product, with tier feature
arrays). Store metadata, in-app modals, website Terms, and CLAUDE.md
all reference (or are templated from) that source. A grep-pattern
audit in `.audit/` (H10) verifies no stale tier promises exist in
any product surface. Per the H18 + H10 + H9 cross-pattern.
Playbook-worthy: yes
Tags: h18, storefront-truth, single-source-of-truth, tier-list, cross-surface-drift

---

ID: vibespin-LL-033
Title: Apple W-9 tax form does not handle single-member LLC disregarded entities cleanly
Type: integration-gap (Apple)
Area: app-store / tax
Severity: medium (blocking but not a bug; awaiting Apple resolution)
Phase encountered: Phase 3 close — Paid Apps Agreement completion on 2026-05-19
What happened: RORE Tech LLC is enrolled in Apple Developer as an
Organization (D-U-N-S verified, Team L7X86Y896W). Completing the
Paid Apps Agreement requires filling out a W-9 in App Store Connect.
The W-9 form locks "Legal Name" (Line 1) to "RORE Tech LLC" (the
Organization name) and offers four tax-classification sub-options
for the LLC: Individual/sole-proprietor, LLC-C-Corp, LLC-S-Corp,
LLC-Partnership. None match RORE Tech LLC's actual federal tax
classification: single-member LLC, disregarded entity (taxed as
sole-prop for federal purposes), with its own EIN. Operator sent
Apple Support ticket requesting tax-team escalation. Resolution
pending (1-3 business days expected). Blocks Paid Apps Agreement
finalization, which blocks IAP product creation in App Store
Connect.
Root cause: Apple's W-9 implementation appears to model LLCs as
either (a) taxed as Individuals (no separate EIN, sole-prop
treatment) OR (b) taxed as a separate tax entity (C-Corp, S-Corp,
Partnership — with own EIN). Disregarded-entity treatment WITH its
own EIN — a common single-member LLC configuration — sits in the
gap. The form's classification options don't represent it
correctly.
What we did: Sent Apple Support ticket. Operator continued with all
non-blocking App Store Connect work (description, screenshots, age
rating, privacy questionnaire) so that resolution day is also
submission-eligible day. Logged as a Phase 4 async blocker.
What would have prevented it: HQ "Per-platform tax form" matrix
(H13 sub-rule): for each platform that requires a tax form (Apple,
Google, Stripe, Gumroad, etc.), document at enrollment time which
tax classifications the form supports and whether the operator's
classification fits cleanly. If it doesn't, expect a support
escalation. Document the resolution path once known so the next
operator (or the next platform) doesn't hit it cold. Same check
needed at Stripe, Gumroad, Google Pay enrollment.
Playbook-worthy: yes (resolution still pending; full lesson can be
finalized once Apple's tax team replies)
Tags: apple-developer, w-9, llc-disregarded-entity, tax-classification, single-member-llc, paid-apps-agreement

---

ID: vibespin-LL-034
Title: Multi-product website legal pages share a template — they share the template's errors too
Type: process-gap
Area: website / legal / multi-product
Severity: high (Delaware governing law was a real factual error across three products)
Phase encountered: Phase 3 close — Roundtable review of Vibe Spinner website Terms on 2026-05-19
What happened: Reviewing Vibe Spinner's website Terms surfaced a
Delaware governing-law claim. Delaware is incorrect — RORE Tech LLC
is Massachusetts-domiciled (4 Canton St, Sharon, MA 02067). Asked
operator to upload Edge Journal and Security SPY Terms; same
template, same Delaware error in both `journal/terms.html` and
`security-spy/terms.html`. Also: same "RORE Tech" shorthand
(missing "LLC") and same registered-address omission in all three.
Three products had the same factual error from copying the same
template. The Vibe Spinner-specific Roundtable caught the error
because Vibe Spinner was the first product to face submission
scrutiny; if Vibe Spinner hadn't been first, the error could have
persisted indefinitely.
Root cause: Template-once, copy-paste-many anti-pattern for legal
text. Each product project has its own legal pages, all derived
from the same template, but with no mechanism to propagate a fix
in the template to all instances. The template was wrong;
propagation was perfect; correction has to happen N times.
What we did: Fixed Vibe Spinner pages with full Roundtable review
(substantive + mechanical). Fixed Edge Journal and Security SPY
Terms with strict mechanical-only changes (entity + MA +
address + governing law + dates) from inside Vibe Spinner project,
because substantive review of those products belongs in their own
projects with calibrated Roundtable chairs. Privacy pages for
journal and security-spy still pending mechanical fix (Phase 4 P3
item; Security SPY is BIPA-critical).
What would have prevented it: HQ H9 (single source of truth for
canonical strings) — entity name, governing law jurisdiction,
registered address, formation state are canonical facts that
should live in `rore-tech-hq/org/LEGAL_ENTITY.md` and be referenced
(or build-time substituted) by every product's legal pages.
`.audit/deprecated-strings.txt` patterns should include "State of
Delaware" with comment "incorrect — RORE Tech LLC is MA-domiciled."
Cross-product audit pass at HQ should re-grep every product's legal
HTML against the canonical entity facts. This is exactly the kind
of cross-cutting drift H9 + H10 are built to catch.
Playbook-worthy: yes
Tags: legal-templates, copy-paste-anti-pattern, single-source-of-truth, entity-name, governing-law, multi-product-drift, h9, h10

---

ID: vibespin-LL-035
Title: macOS Finder auto-renames create phantom duplicates in working tree
Type: process-gap (minor)
Area: ci-cd / git
Severity: low (caught quickly; potential for confusion)
Phase encountered: Phase 3 — `git status` review during 2026-05-19 docs sweep
What happened: `git status` showed approximately eight untracked
or phantom files with " 2.md" / " 2.xml" / " 3.xml" suffixes
(e.g. `CHANGELOG 2.md`, `config 2.xml`). Investigation revealed
mixed causes: (a) some files had been deleted between sessions,
leaving stale entries; (b) macOS Finder auto-renames duplicates
created via drag-drop (Finder appends " 2" / " 3" to disambiguate),
which left accidental duplicates in resource directories
(particularly `android/app/src/main/res/xml/`). `rm` returned
"No such file or directory" for several, confirming they were
phantom. Real duplicates required manual cleanup. All resolved
without damage but ate ~15 minutes of confusion.
Root cause: macOS Finder is not git-aware. Drag-drop operations
that happen to land on an existing filename get auto-renamed by
Finder (silent disambiguation), creating duplicate files alongside
originals. Easy to do accidentally when reorganizing assets or
copying example files into a project. Without periodic `git status`
discipline, the duplicates accumulate until someone notices.
What we did: Cleaned up the phantom + real duplicates manually.
Documented the pattern. No code damage; just confusion.
What would have prevented it: HQ "Git Hygiene" checklist — periodic
`git status` discipline (at the start and end of every session, and
after any Finder drag-drop operation in the repo). A pre-commit
hook could grep for filename patterns matching `* 2.*`, `* 3.*`,
`* copy.*` and warn. Lightweight addition to `.audit/` category;
zero-cost ongoing once written.
Playbook-worthy: yes (lightweight)
Tags: macos-finder, git-hygiene, accidental-duplicates, working-tree-discipline, .audit-pattern

---

## Notes for HQ when filing

1. **Lesson IDs are sequential against the existing Vibe Spinner
   inventory.** LL-021 was the last entry in the `vibespin-native`
   `lessons-inventory.md` v0.1; these continue from LL-022. HQ's
   `eos/lessons/INVENTORY.md` may use a different namespace scheme
   (e.g. `vibespin-LL-022` vs cross-product `LL-022`); align as
   appropriate during filing.

2. **Cross-references to HQ STANDARDS that these lessons justify:**
   - LL-022, LL-023 → "Capacitor Platform-Modifying Operation"
     checklist (new) or H14 sub-rule
   - LL-024 → "Mac Signing Setup" pre-archive checklist (new) or H15
     extension
   - LL-025 → H14 two-phase prompt sub-rule
   - LL-026 → "Capacitor 8 Reference Card" doc (new)
   - LL-027 → "iOS Plugin Audit" pre-archive checklist (new) or H16
     extension
   - LL-028, LL-029 → "iOS Release Discipline" pre-archive
     checklist (new) or H15 extension
   - LL-030 → H12 sub-rule (privacy claims via Network tab)
   - LL-031 → "Pre-submission Gate" checklist or H18 extension
   - LL-032 → H18 + H10 + H9 cross-pattern (tier-list audit pattern)
   - LL-033 → H13 per-platform tax-form sub-rule
   - LL-034 → H9 + H10 cross-pattern (entity-facts audit)
   - LL-035 → "Git Hygiene" lightweight addition to `.audit/`

3. **Five themes carry forward from the original Vibe Spinner
   inventory (multi-target source hygiene, native-app submission
   gates, storefront-truth, regression and verification gaps,
   dependencies outside our control).** The new LL-022 → LL-035
   reinforce themes 2, 3, 4, and 5 specifically. No new theme yet
   — iOS submission gates and runtime privacy verification both fit
   under existing theme labels.

4. **One open lesson candidate is provisional.** LL-033 (Apple
   W-9 disregarded-entity) is logged here but its "What would have
   prevented it" line is incomplete pending Apple Support's tax-team
   reply. Re-file once Apple's resolution is known so the lesson
   includes the actual path forward.

---

*Drafted 2026-05-19 during Phase 4 docs sweep. Source material:
Phase 4 handoff §5 + §6; corroborating detail from CLAUDE.md
P3/P6/P10 and CHANGELOG.md v1.0.5 entry. Operator confirms before
filing to HQ.*
