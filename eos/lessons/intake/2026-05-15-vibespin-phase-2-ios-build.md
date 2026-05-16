# Vibe Spinner — Phase 2 close (iOS scaffold → TestFlight Build 2 LIVE)

1. Phase and product: Phase 2 (iOS build) — Vibe Spinner —
   2026-05-12 → 2026-05-15.

2. What went well: Apple Developer pre-flight as its own session
   (no scaffolding code, no Xcode open) caught xcode-select
   misconfig + Xcode license + Bundle ID registration at the
   right granularity, before they cascaded into ambiguous "where
   did this break."

3. What slipped: Build 1 (v1.0.5) was rejected (ITMS-90683) for
   missing NSPhotoLibraryUsageDescription — Capacitor Camera
   plugin links PhotosUI framework regardless of code paths, and
   Apple's static analyzer demanded the key. Plus macOS keychain
   GUI dialogs rejected the correct Mac password three separate
   times in one session (workaround: `security unlock-keychain`
   in terminal).

4. Process implication: Two HQ checklists may be needed:
   (a) "First-Platform Pre-Flight" as a generalized session
       pattern before any platform-specific scaffolding (iOS, but
       also Firebase, Stripe, Windows code-signing — pattern is
       generalizable).
   (b) `.audit/info-plist-keys.txt` with per-plugin Info.plist
       key requirements (when `@capacitor/camera` is in
       package.json, require Camera + PhotoLibrary + PhotoLibraryAdd
       usage descriptions).
   Plus add "Mac keychain quirks → unlock via terminal first"
   to dev-env-bootstrap.

5. One-line ask of HQ: at monthly review, decide whether
   First-Platform Pre-Flight goes into HQ STANDARDS as a
   cross-cutting pattern (CC-13 candidate) vs. a single
   iOS-specific checklist; create .audit/info-plist-keys.txt
   template regardless. Backed by lessons LL-022 and LL-028 in
   the inventory addition.

Note on filing: this intake should have shipped at the
2026-05-15 phase close and didn't; filed 2026-05-16. The
one-day deferral is a small signal of H8 discipline drift —
intakes that don't reach HQ are functionally the same as no
intake (Manual Section 5).
