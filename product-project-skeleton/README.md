# Product Project Skeleton

> **What this is.** The starting structure for any new RORE Tech
> product project. When you create a new product (e.g.,
> Vibe Spinner, Edge Journal, VibeFire, or future products), you
> copy this skeleton into the new product's repo. It encodes the
> EOS structure (cycle handoffs, required folders, synced HQ
> artifacts) at the moment of project birth, before any code is
> written.
>
> **Why a skeleton.** Without it, every new product repo gets
> manually assembled from scratch — `docs/protocols/`,
> `docs/decisions/`, `.audit/`, CLAUDE.md, etc. The skeleton makes
> bootstrapping deterministic. Eventually a bootstrap script
> automates the copy and version-stamping; until then, the
> operator copies manually.
>
> **What this is not.** A product template. The skeleton has no
> product-specific content (no language choice, no framework, no
> dependencies). It only carries the EOS structure. The product
> author adds language/framework on top.

---

## Skeleton structure

```
product-project-skeleton/
├── CLAUDE.md                      # Synced from rore-tech-hq/eos/templates/
│                                  # CLAUDE_MD_TEMPLATE.md. Operator fills
│                                  # PROJECT-SPECIFIC section.
│
├── ROUNDTABLE.md                  # Synced from rore-tech-hq/roundtable/.
│                                  # Identical across all products. Don't edit
│                                  # in the product; raise lessons to HQ.
│
├── README.md                      # Skeleton's own README; product author
│                                  # replaces with product-specific README
│                                  # when shipping.
│
├── .gitignore                     # Includes EOS-required exclusions
│                                  # (videos, node_modules, .env, build
│                                  # artifacts, OS files).
│
├── .audit/                        # Synced from rore-tech-hq/eos/audit/.
│   ├── README.md
│   ├── stalkerware-patterns.txt
│   ├── deprecated-strings.txt
│   ├── hardcoded-secrets.txt
│   ├── debug-affordances.txt
│   ├── asset-existence.sh
│   ├── link-consistency.sh
│   └── audit.sh
│
└── docs/
    ├── protocols/                 # Phase Protocol documents go here.
    │   └── README.md              # Explains the protocol-per-phase pattern.
    │
    ├── decisions/                 # ADRs go here.
    │   └── README.md              # Explains the ADR pattern.
    │
    └── checklists/                # Local copies of HQ checklists this
        │                          # product uses, synced at the version
        │                          # the product is currently on.
        └── README.md              # Explains how to sync from HQ.
```

Optional, created when first needed:

```
└── docs/
    └── runbooks/                  # Per-product runbooks. Created when
                                   # the operator asks "how did I do
                                   # this last time?" the second time.
```

---

## What the operator does to bootstrap a new product

Until a bootstrap script exists, the manual sequence is:

1. **Create the new product's repo** (GitHub, local, etc.).

2. **Copy the skeleton's contents** into the new repo.
   ```
   cp -r rore-tech-hq/product-project-skeleton/. <new-product-repo>/
   ```

3. **Open `<new-product-repo>/CLAUDE.md`.** Replace
   `[PRODUCT NAME]` and the bracketed placeholders. Fill the
   PROJECT-SPECIFIC section (sections P1–P10).

4. **Stamp the HQ STANDARDS version.** At the top of the
   HQ STANDARDS section, set the `Synced from: rore-tech-hq @ vX.Y
   on YYYY-MM-DD` line to the current HQ version (read from
   `rore-tech-hq/eos/MANUAL.md` Section 0 or
   `rore-tech-hq/CHANGELOG.md` if maintained).

5. **Decide which HQ checklists this product uses** and copy them
   into `docs/checklists/`:
   - Every product gets `PHASE_EXIT_GATE.md`.
   - Mobile products: `PLAY_STORE_SUBMISSION.md` and/or
     (future) `APP_STORE_SUBMISSION.md`.
   - Backend products: `DEPLOYMENT_CHECKLISTS.md` (Section A
     specifically).
   - Web/PWA products: `DEPLOYMENT_CHECKLISTS.md` (Sections B
     and/or C).
   - Desktop products: `DEPLOYMENT_CHECKLISTS.md` (Section D).
   - Products using Firebase + Flutter: `FIREBASE_FLUTTER_SETUP.md`.
   - Products with importers: `EXTERNAL_DATA_IMPORTER.md`.
   - Products with AI-published content: `AI_PUBLISHING_PIPELINE.md`.
   - Any product creating signing material: `SIGNING_KEY_BIRTH_CERTIFICATE.md`.

6. **Decide if this product is surveillance-adjacent.** If yes
   (Security SPY profile), create `.audit/SURVEILLANCE_ADJACENT`
   marker file. The audit runner detects the marker and runs
   `stalkerware-patterns.txt` for this product.

7. **Install the pre-commit hook.**
   ```
   cp .audit/audit.sh .git/hooks/pre-commit-audit
   echo '#!/bin/bash' > .git/hooks/pre-commit
   echo '.audit/audit.sh --pre-commit' >> .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

8. **Initial commit.** Commit message: `Bootstrap: <product> from
   rore-tech-hq skeleton vX.Y`.

9. **Create the first Phase Protocol.** Copy
   `rore-tech-hq/eos/templates/PHASE_PROTOCOL_TEMPLATE.md` to
   `docs/protocols/phase-0.md` (or `phase-1.md` if Phase 0 is
   trivial setup). Fill the kickoff sections. The first phase
   begins.

---

## What gets re-synced and when

| Artifact | Sync trigger | Mechanism |
|---|---|---|
| CLAUDE.md HQ STANDARDS section | Phase kickoff | Manual copy of HQ STANDARDS section from current `eos/templates/CLAUDE_MD_TEMPLATE.md`; PROJECT-SPECIFIC section preserved |
| ROUNDTABLE.md | When HQ updates the file (rare) | Manual copy from `rore-tech-hq/roundtable/ROUNDTABLE.md` |
| `.audit/` pattern files | When HQ updates patterns (monthly review or critical update) | Manual copy of changed pattern files from `rore-tech-hq/eos/audit/` |
| `docs/checklists/` files | When HQ updates the relevant checklist | Manual copy of changed checklist from `rore-tech-hq/eos/checklists/` |

A future standards-sync agent automates these. Until then, the
operator does the copy at phase kickoff (default) or when HQ
flags a critical update (push).

---

## What goes into git in the new product repo

Everything in the skeleton goes into git — including the synced
HQ artifacts. The product's repo carries its own copy of CLAUDE.md
(both sections), ROUNDTABLE.md, the `.audit/` pattern files, and
the relevant checklists.

This duplication is intentional. It means:
- The product is self-contained — a contributor cloning just the
  product repo has everything they need.
- The product can fall behind HQ versions without breaking — it
  syncs at its own cadence.
- The product's version of any HQ artifact is captured at the
  time of last sync, which is auditable via git history.

The cost: when HQ updates an artifact, every product re-syncs.
Manual today, automated eventually.

---

## What the skeleton does NOT include

- **Language- or framework-specific scaffolding.** Flutter
  projects start with `flutter create` after the skeleton is
  copied. Node projects run `npm init`. Etc.
- **CI configuration.** Each product chooses its CI; the skeleton
  doesn't presume.
- **License.** Operator decides per product (MIT, proprietary,
  etc.) and adds when initializing.
- **Specific HQ checklists copied in.** Step 5 above is per-product
  judgment; the skeleton can't predict which apply.

---

*Skeleton README. Maintained in
`rore-tech-hq/product-project-skeleton/README.md`. Updated
whenever the bootstrap process changes.*
