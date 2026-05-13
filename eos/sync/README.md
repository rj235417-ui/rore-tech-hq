# eos/sync/

> The sync system. Propagates HQ STANDARDS and manifest-declared
> Tier 2 artifacts from this HQ repo into product project repos.
> Replaces the prior manual-copy bootstrap process.

---

## Files

- **`sync-to-project.sh`** — the script. Bash, macOS-compatible,
  no external dependencies.
- **`manifest.conf`** — declares which Tier 2 artifacts apply to
  which products. Bash-sourceable key=value + arrays. Edit this
  by hand more often than the script.
- **`README.md`** — this file.

---

## Quick start

```bash
cd ~/Desktop/rore-tech-hq

# First sync of an existing product, pilot scope (Tier 1 only)
./eos/sync/sync-to-project.sh --tier1-only ~/Desktop/vibefire

# Full sync (Tier 1 + Tier 2)
./eos/sync/sync-to-project.sh ~/Desktop/vibefire

# Dry run (preview what would change, modify nothing)
./eos/sync/sync-to-project.sh --dry-run ~/Desktop/vibefire

# Explicit product key (if path-based auto-detection fails)
./eos/sync/sync-to-project.sh --product VIBEFIRE ~/Desktop/my-experimental-fork
```

After running, the script prints a summary and writes
`SYNC_REPORT.md` to the target project. Review with:

```bash
cd ~/Desktop/vibefire
git status
git diff
cat SYNC_REPORT.md
```

The script never commits anything. You commit manually after
reviewing.

---

## What gets synced

**Tier 1 — always synced** (regardless of manifest):

| Source | Destination in product |
|---|---|
| `eos/templates/CLAUDE_MD_TEMPLATE.md` (HQ STANDARDS section) | `CLAUDE.md` (top section; PROJECT-SPECIFIC preserved verbatim) |
| `roundtable/ROUNDTABLE.md` | `ROUNDTABLE.md` |
| `eos/templates/PHASE_PROTOCOL_TEMPLATE.md` | `docs/templates/PHASE_PROTOCOL_TEMPLATE.md` |
| `eos/templates/ADR_TEMPLATE.md` | `docs/templates/ADR_TEMPLATE.md` |
| `eos/templates/BUG_REPORT_PROMPT.md` | `docs/templates/BUG_REPORT_PROMPT.md` |

**Tier 2 — synced per manifest** (skipped if `--tier1-only`):

Whatever the manifest declares in `PRODUCT_<KEY>_TIER2` lands at
`docs/standards/<filename>.md` in the product, with a "Synced from"
header prepended.

---

## During a `.proposed` merge — audit guidance

> *Added v0.2, from Edge Journal adoption intake 2026-05-13.*

The `.proposed` flow exists for the first sync against any project
with a pre-EOS CLAUDE.md. The mechanical task is merging
PROJECT-SPECIFIC content from the original into the sectioned
template. The *opportunity* — and the discipline — is auditing
the original against current code reality before merging.

Across the first three EOS adoptions, the merge surfaced real
drift in three of three projects:

- **VibeFire** — documented as "native Android" but actually
  Flutter. Caught at first sync 2026-05-11.
- **Vibe Spinner** — documented as "native Android" but actually
  Capacitor 8 + HTML/CSS/JS. Caught at first sync 2026-05-12.
- **Edge Journal** — documented an AI tab feature that calls
  `localhost:3001` with no proxy in repo and no setup docs —
  shipped-broken state hidden by doc-to-doc consistency. Caught
  at first sync 2026-05-13.

Three of three is a pattern, not coincidence. The `.proposed`
flow is the highest-leverage moment for catching documentation
drift because it forces the operator to read CLAUDE.md word-by-word
against the current code.

### The audit step

Before accepting any PROJECT-SPECIFIC content into the new
CLAUDE.md:

1. **List every named external service, endpoint, library, or
   stack component** in the existing P4 (Architecture overview)
   and equivalent sections — anything the doc says the product
   uses or talks to.

2. **For each, grep the repo.** If the named thing isn't there,
   uses a different pattern, or has no setup documentation, the
   doc is stale or the feature is broken. Both are findings.

3. **Document the finding** in P3 (per-product hard rules) or
   P8 (open items) of the new CLAUDE.md, not as a silent fix.
   Silent fixes lose the audit trail; explicit findings let the
   next phase address them deliberately.

Doc-to-doc consistency is necessary but not sufficient. The
adoption sync is the rare moment when someone reads CLAUDE.md
carefully against the current code; use it.

*Lesson trace: `eos/lessons/intake/processed/2026-05-13-edge-journal-adoption.md`.*

