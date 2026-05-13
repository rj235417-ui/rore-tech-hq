# Products — Canonical Facts

> **What this is.** The single source of truth for RORE Tech
> product names, taglines, platforms, package/bundle IDs, and
> shareable identifiers. Every store listing, marketing page,
> and product reference pulls values from here.
>
> **Authority.** When product facts change (rename, new platform,
> new version, signing key rotation), this file updates first
> and the change flows via the standard cycle.
>
> **Lesson trace.** HQ STANDARDS H9. Derived from
> `roretech-website-LL-009` (Vibe Studios Spinner naming drift),
> `vibespin-LL-008` (app identity across config files),
> `roreedge-LL-020` (ROREtech Inc. vs RORE Tech).

---

## Active products

### Security SPY

| Field | Value |
|---|---|
| **Display name** | Security SPY |
| **Trade name (™ pending)** | Security SPY™ |
| **Forbidden variants** | "Security Spy", "SecuritySpy", "Security SPY - Silent Lens" (the "Silent Lens" suffix was removed for policy reasons; never restore as listing name — see `securityspy-LL-014`) |
| **One-line description** | Mobile security tool that silently captures unauthorized access attempts to flagged apps. |
| **Tagline** | "Your device. Your data. Your edge." (cross-product) |
| **Platforms** | Android (live) |
| **Package name (Android)** | `com.rore.securityspy` |
| **Distribution** | Google Play |
| **Surveillance-adjacent classification** | **Yes** — walks [SENS] sections in Play Store Submission checklist |
| **Payment provider** | Google Play Billing (subscriptions) |
| **Privacy posture** | On-device only. No cloud. No accounts required for core functionality. |
| **Status** | Live (v1.0.9 as of 2026-05-07) |

### RORE Edge Journal

| Field | Value |
|---|---|
| **Display name** | RORE Edge Journal |
| **Trade name** | RORE Edge Journal™ |
| **Forbidden variants** | "ROREtech Inc." (legal name is "RORE Tech LLC", not "ROREtech Inc.") |
| **One-line description** | Desktop trade journal for active traders with broker imports and AI-coached trade review. |
| **Tagline** | "Trade smarter. Stay secure." |
| **Platforms** | macOS, Windows (in development) |
| **Bundle ID (immutable post-launch)** | `com.roretech.rore-edge-journal` |
| **Distribution** | GitHub Releases (direct download); future: Apple notarization, Windows EV signing |
| **Surveillance-adjacent classification** | No |
| **Payment provider** | [TBD — placeholder Gumroad URL exists; see open items] |
| **Privacy posture** | 100% local data. AI Review feature transmits trade data per-session per-consent only. |
| **Status** | Phase 1 (build hardening) |

### Vibe Spinner

| Field | Value |
|---|---|
| **Display name** | Vibe Spinner |
| **Trade name (™ pending)** | Vibe Spinner™ |
| **Forbidden variants** | "Vibe Studios Spinner", "VibeSpin", "Vibe Spin" — none of these are valid; only "Vibe Spinner" |
| **One-line description** | High-RPM engine simulator game with physics-accurate audio synthesis. |
| **Tagline** | "Play harder." |
| **Platforms** | Android (in closed test) |
| **Package name (Android)** | `com.roretech.vibespin` |
| **Distribution** | Google Play (planned) |
| **Surveillance-adjacent classification** | No |
| **Payment provider — Android** | Google Play Billing (when paid tiers launch — currently free) |
| **Payment provider — Web PWA** | Stripe (web only; never on Android — see `vibespin-LL-005`) |
| **Privacy posture** | On-device only. No accounts. No cloud. |
| **Status** | Closed testing (v1.0.x) |

### VibeFire

