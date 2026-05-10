# Domain Registry — Service Worker Scopes per Shared Domain

> **What this is.** The canonical record of which products own
> which path / SW scope / cache namespace on every RORE Tech
> shared domain. Consulted before any new PWA registers a
> service worker. Prevents a SW with too-wide scope from
> hijacking sibling products on the same domain.
>
> **Authority.** Updated whenever a new path, PWA, or cached
> surface is added under a shared domain. The Operator owns
> updates; AI collaborators consult before SW changes.
>
> **Lesson trace.** HQ STANDARDS H17 / CC-10. Derived from
> `vibespin-LL-003`, `vibespin-LL-014`, `vibespin-LL-016`,
> `roretech-website-LL-007`. The catastrophic incident that
> motivated this registry: a Vibe Spinner SW registered at
> scope `/` cached the spinner's `index.html` and served it for
> every request to `roretech.com`, making it look like the
> homepage had been overwritten.

---

## Domain: roretech.com

### Path-level ownership

| Path | Owner | Type | SW scope (if any) | Cache namespace (if any) | Notes |
|---|---|---|---|---|---|
| `/` | roretech-website | Static marketing site | **None** — root has no SW, by design | n/a | Adding a SW at root would hijack all sibling products. Not permitted. |
| `/security-spy/` | roretech-website (per-product page) | Static page | None | n/a | Per-product info page. Static. |
| `/journal/` | roretech-website (per-product page) | Static page | None | n/a | Per-product info page. Static. |
| `/vibespinner/` | roretech-website (per-product page) | Static page | None | n/a | Per-product info page. Static. Distinct from `/games/vibespinner/`. |
| `/games/vibespinner/` | **Vibe Spinner web PWA** | Live PWA | `/games/vibespinner/` (explicit) | `vibespin-vN` (versioned, bumped per deploy) | Fragile surface. Pre-push hook on the website repo prevents accidental commits to this path without an explicit `[allow-pwa]` token. |
| `/privacy.html` | roretech-website | Static page | None | n/a | Canonical privacy policy. Per-product policies redirect or copy from this. |
| `/terms.html` | roretech-website | Static page | None | n/a | Canonical terms. |
| `/privacy/` (per-product subdirectories) | roretech-website | Static pages or 301 redirects | None | n/a | Either redirect to `/privacy.html` or copy with caveats. Per `roretech-website-LL-001`. |
| `/.well-known/` | reserved | Special | None | n/a | Used for `assetlinks.json` (Android App Links), other web standards. Never houses application content. |
| `/unregister-sw.html` | roretech-website | Static recovery page | None | n/a | Recovery page that any sibling product can link to if a SW misbehaves. Calls `navigator.serviceWorker.getRegistrations()` and unregisters every match. |

### Rules for new paths under roretech.com

1. **Default: no SW.** New product pages do not register service
   workers unless there's a specific reason (offline
   functionality, push notifications, install-to-home-screen
   experience).

2. **If a new path needs a SW: register with explicit scope
   matching the path exactly.** No registering at `/` from a
   subfolder. No omitting the `scope:` parameter.

3. **Update this registry before deploying the SW.** The act of
   adding a row here is the gate. If the registry doesn't
   reflect the new SW, the deploy isn't ready.

4. **Versioned cache name required.** Format: `<product>-vN`,
   bumped on every deploy that changes a cached file.

5. **Recovery page accessible.** New PWAs document their
   recovery URL in this registry so sibling products know where
   to send users if a SW misbehaves.

---

## Domain: [future product subdomain pattern]

> When products graduate to dedicated subdomains (e.g.,
> `journal.roretech.com`, `vibefire.roretech.com`, or
> independent domains), they get their own row here.

| Subdomain | Owner | Notes |
|---|---|---|
| (none currently) | — | Vibe Spinner is the most likely candidate to graduate to its own subdomain or independent deploy unit, per the long-term plan in `DEPLOYMENT_CHECKLISTS.md` Section B.3. |

---

## Cache name allocations (cross-product)

To prevent collisions, every product that uses Cache Storage API
on a shared domain reserves its prefix here.

| Cache name prefix | Owner | Format |
|---|---|---|
| `vibespin-` | Vibe Spinner web PWA | `vibespin-vN` (e.g., `vibespin-v1`, `vibespin-v2`) |

New entries: when a product adds Cache Storage usage, add the
prefix here before deploy.

---

## localStorage namespace allocations (cross-product)

For browser tools using localStorage on shared paths, reserve
the namespace here.

| localStorage key prefix | Owner | Notes |
|---|---|---|
| `vibespin_` | Vibe Spinner web PWA | High score, settings, etc. |
| `tradeedge_` | Trade Edge AI (localhost only) | Watchlist, preferences |
| `tradeedge_v3` | Edge Journal (file:// only) | Trade journal raw data |
| `tradeedge_active_account` | Edge Journal | Active account filter |
| `tradeedge_ai_consent` | Edge Journal | AI Review consent flag |

> Note: file:// origin localStorage is per-file-path. Two HTML
> files at distinct paths have distinct localStorage. Edge
> Journal exploits this for Fidelity/Robinhood tab isolation
> per `tradeedge-LL-009`.

---

## What this registry catches

- **SW scope collisions on multi-product domains.** Caught by
  the rule that every SW registers with explicit scope and the
  registry tracks scope per product.
- **Cache name collisions.** Caught by reserving prefixes here.
- **localStorage namespace collisions** between products on the
  same origin.
- **Forgotten cache version bumps.** The registry's "format"
  column documents the versioning pattern; deploys that don't
  bump are caught either by a deploy script step or by the
  pre-deploy diff check.

---

## What this registry does NOT cover

- **Cross-domain concerns.** This registry is per-domain. If RORE
  Tech ever runs on multiple shared domains, each gets its own
  section.
- **Server-side routing.** Static-site routing (Netlify
  `_redirects`) is handled in the website repo's
  `netlify.toml`, not here.
- **External CDN content.** Unsplash, Google Fonts, etc. aren't
  RORE Tech-owned and aren't tracked here.

---

*Canonical domain registry. Maintained in
`rore-tech-hq/org/DOMAIN_REGISTRY.md`. Last updated: 2026-05-10
(initial draft).*
