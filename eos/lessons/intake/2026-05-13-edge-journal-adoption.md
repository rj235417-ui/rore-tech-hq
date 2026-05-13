# RORE Edge Journal — EOS v0.1 adoption

1. Phase and product: RORE Edge Journal — EOS v0.1 Tier 1
   adoption, 2026-05-13.

2. What went well: .proposed merge process caught a shipped-broken
   feature — AI tab calls localhost:3001 with no proxy in repo
   and no setup docs. Documented in Journal CLAUDE.md P3 and P8.
   This is the third instance of the sync forcing real audit of
   doc-vs-implementation (VibeFire native-vs-Flutter, Vibe Spinner
   native-vs-Capacitor, now Edge Journal AI tab).

3. What slipped: Doc-to-doc consistency was being verified
   without checking against actual code behavior. The audit
   pattern that surfaces this is "open CLAUDE.md's architecture
   section, then grep the repo for the named services and
   endpoints; if you can't find them, the doc is stale or the
   feature is broken."

4. Process implication: sync process needs explicit guidance
   for the .proposed merge phase — "audit any documented external
   integration against actual code, not just doc-to-doc
   consistency." Belongs in eos/sync/README.md as part of the
   .proposed merge instructions.

5. One-line ask of HQ: add doc-vs-code audit step to the
   .proposed merge guidance in sync/README.md.

Additional context (not part of the 5-line intake):

- Storefront drift surfaced: roretech.com claims 100% on-device
  for all products. Journal's AI tab and VibeFire's entire backend
  are cloud-touching. H18 violation. Logged as HQ open item; needs
  operator decision on marketing copy vs. per-product framing.

- Backup file bug: when CLAUDE.md is rewritten via Claude Code's
  Write tool during .proposed merge, the sync script's backup
  hook is bypassed. Originals safe in git, but the backup-file
  audit trail is inconsistent. Defer.
