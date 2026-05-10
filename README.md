# rore-tech-hq

> RORE Tech's Engineering Operating System (EOS) — the
> standards-and-protocols layer that governs how every RORE Tech
> product is built, gated, and shipped.
>
> This repo is the canonical source. Product projects each carry
> a synced subset.

---

## What's in this repo

```
rore-tech-hq/
├── README.md                          # This file. Index and orientation.
│
├── eos/                               # Engineering Operating System
│   ├── MANUAL.md                      # The philosophy and the cycle. Read first.
│   ├── lessons/                       # Cross-project lessons inventory and intake.
│   ├── templates/                     # Templates products copy from.
│   ├── checklists/                    # Reusable checklists.
│   ├── runbooks/                      # Step-by-step procedures.
│   └── audit/                         # Versioned grep-pattern audit files.
│
├── roundtable/
│   └── ROUNDTABLE.md                  # The five-chair advisory system.
│
├── org/                               # Org-level canonical facts.
│   ├── LEGAL_ENTITY.md
│   ├── PRODUCTS.md
│   ├── BILLING_MATRIX.md
│   └── DOMAIN_REGISTRY.md
│
├── reviews/
│   └── monthly/                       # Monthly review notes accumulate here.
│
├── product-project-skeleton/          # Starter structure for new products.
│   └── README.md                      # Bootstrap instructions.
│
└── RORE_TECH_ORG.md                   # Company-level context. Founder profile,
                                       # operating stack, compliance landscape.
```

---

## How to use this repo

**If you're new to it,** start at
[`eos/MANUAL.md`](eos/MANUAL.md). It explains the philosophy, the
three-layer model, and the cycle (Adoption → Execution → Reporting
→ Update) that makes the system sharpen over time. Twenty minutes
of reading.

**If you're starting a new product,** copy
[`product-project-skeleton/`](product-project-skeleton/) into the
new product's repo and follow the bootstrap steps in its README.

**If you're running a phase in an existing product,**
[`eos/templates/PHASE_PROTOCOL_TEMPLATE.md`](eos/templates/PHASE_PROTOCOL_TEMPLATE.md)
is what you copy. The Universal Phase Exit Gate is embedded in
Section 5 of that template.

**If you're closing a phase,** Section 5.10 generates a 5-line
intake. File it under
[`eos/lessons/intake/`](eos/lessons/intake/). The intake protocol
is at [`eos/lessons/INTAKE_PROTOCOL.md`](eos/lessons/INTAKE_PROTOCOL.md).

**If a Roundtable session was summoned in a product project and
you want to refine a chair**, that work happens here in HQ, in
[`roundtable/ROUNDTABLE.md`](roundtable/ROUNDTABLE.md).

**If you're doing the monthly review,**
[`eos/lessons/INTAKE_PROTOCOL.md`](eos/lessons/INTAKE_PROTOCOL.md)
Section "Checkpoint 4" is the procedure. Notes go in
[`reviews/monthly/`](reviews/monthly/).

---

## Artifact index

### Standards (read once, applied everywhere)

| Artifact | Purpose |
|---|---|
| [`eos/MANUAL.md`](eos/MANUAL.md) | The philosophy, the cycle, the discipline standard. The single document that explains the whole system. |
| [`eos/templates/CLAUDE_MD_TEMPLATE.md`](eos/templates/CLAUDE_MD_TEMPLATE.md) | The HQ STANDARDS + PROJECT-SPECIFIC sectioned format. Every product's CLAUDE.md derives from this. |
| [`roundtable/ROUNDTABLE.md`](roundtable/ROUNDTABLE.md) | Five-chair advisory system. Silent by default. Summoned per defined protocols. |
| [`RORE_TECH_ORG.md`](RORE_TECH_ORG.md) | Company-level context — entity, products, founder profile, compliance landscape. |

### Templates (copied into product projects per use)

| Artifact | Purpose |
|---|---|
| [`eos/templates/PHASE_PROTOCOL_TEMPLATE.md`](eos/templates/PHASE_PROTOCOL_TEMPLATE.md) | One per phase per product. Embeds the Phase Exit Gate. |
| [`eos/templates/ADR_TEMPLATE.md`](eos/templates/ADR_TEMPLATE.md) | For decisions that are expensive to reverse. |
| [`eos/templates/BUG_REPORT_PROMPT.md`](eos/templates/BUG_REPORT_PROMPT.md) | Descriptive (not prescriptive) format for Claude Code bug-fix sessions. |
| [`eos/templates/LAUNCH_PLAN_TEMPLATE.md`](eos/templates/LAUNCH_PLAN_TEMPLATE.md) | For first-production launches. Distinct from a Phase Protocol. |

### Checklists (walked at gates)

