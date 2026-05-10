# Deployment Checklists

> **Version:** 0.1
> **Owner:** RORE Tech HQ (`rore-tech-hq/eos/checklists/DEPLOYMENT_CHECKLISTS.md`)
> **What this is.** Four deployment-surface checklists bundled
> into one document with an index. The four sections share enough
> structure (deploy verification, configuration discipline, scope
> boundaries) that combining them reduces drift and makes the
> cross-references work as text instead of file links.
>
> **When to use which section.**
>
> | Product type | Section to walk |
> |---|---|
> | Node/Express/Railway/Vercel backend | Section A — Backend Service Hardening |
> | Static marketing site, multi-product domain | Section B — Web Deploy |
> | PWA on a shared domain | Section B + Section C — PWA Deployment |
> | Electron desktop app | Section D — Desktop Distribution |
>
> **Lesson trace.** DC-D (5 lessons), DC-E (9 lessons), DC-F (8
> lessons), CC-10 (4 lessons) from `eos/lessons/INVENTORY.md`.
> Specific lesson IDs cited per section.

---

## Index

- [Section A — Backend Service Hardening](#section-a--backend-service-hardening) (Node + Express + Railway/Vercel/etc.)
- [Section B — Web Deploy](#section-b--web-deploy) (Static sites, multi-product domains, Netlify/Vercel)
- [Section C — PWA Deployment](#section-c--pwa-deployment) (Service workers, scope, cache, recovery)
- [Section D — Desktop Distribution](#section-d--desktop-distribution) (Electron, code-signing, notarization)

---

## Section A — Backend Service Hardening

> **When to use.** Any product with a backend service
> (Node/Express, Railway, Vercel functions, etc.) that runs
> independently from a UI. XAGENT, Trade Edge, future Edge Journal
> sync, future VibeFire backend.
>
> **Lesson trace.** DC-E in `eos/lessons/INVENTORY.md`.
> `xagent-LL-005`, `LL-006`, `LL-013`, `LL-015`, `LL-016`, `LL-018`;
> `tradeedge-LL-002`, `LL-005`, `LL-006`, `LL-007`, `LL-018`. Plus
> CC-3, CC-7.

### A.1 Configuration

- [ ] **Every required environment variable has a startup
  validator** that fails loudly on missing/empty values.
  Format:
  ```
  REQUIRED_ENV: ANTHROPIC_API_KEY, X_API_KEY, X_API_SECRET, ...
  ```
  Fails the process on startup with a clear message naming the
  missing key. *(`xagent-LL-005`, CC-3.)*

- [ ] **`.env.example` exists in the repo** with every required
  key listed (with placeholder values). Setup instructions say
  `cp .env.example .env`, never `nano .env` from scratch. macOS
  Finder hides leading dots; nano doesn't enforce them; users
  end up with `env` instead of `.env`. *(`tradeedge-LL-005`.)*

- [ ] **`.env` is in `.gitignore`** and has been since the first
  commit. Verify `git ls-files | grep '\.env$'` returns nothing.

### A.2 Dependencies

- [ ] **Every direct dependency in `package.json` uses an exact
  version, never a caret.** `"express": "4.22.1"`, not
  `"express": "^4.22.1"`. Lockfile is the source of truth, but
  the manifest must reflect the same exact version.
  *(`tradeedge-LL-006`.)*

- [ ] **`npm audit` runs weekly during active dev**, plus on
  every dependency change. High-severity vulnerabilities in
  direct dependencies trigger a patch + re-pin.

- [ ] **Supply-chain incident response runbook applied** when a
  package compromise is reported: check installed version
  (`cat node_modules/<pkg>/package.json | grep version`), not
  declared version. Caret ranges resolve broadly; only installed
  is reliable. Check IoCs (file paths, processes) from the
  advisory. *(`tradeedge-LL-007`.)*

- [ ] **Prefer-direct-HTTP-over-SDK rule applied** for any
  third-party API the project already has an HTTP client for.
  Before adding a new SDK, write a 10-line spike against the
  raw HTTP endpoint. If that works, don't add the SDK. Wrappers
  for stable HTTP APIs are volunteer-maintained and version-
  churn faster than the underlying API. *(`tradeedge-LL-003`.)*

### A.3 Architecture — server primitives stay on the server

- [ ] **No browser-side schedulers, no browser-side cron, no
  browser-side retry queues.** Any timer that needs to survive
  tab close, laptop sleep, or browser crash lives on the
  server. *(`xagent-LL-015`.)*

- [ ] **Persistence layer is named in the Phase Protocol's
  Definition of Done**, even if the answer is "in-memory state
  is acceptable, lost on every redeploy is the chosen behavior."
  In-memory state in hosted services is a real choice; it gets
  documented rather than defaulted into. *(`xagent-LL-018`.)*

### A.4 Rate limits and external APIs

- [ ] **Every external API call that fans out across a list
  goes through a rate-limit-aware queue from day one**, even if
  today's list is small. The queue gets stress-tested by the
  list growing; building it after the queue blows up costs more
  than building it preemptively. *(`tradeedge-LL-002`.)*

- [ ] **Per-endpoint tier verification done.** Reference the
  External Service Kickoff matrix in this product's Phase
  Protocol. Per-endpoint tier ≠ per-key tier; an API key that
  works for `/news` may not work for `/candles`. Paste the line
  from the provider's pricing page that confirms the chosen
  tier covers the chosen endpoint. *(`tradeedge-LL-001`.)*

### A.5 Deploy verification

- [ ] **Every deployable service ships with a `/health`
  endpoint** that returns:
  ```
  {
    "deployed_git_sha": "abc123...",
    "deployed_at": "2026-05-10T14:30:00Z",
    "required_env_vars": {
      "ANTHROPIC_API_KEY": true,
      "X_API_KEY": true,
      ...
    }
  }
  ```
  Boolean per env var; `true` means present and non-empty.
  *(CC-7; `xagent-LL-005`, `LL-013`, `LL-016`.)*

- [ ] **Post-deploy ritual** — wait 60 seconds, hit `/health`,
  compare returned `deployed_git_sha` against `git rev-parse
  HEAD`. If they don't match, the deploy didn't land. Manually
  trigger redeploy. Treat auto-deploy as advisory.
  *(`xagent-LL-016`.)*

- [ ] **Hand-distributed clients (e.g., a local dashboard
  HTML)** include a version check on every load — fetch
  `/version` from the backend, compare against an embedded
  constant. Mismatch shows a banner: "Dashboard is older than
  backend; please reload from <url>." *(`xagent-LL-013`.)*

### A.6 Security posture

- [ ] **No-auth backends with mutating routes bind explicitly to
  `127.0.0.1` in code**, not via deployment config. Add a
  runtime warning if `0.0.0.0` is detected. The dangerous
  default must be impossible, not merely documented.
  *(`tradeedge-LL-018`.)*

- [ ] **Hardcoded credentials in code create an immediate
  rotation ticket** in the same commit. Workarounds are not
  "done" until the rotation is. *(`xagent-LL-006`.)*

---

## Section B — Web Deploy

> **When to use.** Any static-site or marketing-site deploy.
> Specifically applies to roretech.com and product-page deploys
> at any path under it. PWA-specific items move to Section C.
>
> **Lesson trace.** DC-F in `eos/lessons/INVENTORY.md`.
> `roretech-website-LL-002`, `LL-003`, `LL-004`, `LL-006`,
> `LL-011`, `LL-012`, `LL-017`. Plus CC-2 (audit), CC-1 (canonical
> strings).

### B.1 Asset and content wiring

- [ ] **Pre-commit audit (`asset-existence.sh`) ran clean.**
  Every `<img src>` or favicon path in committed HTML resolves
  to a tracked file in the repo. Catches the "PNG lives in
  Claude project workspace, not in GitHub" failure.
  *(`roretech-website-LL-003`.)*

- [ ] **Pre-commit audit (`link-consistency.sh`) ran clean.**
  No filenames with whitespace; internal links use consistent
  extension conventions (e.g., `/privacy.html` not `/privacy`
  if the site mixes them). Netlify's pretty-URL fallback masks
  inconsistency until a deploy without that setting 404s.
  *(`roretech-website-LL-002`, `LL-004`.)*

- [ ] **HTML validity check passed.** No nested `<a>` tags
  (cards that may contain secondary clickable elements are
  `<div>` with explicit `<a>` for primary CTA, never
  `<a>`-wrapped). *(`roretech-website-LL-006`.)*

### B.2 SVG and visual smoke test

- [ ] **Any SVG with curved text or filter effects has viewBox
  padded** by at least the filter's `stdDeviation × 4` plus
  `font-size × 1.2` on each side.

- [ ] **Cross-browser visual smoke test** for any non-trivial
  SVG/animation before merging. Safari + Chrome + mobile
  Safari. Filter behavior diverges across engines and "looks
  fine in Chrome" is not enough. *(`roretech-website-LL-011`.)*

### B.3 Multi-product domain hygiene

- [ ] **Live, fragile surfaces inside the same repo** (e.g.,
  `/games/vibespinner/` PWA) are protected by a pre-push hook
  that fails if any commit on `main` touches the path without
  an explicit `[allow-pwa]` token in the commit message. The
  CLAUDE.md "do not touch" rule is words; the hook is
  enforcement. *(`roretech-website-LL-007`.)*

- [ ] **Long-term plan to split fragile-but-co-located surfaces
  into their own deploy units** is named in an ADR (separate
  repo, separate Netlify site, proxied path). Convention
  doesn't scale; technical boundaries do.

### B.4 Deploy verification

- [ ] **Documented post-push sequence followed:**
  1. Wait 60 seconds for Netlify build.
  2. `curl` the canonical URL and grep for one known-changed
     string.
  3. `curl` each mirror URL similarly.
  4. Check HTTP 200 explicitly.
  5. If any of 2–4 fail: check Netlify dashboard for build
     error.

  Verification is documented in the repo (or HQ runbook), not
  reconstructed each release. *(`roretech-website-LL-017`.)*

- [ ] **Large media files are not committed to git history.**
  `.gitignore` covers `*.mp4`, `*.MP4`, `*.mov`, `*.MOV`,
  `*.zip`, `*.dmg` from day one — before the first commit. If
  large files are already in history, use `git filter-branch`
  to purge before next push. *(`roreedge-LL-012`.)*

### B.5 SEO triage

- [ ] **Search Console signals classified before action**:
  redirects (correct behavior), 404s from vulnerability
  scanners (correct behavior), pretty-URL variants (correct
  behavior, dismiss with `<link rel="canonical">`). Reference
  `eos/runbooks/SEO_TRIAGE.md` before treating any line as a
  bug. *(`roretech-website-LL-012`.)*

---

## Section C — PWA Deployment

> **When to use.** Any product hosted under a shared domain
> that registers a service worker. Apply *in addition to*
> Section B.
>
> **Lesson trace.** CC-10 in `eos/lessons/INVENTORY.md`.
> `vibespin-LL-003`, `LL-014`, `LL-016`; `roretech-website-LL-007`.

### C.1 Scope discipline

- [ ] **Service worker registers with explicit `scope:`
  parameter** equal to the product's subfolder. No exceptions.
  `navigator.serviceWorker.register('/games/vibespinner/sw.js',
  { scope: '/games/vibespinner/' })`. *(`vibespin-LL-003`,
  `LL-016`; H17.)*

- [ ] **Domain-level SW-scope registry**
  (`rore-tech-hq/org/DOMAIN_REGISTRY.md`) lists every product's
  SW scope on shared domains. New PWAs check the registry
  before registering — no two products may register at the
  same scope on the same domain.

### C.2 Cache versioning

- [ ] **Cache name includes a version**: `vibespin-v2`, not
  `vibespin`. *(`vibespin-LL-014`.)*

- [ ] **Every deploy that changes a cached file bumps the cache
  version.** Make it a step in the deploy script, not a
  remembering exercise.

- [ ] **Cached resources include `?v=<commit-sha>` query
  params** so a hard refresh always wins.

### C.3 Recovery

- [ ] **`unregister-sw.html` recovery page exists** at every
  PWA's path. If a SW misbehaves, users (or sibling products)
  can recover by visiting that URL. The recovery page calls
  `navigator.serviceWorker.getRegistrations()` and unregisters
  every match.

- [ ] **Recovery URL is linked** from any sibling product's
  documentation that might be affected.

### C.4 Capacitor-specific (when applicable)

- [ ] **`assets/public/` is never edited directly.** `cap sync`
  overwrites it. The source of truth is `www/`.
  *(`vibespin-LL-015`.)*

- [ ] **`.gitignore` excludes `assets/public/`** and a
  `.editorconfig` marks those paths read-only in supported
  editors.

- [ ] **`touch-action: none` is element-scoped**, never on `*`,
  `body`, or `html`. Global `touch-action: none` causes WebView
  to fire stray `touchmove` events during page load and system
  gestures. *(`vibespin-LL-001`.)*

---

## Section D — Desktop Distribution

> **When to use.** Any Electron, Tauri, or other desktop-app
> product. Currently RORE Edge Journal; future iOS/macOS
> ports of mobile products.
>
> **Lesson trace.** DC-D in `eos/lessons/INVENTORY.md`.
> `roreedge-LL-012`, `LL-013`, `LL-017`, `LL-018`, `LL-022`. Plus
> CC-8 (signing material).

### D.1 Phase 0 readiness

- [ ] **Apple Developer enrollment ordered before Phase 1.**
  Enrollment can take days to weeks depending on entity type.
  `$99/yr`. Required for notarization, which is required for
  Mac DMG distribution to bypass Gatekeeper. *(`roreedge-LL-017`.)*

- [ ] **Windows EV code-signing certificate ordered before
  Phase 1.** Vendors require business validation; takes time.
  `$200–$400/yr`. Required to bypass SmartScreen. Without
  signing, most non-technical users abandon at the security
  warning. *(`roreedge-LL-017`.)*

- [ ] **`.gitignore` covers `*.dmg`, `*.exe`, `*.zip`, `*.MP4`,
  `*.mov`, `node_modules`, `dist/`, `out/`, `build/` on day
  one** — before the first commit. *(`roreedge-LL-012`.)*

### D.2 Build configuration

- [ ] **`electron-builder.config.js` is set up for both Mac
  and Windows targets from day one**, even if only one is
  built initially. Adding cross-platform after the fact is
  harder than starting with the matrix.

- [ ] **GitHub Actions CI matrix planned for cross-platform
  builds.** `npm run build` on a Mac produces a Mac DMG; a
  Windows EXE requires a Windows runner (or signed cross-build
  setup). Native code-signing is OS-bound. *(`roreedge-LL-018`.)*

### D.3 Signing and notarization

- [ ] **Signing-key birth certificate ran** for the Mac
  distribution certificate and the Windows EV cert. See
  `eos/checklists/SIGNING_KEY_BIRTH_CERTIFICATE.md` Section A
  (irrecoverable material).

- [ ] **Mac notarization workflow documented** in a runbook.
  `notarytool` flow, stapling, the `xcrun altool` path if
  needed. The workflow happens once but survives months
  between uses; without a runbook it gets re-derived every
  time.

- [ ] **Windows signing workflow documented** similarly.
  `signtool.exe` flags, EV cert hardware-token handling.

### D.4 Distribution UX

- [ ] **The unsigned-download UX is explicitly considered if
  signing isn't ready yet.** A Mac DMG with "cannot be opened
  because Apple cannot check it for malicious software" loses
  most non-technical users at the warning. Either ship signed
  or don't ship to those users yet.

- [ ] **Auto-updater plan exists**, with the explicit note that
  bundle ID changes break the auto-updater. Once the bundle ID
  is published, it does not change. *(`roreedge-LL-020`.)*

### D.5 State and persistence

- [ ] **localStorage vs `electron-store` decision made
  explicitly**, captured in an ADR. Each is its own
  architectural concern; bundling the migration with packaging
  in one Claude Code session multiplies failure surface.
  *(`roreedge-LL-022`; H14.)*

- [ ] **Window-state persistence implementation chosen.**
  `electron-window-state` is a known unreliable package; manual
  JSON in app data path is often simpler. Either choice
  documented. *(`roreedge-LL-013`.)*

---

## Gate decision (per section walked)

At the end of each section walked, record one of:

- **PASSED** — all items PASS, N/A, or WAIVE with reason.
- **PASSED WITH WAIVERS** — same, with explicit waivers carrying
  named follow-up owners and target dates.
- **FAILED** — one or more items cannot be marked. The relevant
  surface is not ready to deploy.

Multiple sections may be walked for one product (e.g., a PWA
walks Section B and Section C). Each section gates its own
surface; a failure in one doesn't fail the others.

---

*Source-of-truth bundled checklist. Maintained in
`rore-tech-hq/eos/checklists/DEPLOYMENT_CHECKLISTS.md`. v0.1
absorbs DC-D, DC-E, DC-F, and CC-10 from the lessons inventory.
Will be split into separate files only if any one section grows
to the point that bundling is harder than splitting.*
