# Billing Matrix — Per-Product, Per-Platform, Per-Endpoint

> **What this is.** The canonical record of which billing surface
> owns what cost, for every product and every external service.
> Referenced when:
> - A product onboards a new external service (External Service
>   Kickoff matrix in any service-setup checklist).
> - A privacy page or terms page mentions a payment partner.
> - A monthly review checks unexpected costs against expected
>   sources.
>
> **Authority.** Updated when a new service is integrated, when
> a billing partner changes, or when a rate-limit/tier shift
> changes the cost picture. The Operator owns updates; AI
> collaborators reference the matrix but do not edit it.
>
> **Lesson trace.** HQ STANDARDS H13. Derived from
> `xagent-LL-001` (Anthropic API billing separate from Claude.ai
> Pro), `xagent-LL-002` (X API tier per-operation),
> `tradeedge-LL-001` (per-endpoint tier), `vibespin-LL-005`
> (Stripe vs Google Play Billing per platform),
> `roretech-website-LL-010` (per-product billing language drift).

---

## How to read this matrix

Three dimensions: **Product × Platform × Endpoint**.

- **Product** — which RORE Tech product or surface incurs the
  cost.
- **Platform** — where the product is distributed (matters
  because Android can't use Stripe for digital goods, etc.).
- **Endpoint or operation** — specific because tiers are per-
  endpoint, not per-key.

For each row: which dashboard owns the billing, what tier,
what's the expected monthly cost band, and what's the rate
limit/quota.

---

## Outbound revenue (money in)

> What we charge users. Mapped to platform requirements.

### Security SPY

| Platform | Mechanism | Provider | Notes |
|---|---|---|---|
| Android | Subscription (in-app) | **Google Play Billing** | Required by Google Play policy; no alternative for Android digital goods. SUB-003 disclosure language applies in privacy policy. |
| iOS (future) | Subscription (in-app) | StoreKit | Required by Apple App Store policy. |
| Web (future) | n/a (mobile-only currently) | — | — |

### RORE Edge Journal

| Platform | Mechanism | Provider | Notes |
|---|---|---|---|
| Direct download (macOS/Windows) | Pro / Lifetime tier purchases | **[TBD — operator decision]** | Placeholder Gumroad URL exists in CLAUDE.md but no provider integrated yet. Decision pending. Candidates: Gumroad, Stripe (direct), Paddle. Decide before promoting Pro/Lifetime tiers publicly. |
| App Store (future) | Subscription / one-time | StoreKit | When iOS ships. |

### Vibe Spinner

| Platform | Mechanism | Provider | Notes |
|---|---|---|---|
| Android | One-time / subscription (in-app, when paid tiers ship) | **Google Play Billing** | Required for Android. Currently free. |
| Web PWA | Subscription | **Stripe** (or Paddle) | Web is *not* subject to Google Play policy. Stripe is fine here. Code conditionalizes payment URL on `Capacitor.getPlatform()` to ensure Android never hits Stripe. |
| iOS (future) | Subscription (in-app) | StoreKit | When iOS ships. |

### VibeFire

| Platform | Mechanism | Provider | Notes |
|---|---|---|---|
| Android | [TBD] | [TBD] | Phase 1 is auth-only. Payment decision deferred to a later phase. |

---

## Inbound costs (money out)

> What we pay external services. Each row owns its own dashboard
> and its own credential.

### Anthropic Claude API

| Used by | Endpoints | Tier | Monthly cost band | Rate limit | Dashboard |
|---|---|---|---|---|---|
| **RORE Edge Journal** (AI Review feature) | `messages.create` (Sonnet) | Pay-per-token | $0–$50 (depends on user adoption of AI Review) | Per-account TPM limits | console.anthropic.com |
| **XAGENT** (research/draft/verify pipeline) | `messages.create` (Sonnet, with web_search tool) | Pay-per-token | $5–$20 (covers operator's daily posting cadence) | Per-account TPM limits | console.anthropic.com |
| **RORE Edge AI** (research dashboards) | `messages.create` (Sonnet) | Pay-per-token | $5–$15 | Per-account TPM limits | console.anthropic.com |

> **Important.** Anthropic API billing is separate from Claude.ai
> Pro subscription. Per `xagent-LL-001`. Pro covers chat product
> only; API access is a separate pay-per-token billing
> relationship. Verify a non-zero balance at console.anthropic.com
> before any integration code is written.

### X (Twitter) API

| Used by | Endpoints | Tier | Monthly cost band | Rate limit | Dashboard |
|---|---|---|---|---|---|
| **XAGENT** | POST `/2/tweets` (automated posting) | Free tier + $5 minimum credit purchase | $5/month minimum credit | 1,500 posts/month on free | developer.x.com |

> **Important.** Free tier alone does not allow automated
> posting. Per `xagent-LL-002`. The $5 minimum credit purchase on
> the free tier unlocks posting. Do not confuse with the $100/month
> Basic plan.

### Finnhub

| Used by | Endpoints | Tier | Monthly cost band | Rate limit | Dashboard |
|---|---|---|---|---|---|
| **RORE Edge AI** | `/news`, `/earnings`, `/quote` | Free tier | $0 | 60 calls/min | finnhub.io |
| RORE Edge AI | `/stock/candle` | **NOT IN FREE TIER** — fallback to Yahoo Finance HTTP API | n/a | n/a | n/a |

> **Important.** Per `tradeedge-LL-001`. Per-endpoint tier
> verification done. `/candles` is paid; `/news` and `/quote` are
> free. An API key working for one does not mean working for
> another.

### Yahoo Finance (HTTP, no SDK)

| Used by | Endpoints | Tier | Monthly cost band | Rate limit | Dashboard |
|---|---|---|---|---|---|
| **RORE Edge AI** | `query1.finance.yahoo.com/v8/finance/chart/...` | Public, unkeyed | $0 | Soft (rate-limit queue maintains 150ms gap) | n/a (public) |

> Per `tradeedge-LL-003`, prefer-direct-HTTP over SDK applied:
> `yahoo-finance2` package was abandoned for direct HTTP because
> the SDK had v2→v3 export shape changes that broke at runtime.

### Firebase / Google Cloud Platform

| Used by | Services | Tier | Monthly cost band | Rate limit | Dashboard |
|---|---|---|---|---|---|
| **VibeFire** (Phase 1+) | Authentication, Firestore (locked mode), Cloud Functions, Cloud Storage | **Blaze (pay-as-you-go)** | $0–$5 (Phase 1 expected; budget alert set at $25) | Per-service quotas | console.firebase.google.com |

> **Important.** Per VibeFire Phase 1 lessons. New Blaze projects
> require Storage Object Viewer IAM role on the compute service
> account (`{project-number}-compute@developer.gserviceaccount.com`)
> for Cloud Functions deploy to work. Artifact Registry cleanup
> policy: 30 days. Budget alert: $25/month.

### Google Play Billing

| Used by | Subscription/IAP product | Tier | Monthly fee | Rate limit | Dashboard |
|---|---|---|---|---|---|
| **Security SPY** | Subscription tier | n/a | Google takes 15-30% commission depending on revenue volume and subscription length | n/a | play.google.com/console |
| **Vibe Spinner** (when paid tiers ship) | One-time / subscription | n/a | Same commission structure | n/a | play.google.com/console |

### Apple Developer Program (future)

| Used by | Service | Annual cost | Notes |
|---|---|---|---|
| Security SPY (iOS), Vibe Spinner (iOS), Edge Journal (App Store distribution if pursued) | Apple Developer Program | $99/year | Required for App Store distribution, TestFlight, notarization on macOS. Applies once across all RORE Tech apps. |

### Windows EV Code-Signing Certificate (future)

| Used by | Service | Annual cost | Notes |
|---|---|---|---|
| Edge Journal (Windows .exe distribution) | Code-signing CA (e.g., DigiCert, Sectigo) | $200–$400/year | Required for Windows direct-download apps to bypass SmartScreen. Long lead time — order in Phase 0. |

### Hosting and infrastructure

| Used by | Provider | Tier | Monthly cost band | Dashboard |
|---|---|---|---|---|
| **roretech.com** | Netlify | Free / Starter | $0–$20 | netlify.com |
| **XAGENT backend** | Railway | Hobby / Pro | $5–$20 | railway.app |
| **RORE Edge AI** | localhost (no hosting cost) | n/a | $0 | n/a |
| **All product domains** | Namecheap | n/a | ~$15/year per domain | namecheap.com |

### Email

| Used by | Provider | Tier | Monthly cost band |
|---|---|---|---|
| All RORE Tech addresses (`support@`, `privacy@`, etc.) | Zoho Mail | Free tier (up to 5 users with custom domain) | $0 |

### Trademark and entity

| Used by | Cost | Frequency | Dashboard |
|---|---|---|---|
| Massachusetts LLC | Annual report fee | Annually on anniversary month | Massachusetts Secretary of State |
| RORE Tech trademark | USPTO maintenance declarations | Years 5-6, 9-10 after registration | uspto.gov |
| D-U-N-S | Free for self-service | One-time | dnb.com |

---

## Total expected monthly cost

| Tier | Cost band |
|---|---|
| **Bare minimum** (one product live, no AI features active) | ~$25/month |
| **Current state** (Security SPY live, XAGENT live, RORE Edge AI on localhost, Edge Journal Phase 1, Vibe Spinner closed test, VibeFire Phase 1) | ~$50–$75/month |
| **Expected post-launch of all four** | ~$100–$150/month |

These are operator-side costs. Inbound revenue from Security SPY
and (eventually) Edge Journal Pro should cover this.

---

## Update protocol

This file gets updated:

1. **Whenever a new external service is integrated.** New row
   added; the External Service Kickoff matrix in the relevant
   service-setup checklist references this row.

2. **Whenever a billing partner changes.** E.g., when Edge
   Journal's payment provider is decided, this file is the first
   thing updated.

3. **Whenever a rate-limit or tier shift changes the picture.**
   E.g., if Anthropic's pricing changes meaningfully.

4. **At every monthly review.** The operator scans actual costs
   against expected bands. Variances trigger investigation.

---

## What this file is NOT

- **Not the place for credentials.** All API keys, account
  passwords, and dashboard logins live in the password manager.
  This file names *which* dashboard owns the cost, not the
  credentials to access it.
- **Not a financial forecast.** Cost bands are observed
  estimates, not commitments. Real costs may vary; this file
  surfaces variance, doesn't prevent it.
- **Not the source for tax accounting.** Real tax accounting
  pulls from Mercury bank statements and provider invoices, not
  from this file. This file is a reference for "where does X
  cost come from."

---

*Canonical billing matrix. Maintained in
`rore-tech-hq/org/BILLING_MATRIX.md`. Last updated: 2026-05-14
(Trade Edge AI renamed to RORE Edge AI throughout; all billing
rows unchanged — stack and dashboards are identical, only the
display name changed). Note: lesson IDs of the form
`tradeedge-LL-NNN` refer to RORE Edge AI lessons captured before
the rename and are kept as-is for cross-reference stability.*
