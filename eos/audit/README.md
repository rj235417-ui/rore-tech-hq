# eos/audit/ — Pre-submission and pre-deploy grep audits

> **What this is.** A folder of versioned grep-pattern files plus a
> thin shell wrapper. Every product repo carries a synced copy.
> Audits run as a pre-commit hook (fast subset) and as a
> pre-submission gate (full audit). New patterns flow from HQ when
> surfaced anywhere.
>
> **What this is not.** A CI matrix. A SaaS product. A heavy
> infrastructure investment. Adding a pattern is a one-line PR;
> cost is near zero, value compounds. If anyone — including a
> future architect — proposes building this on Jenkins, GitHub
> Actions multi-stage, or any heavier stack, push back. The Vibe
> Spinner DEV-button-shipped-three-times bug needs a one-line
> bash script, not a pipeline.
>
> **Lesson trace.** HQ STANDARDS H10. Derived from
> `securityspy-LL-001`, `LL-009`, `LL-010`; `vibespin-LL-002`,
> `LL-004`; `roretech-website-LL-002`, `LL-003`, `LL-004`,
> `LL-008`; `xagent-LL-007`.

---

## Directory structure

```
eos/audit/
├── README.md                          # this file
├── stalkerware-patterns.txt           # surveillance-adjacent app patterns
├── deprecated-strings.txt             # old names, old states, old billing language
├── hardcoded-secrets.txt              # API keys, tokens, common secret patterns
├── debug-affordances.txt              # dev buttons, console.log, TODO: remove
├── asset-existence.sh                 # every <img src> resolves to a tracked file
├── link-consistency.sh                # internal links use consistent conventions
└── audit.sh                           # the runner
```

The pattern files (`*.txt`) are simple — one pattern per line,
comment lines start with `#`. The runner (`audit.sh`) walks the
patterns against the appropriate target (staged diff for
pre-commit, release artifact for pre-submission) and reports
PASS/FAIL with line references.

---

## How patterns work

### Pattern files (`*.txt`)

Each line is either:
- A grep pattern (regex or literal)
- A comment (starts with `#`)

Format:

```
# Patterns that indicate stalkerware-class code
# These trigger Google Play auto-enforcement even when unused

setComponentEnabledSetting.*COMPONENT_ENABLED_STATE_DISABLED
excludeFromRecents
hideAppIcon
showAppIcon
android:permission.*BIND_DEVICE_ADMIN

# Defensive permissions that signal surveillance
SYSTEM_ALERT_WINDOW
```

When the runner finds a match in the target, it reports:
```
[stalkerware-patterns.txt] FAIL
  app/android/app/src/main/AndroidManifest.xml:42 — SYSTEM_ALERT_WINDOW
```

### Sub-shell scripts (`*.sh`)

Some checks are too structural for grep alone — verifying every
referenced asset exists, verifying internal links use consistent
extensions. These get their own short shell scripts in the same
folder, called from `audit.sh`.

Each shell script returns 0 (PASS) or non-zero (FAIL) and prints
findings in the same format as grep patterns.

---

## Run modes

### Pre-commit (fast subset)

Run automatically on `git commit`. Walks only the lightweight
pattern files against the *staged diff* — not the whole repo.
Fails fast (under 1 second) so it doesn't slow normal commit flow.

Pre-commit subset:
- `hardcoded-secrets.txt`
- `debug-affordances.txt`
- `stalkerware-patterns.txt` (for surveillance-adjacent products)

Wired into `.git/hooks/pre-commit`. Setup is a one-line `cp` from
the bootstrap script (or manual install — see SETUP below).

### Pre-submission (full audit)

Run manually before any production submission. Walks the *release
artifact* — the AAB, AAR, deployed bundle, signed binary — not
the source tree. Catches what got compiled in even when the
source review was clean.

Full audit runs all pattern files plus the sub-shell scripts.

Wired into the Phase Exit Gate (Section 5.7) as a required item.

---

## Adding a new pattern

A pattern earns its place when:
1. A specific lesson surfaced where the pattern would have caught
   the failure.
2. The lesson ID is referenced in the pattern file's comment.
3. The pattern is specific enough not to false-positive.

To add a pattern:
1. Open the relevant pattern file (or create a new one if a new
   category is genuinely needed).
2. Add the pattern with a comment naming the lesson ID.
3. Run `audit.sh` against a known-good repo to verify no false
   positives.
4. Commit. Push. Distribute to product projects via the standard
   sync cycle.

### When to create a new pattern file

The default is "add to an existing file." Create a new file only
when a new category is justified by 2+ lessons. New categories
that might emerge over time:
- `manifest-hygiene.txt` — Android manifest patterns (over-broad
  permissions, missing intent filters, etc.)
- `pwa-scope.txt` — service worker registration patterns
- `payment-policy.txt` — payment provider consistency per platform

---

## Setup

For a new product project:

1. The bootstrap script (when it exists) syncs `eos/audit/` from
   HQ into the product repo and installs the pre-commit hook.
2. Until the bootstrap script exists: manual setup is
   ```
   cp -r rore-tech-hq/eos/audit/ <product-repo>/.audit/
   cp .audit/audit.sh-precommit-wrapper .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

---

## Update flow

When HQ updates a pattern file:
1. The next product project sync pulls the new patterns at phase
   kickoff (standard adoption).
2. For critical updates (a new policy-driven pattern that affects
   live submissions), HQ pushes a notification — operator runs
   the sync immediately.
3. Pattern updates are versioned; the synced copy in each product
   records which version it's at.

---

## What this catches, with lesson trace

| Pattern category | Lesson IDs | What it catches |
|---|---|---|
| stalkerware-patterns | `securityspy-LL-001`, `LL-009` | Dead surveillance-class code, defensive over-declarations |
| deprecated-strings | `roretech-website-LL-008`, `LL-009`, `LL-016` | Delaware vs Massachusetts; "Vibe Studios Spinner"; pasted-context drift |
| hardcoded-secrets | `xagent-LL-006`, `LL-007` | API keys committed; chat-pasted credentials |
| debug-affordances | `vibespin-LL-004` | DEV button, console.log, TODO: remove shipped to prod |
| asset-existence | `roretech-website-LL-003` | HTML referenced PNGs not committed |
| link-consistency | `roretech-website-LL-002`, `LL-004` | Filename whitespace; footer links missing .html |

---

## What's intentionally not here

- **Linters and type-checkers.** Those run as part of normal build,
  not part of this audit. The audit catches things linters miss —
  policy patterns, naming drift, asset existence. Adding eslint
  output here would muddy the signal.
- **Test runs.** Same reasoning. Tests run via the build; the
  audit checks for things tests can't see.
- **Format checking.** Same.

The audit is for the specific class of bug where "the artifact
contains a string the artifact shouldn't contain." That class is
small, specific, and reliably catchable by grep. Anything else
belongs elsewhere.

---

*Audit folder structure v0.1. Maintained in
`rore-tech-hq/eos/audit/`. Pattern files versioned independently;
this README versioned with the EOS Operating Manual.*
