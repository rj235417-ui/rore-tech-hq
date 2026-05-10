# RORE Tech — Organization Context

> **Purpose of this file.** This is the company-level context document for the
> *RORE Tech Org* Project — the meta-Project that serves as both an agent
> factory and the high-level HQ for running RORE Tech. It captures only what
> is true at the company level. Product-specific details live in each product
> Project's own CLAUDE.md.
>
> Update this file when the company changes — new entity facts, new tools,
> new products, new hard rules, new founder constraints. Re-upload to the
> Project knowledge base after every meaningful edit.

---

## 1. Legal Entity

- **Legal name:** RORE Tech LLC
- **Entity type:** Single-member LLC (founder is sole member)
- **State of formation:** Massachusetts, USA
- **Tax classification:** Disregarded entity by default — income passes through to founder's personal return (Schedule C on Form 1040). Founder may elect S-Corp taxation later if revenue justifies it.
- **EIN:** [stored separately — fill if needed for a specific task]
- **DUNS number:** Pending (application submitted)
- **Fiscal year end:** December 31 (US calendar year)
- **USPTO trademark:** RORE Tech application filed under International Class 9 (downloadable software, apps, security software) and International Class 42 (SaaS, software design and development services). Application pending; not yet registered.

### Governing law inconsistency to fix
The current Terms of Service and Privacy Policy across product sites reference **Delaware** as governing law. The actual LLC is registered in **Massachusetts**. This must be corrected in all legal pages across the three products before any meaningful enforcement situation arises. Treat as an open item — see Section 9.

---

## 2. Mission & Philosophy

**One-line tagline:** *Your device. Your data. Your edge.*

**Sub-tagline:** *Trade smarter. Stay secure. Play harder.*

**Core philosophy.** RORE Tech builds privacy-first software that runs on the user's own device. Data never leaves the device. No cloud servers. No accounts required to use core functionality. No tracking, no advertising, no monetization of user data. This is not a marketing position — it is the architectural commitment that constrains every product decision.

**What we believe.**
- The user's device is the right place for the user's data. Building otherwise is a choice, not a necessity.
- Independent software can be both polished and principled. The two are not in tension.
- Honest pricing — one-time purchases or transparent subscriptions — beats dark patterns and feature hostage-taking.
- Small, focused teams ship better software than large, distracted ones. We will stay that way deliberately.

**What we will not do.**
- Collect user data we do not need.
- Add cloud sync as a default. (If we ever offer it, it will be opt-in, end-to-end encrypted, and clearly disclosed.)
- Take VC money that pressures us to monetize users.
- Add advertising to any product.
- Ship features that betray the privacy posture, regardless of revenue upside.

---

## 3. Products at a Glance

> One paragraph each. Deep specs live in each product Project's CLAUDE.md.

**Security SPY** — Mobile security tool. Live on Google Play (Android). Silently captures a photograph from the front camera when an app or system screen the device owner has marked sensitive is opened, allowing the owner to identify unauthorized access. Owner-face recognition discards photos that match the registered owner. All photos stored in an on-device encrypted vault. Zero cloud. Sits in the highest-risk Play Store category (anti-theft / surveillance-adjacent) — store listing copy and feature additions require careful compliance review every time.

**RORE Edge Journal** — Desktop trade journal for active traders. macOS and Windows (Electron). Imports from eight US brokers, full analytics, AI-coached trade review using the Claude API. 100% local data. AI feature transmits trade data only when the user explicitly requests a review and consents per session. Sits adjacent to financial-advice territory — copy must never cross the line into recommendations or predictions.

**Vibe Spinner** — High-RPM engine simulator game. Android (in development). Physics-accurate engine spinner with real-time audio synthesis. Repetitive finger-spinning gameplay creates a real RSI / physical-strain risk that must be disclosed in Terms and on the product page. Lower compliance complexity than the other two, but the physical-strain warning is non-negotiable.

---

## 4. Voice & Hard Rules

**Voice.** Confident, plainspoken, engineering-honest. Short sentences when possible. We say what the product does and what it does not do. We do not oversell. We do not use words like "revolutionary," "AI-powered" (when the AI is just an SDK), or "military-grade." We treat the user as intelligent.