---

## Safety properties

1. **Never deletes.** The script only adds, modifies, or skips.
2. **Never runs git commands** in the target project. Working tree
   only; you commit manually.
3. **Always backs up** before modifying (`*.pre-eos-sync-YYYY-MM-DD`).
4. **Idempotent.** Running twice on the same clean project on the
   same day produces zero diff.
5. **Refuses unsafe overwrites.** If existing CLAUDE.md lacks the
   sectioned format, writes `CLAUDE.md.proposed` for manual merge
   instead of clobbering. Exit code 2 surfaces this.

---

## Exit codes

- `0` — success.
- `1` — user error (bad args, target not a directory).
- `2` — sync proceeded but `CLAUDE.md.proposed` was written for
  manual merge. Treat as "needs your attention" not "failed."
- `3` — manifest error or unknown product.
- `4` — internal error (missing HQ artifacts, etc.).

---

## Adding a new product to the manifest

Edit `manifest.conf`. Add a block following the existing pattern:

```bash
PRODUCT_MYNEWPROD_NAME="My New Product"
PRODUCT_MYNEWPROD_REPO_HINT="~/Desktop/my-new-prod"
PRODUCT_MYNEWPROD_TIER2=(
  "PLAY_STORE_SUBMISSION"
  "SIGNING_KEY_BIRTH_CERTIFICATE"
)
```

Append `MYNEWPROD` to `KNOWN_PRODUCTS`. Add a `PATH_HINT_MYNEWPROD`
line if the path-based auto-detection should match.

Then run the sync against the target path.

---

## Adding a new Tier 2 artifact to the manifest

When HQ ships a new checklist or runbook that some products should
adopt:

1. Drop the artifact at the appropriate path under `eos/checklists/`
   or `eos/runbooks/`.
2. Open `sync-to-project.sh`. Find the `TIER2_PATHS` associative
   array. Add a line:
   ```bash
   TIER2_PATHS["MY_NEW_CHECKLIST"]="$HQ_ROOT/eos/checklists/MY_NEW_CHECKLIST.md"
   ```
3. Update each `PRODUCT_<KEY>_TIER2` array in `manifest.conf` to
   include `MY_NEW_CHECKLIST` for products that should adopt it.
4. Re-run the sync against each affected product.

---

## Troubleshooting

**"Could not auto-detect product from path."** The path doesn't
contain any string in the `PATH_HINT_*` definitions. Use
`--product KEY` to specify explicitly.

**Exit code 2, `.proposed` file written.** First sync against a
project with a pre-EOS CLAUDE.md. Open
`<product>/CLAUDE.md.proposed`, manually merge content from the
original `CLAUDE.md` into the `PROJECT-SPECIFIC` sections P1–P10,
rename `.proposed` to `CLAUDE.md`, delete the old one. Subsequent
syncs will be safe.

**Backup files accumulating.** Every sync creates
`*.pre-eos-sync-YYYY-MM-DD` if it modifies a file. They're
deliberate — they let you `diff` against the prior version. Clean
them up manually when you no longer need the history (or git-ignore
the pattern if you only want git history as the audit trail).

**Registry not updating.** Check that
`rore-tech-hq/org/PROJECT_REGISTRY.md` exists and contains the
`<!-- SYNC_ROWS_END -->` marker. If the marker is missing, the
script appends at end of file (still works, just messier).

---

## Why bash, not Python or something heavier

- Solo founder, one Mac, no need for a runtime install.
- macOS bash 3.2 is older but sufficient — the script avoids bash 4+
  features where possible. The associative array (`declare -A`) is
  the one bash-4 feature used; macOS ships with a newer bash if
  installed via Homebrew, or upgrades via `brew install bash` are
  one-line.
- The script is auditable in 500 lines. A Python equivalent would
  be 300 lines of Python plus dependencies plus a venv.
- This script is the manual-but-deterministic baseline. When the
  future Standards Sync Agent replaces it, this script's behavior is
  the spec for what the agent must do.

---

## Future: the Standards Sync Agent

Per the EOS Operating Manual Section 7, a future agent will replace
the manual invocation of this script with automatic propagation
triggered by HQ commit activity. This script is the spec for that
agent. Not built yet — premature automation codifies chaos.

The trigger to build the agent: 5+ successful manual sync cycles
across 2+ products, with the friction in the manual process
documented and stable.

---

*Sync system. v0.2 (was v0.1; bumped 2026-05-13 from Edge Journal
adoption intake — added .proposed merge audit guidance section).
Maintained at `rore-tech-hq/eos/sync/`.*