| Artifact | When to walk |
|---|---|
| [`eos/checklists/PHASE_EXIT_GATE.md`](eos/checklists/PHASE_EXIT_GATE.md) | Every phase, every product. Embedded in the Phase Protocol. |
| [`eos/checklists/FIREBASE_FLUTTER_SETUP.md`](eos/checklists/FIREBASE_FLUTTER_SETUP.md) | Setup or change to Firebase + Flutter on any product. |
| [`eos/checklists/PLAY_STORE_SUBMISSION.md`](eos/checklists/PLAY_STORE_SUBMISSION.md) | Every Play Store submission, including resubmissions. |
| [`eos/checklists/EXTERNAL_DATA_IMPORTER.md`](eos/checklists/EXTERNAL_DATA_IMPORTER.md) | Building or extending a data importer (CSV, PDF, RSS, broker exports). |
| [`eos/checklists/AI_PUBLISHING_PIPELINE.md`](eos/checklists/AI_PUBLISHING_PIPELINE.md) | Any product where an LLM publishes content externally. |
| [`eos/checklists/SIGNING_KEY_BIRTH_CERTIFICATE.md`](eos/checklists/SIGNING_KEY_BIRTH_CERTIFICATE.md) | Pulled out at the moment of credential or signing-material creation. |
| [`eos/checklists/DEPLOYMENT_CHECKLISTS.md`](eos/checklists/DEPLOYMENT_CHECKLISTS.md) | Bundled: Backend (A) / Web (B) / PWA (C) / Electron (D). |

### Runbooks (consulted at the moment of need)

| Artifact | When to consult |
|---|---|
| [`eos/runbooks/SEO_TRIAGE.md`](eos/runbooks/SEO_TRIAGE.md) | Opening Google Search Console and seeing flagged URLs. |
| [`eos/runbooks/EMAIL_INFRA_MIGRATION.md`](eos/runbooks/EMAIL_INFRA_MIGRATION.md) | Setting up a new business email address with SPF/DKIM/DMARC. |

### Audit patterns (run as pre-commit hook and pre-submission gate)

| Artifact | Catches |
|---|---|
| [`eos/audit/stalkerware-patterns.txt`](eos/audit/stalkerware-patterns.txt) | Surveillance-class code patterns (opt-in via marker file). |
| [`eos/audit/deprecated-strings.txt`](eos/audit/deprecated-strings.txt) | Old names, old states, old billing language. |
| [`eos/audit/hardcoded-secrets.txt`](eos/audit/hardcoded-secrets.txt) | API keys, tokens, credentials in committed code. |
| [`eos/audit/debug-affordances.txt`](eos/audit/debug-affordances.txt) | DEV buttons, console.log, debug bypass code. |
| [`eos/audit/asset-existence.sh`](eos/audit/asset-existence.sh) | HTML-referenced assets that aren't tracked in git. |
| [`eos/audit/link-consistency.sh`](eos/audit/link-consistency.sh) | Filename whitespace, link extension consistency. |
| [`eos/audit/audit.sh`](eos/audit/audit.sh) | The runner that walks all of the above. |

### Org-level canonical facts (referenced; never restated)

| Artifact | Purpose |
|---|---|
| [`org/LEGAL_ENTITY.md`](org/LEGAL_ENTITY.md) | RORE Tech LLC entity facts. Legal pages reference. |
| [`org/PRODUCTS.md`](org/PRODUCTS.md) | Canonical product names, taglines, package IDs. |
| [`org/BILLING_MATRIX.md`](org/BILLING_MATRIX.md) | Per-product, per-platform billing surface. |
| [`org/DOMAIN_REGISTRY.md`](org/DOMAIN_REGISTRY.md) | SW scopes per shared domain. |

### Cross-project intake

| Artifact | Purpose |
|---|---|
| [`eos/lessons/INVENTORY.md`](eos/lessons/INVENTORY.md) | Cross-project lessons inventory. Source of truth for what's been learned. |
| [`eos/lessons/INTAKE_PROTOCOL.md`](eos/lessons/INTAKE_PROTOCOL.md) | How lessons flow from product projects to HQ; monthly review process. |
| [`eos/lessons/intake/`](eos/lessons/intake/) | Where 5-line intakes from product projects land. |

---

## Versioning

Each major artifact carries a version number at its top
(`Version: 0.1`, etc.). When a product's CLAUDE.md HQ STANDARDS
section is synced, it records the version it synced from. The
monthly review surfaces any product running on a version >1
minor behind current.

This repo as a whole doesn't use semver tags. Individual
artifacts version independently.

---

## Update flow

```
Product project closes a phase
         ↓
5-line intake filed in eos/lessons/intake/
         ↓
Monthly review reads intakes
         ↓
INVENTORY.md updated; relevant artifact(s) updated
         ↓
Next phase in any product pulls updated version at adoption
```

For critical updates (a new policy-driven pattern, a security-
relevant standard change), HQ pushes a notification rather than
waiting for next phase pull.

---

## What this repo is NOT

- **Not a code repo.** No build artifacts. No language-specific
  scaffolding. No CI configuration. Those live in product repos.
- **Not legal counsel or financial accounting.** When real money
  flows or real legal questions arise, this repo's standards say
  "consult a professional," and they mean it.
- **Not the place for product-specific work.** Code review,
  marketing copy review, compliance review on actual deliverables
  — those go through the deployed Roundtable in the relevant
  product project, not here.
- **Not a public repo.** This is the operator's HQ. It contains
  references to entity facts, billing surfaces, and process
  details that don't need to be public.

---

## Future-state automation hooks

The Manual Section 7 names five future agents that automate parts
of this system. None are built yet; the manual process must be
stable across 2-3 monthly review cycles before any of them are
worth building. Premature automation codifies chaos.

The hooks for them are already named in the relevant artifacts.
When the time comes to build, the hooks point at exactly where
each agent intercepts.

---

*Repository README. Last updated: 2026-05-10 (initial
populate). Maintainer: Operator.*
