# Launch Plan — [PRODUCT NAME] — v[X.Y]

> **What this document is.** The plan for taking a product from
> "feature-complete" to "live and supported." Distinct from a
> Phase Protocol. A Phase Protocol covers one development phase;
> a Launch Plan covers the *first time* a product reaches users
> (and any subsequent major version that materially changes the
> launch posture).
>
> **When to use this.** First production launch of any product.
> Major version launches that change platform, distribution, or
> compliance posture. Not for incremental version bumps — those
> use Phase Protocols.
>
> **Why distinct.** Launches have a category of work that
> development phases don't: store-listing creation, badge
> handling, developer-account setup, public address decisions,
> support email DNS, payment provider integration, marketing
> velocity control, post-launch monitoring. Folding all this into
> a Phase Protocol creates an unwieldy document.
>
> **Lesson trace.** Launch-specific lessons across the inventory
> include `securityspy-LL-006`, `LL-014`, `LL-019`, `LL-020`,
> `LL-021`, `LL-022`; `vibespin-LL-005`, `LL-007`, `LL-008`,
> `LL-009`, `LL-010`, `LL-017`; `roretech-website-LL-005`,
> `LL-013`, `LL-014`, `LL-015`. The structure below absorbs them.

---

## Header

| Field | Value |
|---|---|
| Product | [Product name] |
| Launch version | [v1.0, v2.0, etc.] |
| Launch type | [First production / Major version / Platform expansion (e.g., adding iOS)] |
| Target launch date | [YYYY-MM-DD] |
| Actual launch date | [YYYY-MM-DD or "open"] |
| Launch phase | [Links to the Phase Protocol that covers the launch — typically the production-launch phase] |
| HQ STANDARDS version this launch syncs from | [vX.Y] |

---

## 1. Launch posture

### What's being launched

[One paragraph: what the product does, who it's for, what platforms,
what the first version includes. Concise.]

### What's explicitly NOT in this launch

[Things deferred to a later launch — paid tiers, additional
platforms, additional features. Important because deferred items
sometimes appear in marketing copy or store listings; this section
is the source of truth for "not yet."]

### Launch velocity strategy

> *(Cross-references `securityspy-LL-006` — first releases on Play
> Console have no staged-rollout option.)*

- **Distribution control mechanism:** [Staged rollout if available
  / delayed marketing seed if not / private beta cohort / direct
  download with limited distribution / etc.]
- **Why this mechanism:** [The constraint or choice that drove it.]
- **Trigger to escalate:** [What signals readiness to expand —
  Vitals clean for N days, user feedback hits some bar, etc.]

---

## 2. Per-platform launch matrix

> One column per platform this launch targets. Each row is a
> launch-required item. Items may be N/A on some platforms.
> *(Cross-references H13 — per-platform, per-operation matrix.)*

| Item | [Platform 1] | [Platform 2] |
|---|---|---|
| Developer account active | | |
| Developer account type (Individual / Organization) | | |
| D-U-N-S number on file | | |
| Tax form (W-9 or equivalent) submitted with correct TIN | | |
| Public developer address (non-residential) | | |
| Support contact email (with SPF/DKIM/DMARC) | | |
| Payment provider integrated and tested | | |
| Code-signing certificate installed | | |
| Closed test cohort run (where required) | | |
| Privacy policy live at canonical URL | | |
| Terms of Service live at canonical URL | | |
| Store listing drafted and reviewed | | |
| Brand assets (badges, icons) from official sources only | | |
| Per-API prominent disclosures in app | | |
| Per-API disclosures in store listing | | |
| First-version submission accepted | | |

---

## 3. Pre-launch checklists run

> Each checklist owned by HQ; walked specifically as part of this
> launch.

- [ ] **Phase Exit Gate** for the production-launch phase walked
  and passed (or passed with documented waivers). Linked Phase
  Protocol: [...]
- [ ] **Pre-Submission Audit** (`PRE_SUBMISSION_AUDIT.md`) ran
  clean on the release artifact.