**Cross-product hard rules — never violate.**
- Never imply or state that any user data is stored in the cloud, on our servers, or anywhere off the user's device. (Exception: the Edge Journal AI coaching feature transmits per-session, per-consent — and even that gets phrased carefully.)
- Never imply Security SPY is for surveilling other people. The product is for protecting the owner's own device against unauthorized access.
- Never give financial advice, investment recommendations, or performance predictions in any Edge Journal copy.
- Never market Vibe Spinner without the physical-strain / RSI warning visible on the product page and in Terms.
- Never use "Vibe Studios Spinner" — the product name is "Vibe Spinner."
- Never write copy that promises features the product does not have.

---

## 5. Operating Stack

| Function | Tool | Notes |
|---|---|---|
| Domain registrar | Namecheap | roretech.com |
| Web hosting | Netlify | Auto-deploy from GitHub main branch, ~60s |
| Source control | GitHub (org: rj235417-ui) | Public repo for site, private repos for product code |
| Email | Zoho Mail | support@roretech.com, privacy@roretech.com |
| Banking | Mercury | Business checking for the LLC |
| Mobile distribution | Google Play Console | Security SPY live; Vibe Spinner planned |
| Desktop distribution | GitHub Releases | RORE Edge Journal binaries |
| Payments — mobile | Google Play Billing | Security SPY subscriptions |
| Payments — desktop | TBD | Edge Journal Pro/Lifetime (placeholder URL exists; no provider integrated yet) |
| AI infrastructure | Anthropic Claude API | Edge Journal AI coaching feature |
| Trademark | USPTO Classes 9 & 42 | Registered |
| DUNS | D&B | Application pending |

**Notable absences (intentional).** No CRM, no analytics platform, no marketing automation, no Slack, no project management tool. Solo operation — added complexity must earn its keep.

---

## 6. Founder Profile

> This section exists because agent design depends on knowing the actual operator, not an idealized one.