| Field | Value |
|---|---|
| **Display name** | VibeFire |
| **One-line description** | [Operator to fill — product description] |
| **Tagline** | [Operator to fill] |
| **Platforms** | Android (Phase 1 — Flutter) |
| **Package name (Android)** | `app.vibefire.android` |
| **Firebase project ID** | `vibefire-dev-cdfd6` |
| **Distribution** | Google Play (planned) |
| **Surveillance-adjacent classification** | No |
| **Payment provider** | [TBD] |
| **Privacy posture** | [Operator to fill — Firebase backend changes the on-device-only posture; needs explicit articulation] |
| **Status** | Phase 1 (recovery in progress as of 2026-05-10) |

---

## Other RORE Tech surfaces

### XAGENT

| Field | Value |
|---|---|
| **Display name** | XAGENT |
| **Type** | Internal tool (autonomous X/Twitter posting agent) |
| **Distribution** | Not user-facing |
| **Stack** | Node.js + Express, Anthropic Claude API, X API, Railway hosting |
| **Status** | Live for operator's own X account; not a public product |

### RORE Edge AI

| Field | Value |
|---|---|
| **Display name** | RORE Edge AI |
| **Forbidden variants** | "Trade Edge AI" (deprecated 2026-05-14 — name renamed for brand consistency with RORE Edge Journal), "Catalyst Watch" (early working title; never used externally) |
| **Type** | Internal tool (operator's own trading research dashboard) |
| **Distribution** | localhost-only Node.js + browser dashboard |
| **Status** | Live for operator's use; not a public product |

> **Naming distinction.** RORE Edge AI is *operator-facing only* —
> a localhost dashboard for the operator's own research. RORE Edge
> Journal is the *trader-facing* desktop product that ships
> externally. Both touch the Claude API but serve different
> audiences and have different compliance frames. Do not conflate.

### roretech.com (the website)

| Field | Value |
|---|---|
| **Type** | Marketing site for RORE Tech LLC |
| **Hosting** | Netlify |
| **Stack** | Static HTML/CSS/JS |
| **Live PWA hosted under it** | `/games/vibespinner/` (Vibe Spinner web PWA — fragile, see `roretech-website-LL-007`) |

---

## Cross-product taglines

| Tagline | Use |
|---|---|
| "Your device. Your data. Your edge." | Cross-product (RORE Tech) |
| "Trade smarter. Stay secure. Play harder." | Cross-product sub-tagline |
| "Trade smarter." | Edge Journal (and RORE Edge AI internally) |
| "Stay secure." | Security SPY |
| "Play harder." | Vibe Spinner |

---

## Forbidden words and phrases (cross-product)

> Caught by `eos/audit/deprecated-strings.txt`. Never appear in
> any product's copy, store listing, or legal page.

- "ROREtech Inc." (entity is RORE Tech LLC, no Inc.)
- "Vibe Studios Spinner" (product is Vibe Spinner)
- "Delaware" (in the context of governing law — RORE Tech is
  Massachusetts)
- "Silent Lens" (in any Play Store listing-name field for
  Security SPY)
- "Trade Edge AI" (renamed to RORE Edge AI on 2026-05-14; old
  name retired entirely)
- "Catalyst Watch" (early working title for RORE Edge AI; never
  used externally)

---

## Privacy commitments — canonical

These appear verbatim across product privacy pages. Edits flow
from this file.

1. **No cloud storage of user data.** All product data lives on
   the user's device. Per-product exceptions (e.g., Edge
   Journal's AI Review feature, VibeFire's Firebase backend)
   are explicitly named and require dedicated consent surfaces.

2. **No accounts required for core functionality.** Where
   accounts are required (Edge Journal AI consent, VibeFire
   auth), the requirement is explicit and the alternative is
   working without that feature.

3. **No tracking, no advertising, no monetization of user data.**
   Per `RORE_TECH_ORG.md` Section 2.

4. **Honest pricing.** One-time purchases or transparent
   subscriptions. No dark patterns, no feature hostage-taking.

---

*Canonical product facts. Maintained in
`rore-tech-hq/org/PRODUCTS.md`. Last updated: 2026-05-14 (Trade
Edge AI renamed to RORE Edge AI; old name added to forbidden
variants).*