- [ ] **Service-specific setup checklists** for everything this
  launch touches — Firebase + Flutter, Play Store submission,
  App Store submission, AI publishing pipeline, Electron
  distribution, backend service hardening — each walked. List:
  - [...]
- [ ] **Signing-key birth certificate** ran for any new signing
  material created for the launch.
- [ ] **External Service Kickoff** ran for any third-party
  service introduced for the launch.

---

## 4. Compliance and policy verification

> *(Cross-references H10, H18, and per-product compliance
> landscape in CLAUDE.md P7.)*

- [ ] **Privacy policy** is accurate to the current data flow,
  not generic boilerplate. *(Cross-references `securityspy-LL-015`,
  `roreedge-LL-016`.)*
- [ ] **Privacy policy includes any required jurisdictional
  notices** for biometric handling (BIPA, CUBI, GDPR Art. 9,
  LGPD), third-party capture, age-gated content, etc.
- [ ] **Store listing language** documents each sensitive API by
  name with explicit use case. *(Cross-references
  `securityspy-LL-003`.)*
- [ ] **App-name field** has been audited for policy-relevant
  words. *(Cross-references `securityspy-LL-014`.)*
- [ ] **Paywall feature claims** map to built features.
  *(Cross-references `vibespin-LL-006`, H18.)*
- [ ] **Brand assets** come from official sources only.
  *(Cross-references `roretech-website-LL-005`, H18.)*
- [ ] **Public developer address** is non-residential.
  *(Cross-references `roretech-website-LL-014`.)*
- [ ] **Content rating questionnaire** vs. **Target Audience
  setting** are answered with understanding of which controls
  what. *(Cross-references `roretech-website-LL-013`.)*

---

## 5. Communication plan

### External

- [ ] **Launch announcement drafted** for the channels this
  product uses (product page, social media, email list if any).
- [ ] **Marketing seed timing decided** — synced with launch
  velocity strategy in Section 1.
- [ ] **Support page or FAQ** updated for the launch version.

### Internal (operator + AI collaborators)

- [ ] **CLAUDE.md PROJECT-SPECIFIC section** updated to reflect
  launched state — current version, distribution channels, status.
- [ ] **Phase history table (P9)** updated with the launch phase.

---

## 6. Post-launch monitoring (first 7 days)

> What gets watched, what gets escalated. Time-bounded so it
> doesn't become permanent overhead.

| Signal | Source | Threshold to investigate | Threshold to escalate |
|---|---|---|---|
| Crash rate | Play Console Vitals / App Store Connect / Sentry | [%] | [%] |
| User reviews | Play Console / App Store | [Sentiment] | [Specific complaint] |
| Support emails | Inbox | [Volume] | [Pattern] |
| Server errors (if applicable) | `/health` + logs | [Rate] | [Rate] |
| Cost burn (if applicable) | Provider dashboards | [Daily] | [Cumulative] |

---

## 7. Rollback plan

- **What "back out the launch" means:** [Pull from store, push
  rollback build, etc. Be specific.]
- **What user data is at risk during rollback:** [None / Specific
  scope.]
- **Decision criteria to invoke rollback:** [Specific trigger.]
- **Operator-only or AI-collaborator-allowed:** [The Roundtable's
  Compliance veto applies if rollback touches a privacy commitment
  or a regulated surface.]

---

## 8. Lessons captured during launch

> Updated during the launch and immediately after. Feeds into the
> 5-line lessons-learned intake at launch close.

- [Surface lesson here as it surfaces. One line each.]
- [...]

---

## 9. Launch-close lessons-learned intake

[The 5-line intake, sent to HQ at launch close. Same format as
phase-close intake. Copy here for the project's institutional
memory.]

```
Phase and product: ...
What went well: ...
What slipped: ...
Process implication: ...
One-line ask of HQ: ...
```

**Sent to HQ:** [YYYY-MM-DD]

---

*Launch Plan template v0.1. Sourced from
`rore-tech-hq/eos/templates/LAUNCH_PLAN_TEMPLATE.md`. Designed to
absorb launch-specific lessons from across the cross-project
inventory.*