- **Operating mode:** Solo founder. No employees, no contractors on regular retainer.
- **Time pattern:** Builds in evenings and weekends around other commitments. High-context-switching cost. Long uninterrupted blocks are rare.
- **Strengths:** Ships product. Cares about craft. Comfortable across product, design, code, copy, and operations.
- **Bottlenecks:** Marketing/distribution is the primary gap. Compliance/legal is the secondary gap (especially Security SPY's stalkerware-policy adjacency). Financial and tax operations have not been formalized yet.
- **Decision style:** Wants honest pushback over agreeable validation. Prefers fewer, sharper recommendations to long enumerated lists. Will reject overbuilt systems that add maintenance burden.
- **Risk tolerance:** Conservative on legal/compliance. Aggressive on product ambition. Allergic to subscription-trap business models.

**What this means for agent design here.**
- Lower-maintenance designs beat higher-power ones if the latter requires daily attention.
- Agents must produce scannable output. The founder will not read 800-word responses to small questions.
- Roundtables and frameworks are preferred over standalone agents because they reduce routing overhead.
- Anything we build here should plausibly still be in use 90 days from now. If it requires daily ritual to maintain, it dies.

---

## 7. Compliance & Regulatory Landscape

Each product sits under a different regulatory frame. Agents working on each product must apply the right lens.

**Security SPY**
- Google Play Developer Program Policies — Stalkerware and Surveillance section is the live tripwire. Listing copy, screenshots, and feature scope must avoid any framing that implies covert monitoring of third parties.
- Biometric privacy laws — Illinois BIPA, Texas CUBI, EU GDPR Article 9, Brazil LGPD. The current architecture (on-device-only, geometry ratios not raw templates) is defensible, but any change to biometric handling requires re-review.
- Wiretap and stalking laws — vary by US state and country. The product page must continue to clearly state intended use is for the owner's own device.

**RORE Edge Journal**
- Investment Advisers Act of 1940 (US) and state-level adviser regulations — the line is between *journaling/analytics* (allowed) and *advice/recommendations* (regulated). All copy and AI output must stay on the safe side of that line.
- General consumer-protection rules around software claims — no "guaranteed returns" type language, ever.
- EU/UK consumer rights (digital goods, refunds) — applicable if sold to those regions.

**Vibe Spinner**
- Standard mobile game policies — relatively low complexity.
- Physical-strain disclosure — required for repetitive-motion gameplay. Industry norm; not optional.
- COPPA and equivalents — game must not be marketed to or designed for children under 13 unless we accept the heavy compliance burden.

**Cross-cutting**
- Privacy policies must accurately describe data flows. Inaccuracy is the most common cause of regulatory action against small developers.
- Terms of Service governing law must match the state of formation (Massachusetts) — see Section 9.

---

## 8. Finance, Tax & Reporting Cadence

> This section sets expectations for what gets tracked when. The Project will help draft templates and reminders, but the founder owns execution.

**Monthly**
- Reconcile Mercury account against expected income/expenses.
- Capture Google Play earnings report (downloadable from Play Console).
- Note any new business expenses (domain, hosting, dev tools, software licenses) — receipts to a single folder.

**Quarterly**
- Estimated federal tax payment (Form 1040-ES) — single-member LLC income flows to founder's Schedule C.
- Massachusetts estimated state tax payment (Form 1-ES).
- Review of three-product portfolio: what shipped, what stalled, what to kill.

**Annually**
- Federal return: Schedule C attached to Form 1040.
- Massachusetts state return.
- Massachusetts LLC annual report (due each year on the anniversary month of formation; small filing fee).
- Trademark maintenance check (USPTO has periodic declarations of use due years 5-6 and 9-10 after registration).
- Renew domain (Namecheap auto-renews if enabled).

**Things this Project can help draft over time.**
- Monthly metrics digest template
- Quarterly portfolio review protocol
- Pre-tax-season expense categorization checklist
- Decision journal for product/business calls worth remembering

**Things this Project will NOT do.**
- Replace a CPA. When real money flows or S-Corp election is on the table, a Massachusetts CPA familiar with single-member LLCs is the right call.
- Replace a lawyer. For trademark disputes, biometric privacy challenges, or Play Store appeals, get counsel.

---

## 9. Open Items & Known Inconsistencies

> Living list. Items get added when discovered, removed when resolved. The Project should refer to this list whenever drafting work that intersects with these items.

1. **Governing law mismatch.** Terms of Service and Privacy Policy across all three product sites reference Delaware. The LLC is registered in Massachusetts. Update all `/terms.html` and `/privacy.html` pages (per-product and root) to reflect Massachusetts.
2. **DUNS number pending.** Once received, add to the legal entity record above. Some Apple App Store and enterprise contexts ask for it.
3. **Edge Journal payments provider.** Placeholder Gumroad URL exists in CLAUDE.md but no provider is integrated. Decide and integrate before promoting Pro/Lifetime tiers publicly.
4. **iOS rollout for Security SPY and Vibe Spinner.** Apple's review posture differs meaningfully from Google's, especially for the Security SPY category. Pre-submission compliance review will be needed.
5. **Apple Developer enrollment.** Likely required before iOS work begins. DUNS may be needed.
6. **Edge Journal AI coaching consent flow.** Per-session consent language should be reviewed once for compliance precision and then locked.
7. **Backup strategy for Mercury statements and Play Console reports.** Currently informal. Needs a simple monthly capture habit before tax season.
8. **USPTO application status — operational implications.** Until registration issues, use the ™ symbol (not ®) anywhere the RORE Tech mark appears in product copy, store listings, or marketing. Watch for USPTO office actions during the examination period — they have strict response deadlines (typically 3-6 months) and a missed response abandons the application.

---

## 10. What This Project IS and IS NOT For

**This Project IS for:**
- Designing, refining, and stress-testing AI agents and roundtables before deployment to product Projects
- Drafting org-level operating frameworks (decision protocols, review checklists, escalation rules, monthly/quarterly cadences)
- High-level company management — finance posture, tax cadence reminders, compliance landscape tracking, reporting templates, strategic portfolio review
- Maintaining canonical source-of-truth versions of all agent files, frameworks, and operating documents
- Capturing and refining RORE Tech's evolving operating philosophy

**This Project is NOT for:**
- Day-to-day product work for Security SPY, Edge Journal, or Vibe Spinner — those have their own Projects with their own CLAUDE.md and deployed agents
- Code review, marketing copy review, compliance review on actual deliverables — those go through the deployed roundtable in the relevant product Project
- Legal advice (consult a Massachusetts attorney)
- Tax filing or accounting (consult a CPA)
- Anything that pulls focus away from the meta-design and HQ-management role of this Project

---

*Last updated: founding draft. Update freely as the company evolves.*
