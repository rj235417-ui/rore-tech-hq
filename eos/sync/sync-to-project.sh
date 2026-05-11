#!/usr/bin/env bash
# rore-tech-hq/eos/sync/sync-to-project.sh
#
# Syncs HQ STANDARDS and manifest-declared Tier 2 artifacts from
# rore-tech-hq into a target product project repo.
#
# USAGE:
#   ./sync-to-project.sh [--tier1-only] [--product KEY] [--dry-run] <target-path>
#
# FLAGS:
#   --tier1-only       Sync only the HQ STANDARDS section + ROUNDTABLE.md
#                      + Phase Protocol template + ADR template + Bug
#                      Report Prompt. Skip Tier 2 (checklists, runbooks).
#   --product KEY      Override path-based product auto-detection.
#                      KEY must be in KNOWN_PRODUCTS in the manifest.
#   --dry-run          Show what would happen; modify nothing.
#
# EXIT CODES:
#   0   success
#   1   user error (bad args, target not a repo, etc.)
#   2   target state requires manual intervention (CLAUDE.md proposal)
#   3   manifest error or unknown product
#   4   internal error
#
# SAFETY:
#   - Never deletes files in the target project.
#   - Never runs git commands against the target.
#   - Backs up files to *.pre-eos-sync-YYYY-MM-DD before modifying.
#   - Idempotent: running twice produces zero diff on second run.
#
# COMPATIBILITY:
#   - Works on macOS default bash 3.2 and later.
#   - No associative arrays. No mapfile. No ${var,,}.
#   - Standard POSIX tools only: awk, sed, grep, cmp, cp, mv,
#     mktemp, basename, dirname, date, tr, printf, cat.
#   - git is used only to read HQ commit SHA (optional, falls back
#     to "not-in-git" if HQ is not a git repo). Never run against
#     the target.

set -euo pipefail

# ─────────────────────────────────────────────────────────────────
# Constants and locations
# ─────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HQ_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST_FILE="$SCRIPT_DIR/manifest.conf"

TEMPLATE_FILE="$HQ_ROOT/eos/templates/CLAUDE_MD_TEMPLATE.md"
ROUNDTABLE_FILE="$HQ_ROOT/roundtable/ROUNDTABLE.md"
PHASE_PROTOCOL_TEMPLATE="$HQ_ROOT/eos/templates/PHASE_PROTOCOL_TEMPLATE.md"
ADR_TEMPLATE="$HQ_ROOT/eos/templates/ADR_TEMPLATE.md"
BUG_REPORT_PROMPT="$HQ_ROOT/eos/templates/BUG_REPORT_PROMPT.md"

REGISTRY_FILE="$HQ_ROOT/org/PROJECT_REGISTRY.md"

PROJECT_SPECIFIC_MARKER="^# PROJECT-SPECIFIC"

TODAY="$(date +%Y-%m-%d)"
NOW="$(date +%Y-%m-%dT%H:%M:%S%z)"

if (cd "$HQ_ROOT" && git rev-parse --git-dir >/dev/null 2>&1); then
  HQ_SHA="$(cd "$HQ_ROOT" && git rev-parse --short HEAD)"
  HQ_SHA_FULL="$(cd "$HQ_ROOT" && git rev-parse HEAD)"
else
  HQ_SHA="not-in-git"
  HQ_SHA_FULL="not-in-git"
fi

# ─────────────────────────────────────────────────────────────────
# Tier 2 path resolver — POSIX-compatible (no associative arrays)
# ─────────────────────────────────────────────────────────────────

# Given an artifact key, echo its source path under HQ_ROOT.
# Returns 1 if the key is unknown.
# To add a new Tier 2 artifact: add one line below.
get_tier2_path() {
  case "$1" in
    FIREBASE_FLUTTER_SETUP)         echo "$HQ_ROOT/eos/checklists/FIREBASE_FLUTTER_SETUP.md" ;;
    PLAY_STORE_SUBMISSION)          echo "$HQ_ROOT/eos/checklists/PLAY_STORE_SUBMISSION.md" ;;
    EXTERNAL_DATA_IMPORTER)         echo "$HQ_ROOT/eos/checklists/EXTERNAL_DATA_IMPORTER.md" ;;
    AI_PUBLISHING_PIPELINE)         echo "$HQ_ROOT/eos/checklists/AI_PUBLISHING_PIPELINE.md" ;;
    SIGNING_KEY_BIRTH_CERTIFICATE)  echo "$HQ_ROOT/eos/checklists/SIGNING_KEY_BIRTH_CERTIFICATE.md" ;;
    DEPLOYMENT_CHECKLISTS)          echo "$HQ_ROOT/eos/checklists/DEPLOYMENT_CHECKLISTS.md" ;;
    LAUNCH_PLAN_TEMPLATE)           echo "$HQ_ROOT/eos/templates/LAUNCH_PLAN_TEMPLATE.md" ;;
    SEO_TRIAGE)                     echo "$HQ_ROOT/eos/runbooks/SEO_TRIAGE.md" ;;
    *)                              return 1 ;;
  esac
}

# ─────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────

TIER1_ONLY="no"
PRODUCT_KEY=""
DRY_RUN="no"
TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --tier1-only)
      TIER1_ONLY="yes"
      shift
      ;;
    --product)
      PRODUCT_KEY="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="yes"
      shift
      ;;
    -h|--help)
      sed -n '3,40p' "$0"
      exit 0
      ;;
    *)
      if [ -z "$TARGET" ]; then
        TARGET="$1"
      else
        echo "ERROR: unexpected argument: $1" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "ERROR: target project path required" >&2
  echo "Usage: $0 [--tier1-only] [--product KEY] [--dry-run] <target-path>" >&2
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "ERROR: target path does not exist or is not a directory: $TARGET" >&2
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

# ─────────────────────────────────────────────────────────────────
# Load manifest
# ─────────────────────────────────────────────────────────────────

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "ERROR: manifest not found at $MANIFEST_FILE" >&2
  exit 3
fi

# shellcheck source=/dev/null
. "$MANIFEST_FILE"

# ─────────────────────────────────────────────────────────────────
# Determine product key (from flag, or auto-detect from path)
# ─────────────────────────────────────────────────────────────────

if [ -z "$PRODUCT_KEY" ]; then
  target_lower="$(echo "$TARGET" | tr '[:upper:]' '[:lower:]')"
  for key in "${KNOWN_PRODUCTS[@]}"; do
    hint_var="PATH_HINT_${key}"
    hints="${!hint_var:-}"
    for hint in $hints; do
      case "$target_lower" in
        *"$hint"*)
          PRODUCT_KEY="$key"
          break 2
          ;;
      esac
    done
  done
fi

if [ -z "$PRODUCT_KEY" ]; then
  echo "ERROR: could not auto-detect product from path $TARGET" >&2
  echo "Use --product KEY to specify. Known products:" >&2
  for key in "${KNOWN_PRODUCTS[@]}"; do
    echo "  $key" >&2
  done
  exit 3
fi

# Verify product is in KNOWN_PRODUCTS
known="no"
for key in "${KNOWN_PRODUCTS[@]}"; do
  if [ "$key" = "$PRODUCT_KEY" ]; then
    known="yes"
    break
  fi
done
if [ "$known" = "no" ]; then
  echo "ERROR: $PRODUCT_KEY is not in KNOWN_PRODUCTS in the manifest" >&2
  exit 3
fi

# Resolve product display name
name_var="PRODUCT_${PRODUCT_KEY}_NAME"
PRODUCT_NAME="${!name_var:-$PRODUCT_KEY}"

# Resolve Tier 2 list for this product
tier2_var="PRODUCT_${PRODUCT_KEY}_TIER2[@]"
PRODUCT_TIER2=("${!tier2_var:-}")

# Surveillance-adjacent flag
surv_var="PRODUCT_${PRODUCT_KEY}_SURVEILLANCE_ADJACENT"
PRODUCT_SURVEILLANCE="${!surv_var:-no}"

# ─────────────────────────────────────────────────────────────────
# Pre-flight checks
# ─────────────────────────────────────────────────────────────────

echo "─────────────────────────────────────────────────────────"
echo " EOS Sync — $PRODUCT_NAME"
echo "─────────────────────────────────────────────────────────"
echo " Target:        $TARGET"
echo " Product key:   $PRODUCT_KEY"
echo " HQ commit:     $HQ_SHA"
echo " Tier1 only:    $TIER1_ONLY"
echo " Dry run:       $DRY_RUN"
echo "─────────────────────────────────────────────────────────"
echo ""

for f in "$TEMPLATE_FILE" "$ROUNDTABLE_FILE" "$PHASE_PROTOCOL_TEMPLATE" "$ADR_TEMPLATE" "$BUG_REPORT_PROMPT"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required HQ artifact missing: $f" >&2
    exit 4
  fi
done

if [ "$TIER1_ONLY" = "no" ] && [ ${#PRODUCT_TIER2[@]} -gt 0 ]; then
  for artifact in "${PRODUCT_TIER2[@]}"; do
    [ -z "$artifact" ] && continue
    if ! path="$(get_tier2_path "$artifact")"; then
      echo "ERROR: manifest references unknown Tier 2 artifact: $artifact" >&2
      echo "  (Add a case to get_tier2_path() in sync-to-project.sh)" >&2
      exit 3
    fi
    if [ ! -f "$path" ]; then
      echo "ERROR: Tier 2 artifact file missing: $path" >&2
      exit 4
    fi
  done
fi

# ─────────────────────────────────────────────────────────────────
# Tracking arrays for the sync report
# ─────────────────────────────────────────────────────────────────

FILES_ADDED=()
FILES_MODIFIED=()
FILES_PRESERVED=()
FILES_SKIPPED=()
ANOMALIES=()
NEXT_ACTIONS=()

# ─────────────────────────────────────────────────────────────────
# Helper functions
# ─────────────────────────────────────────────────────────────────

write_file() {
  dst="$1"
  content="$2"
  if [ "$DRY_RUN" = "yes" ]; then
    echo "  [dry-run] would write: $dst (${#content} chars)"
    return 0
  fi
  printf '%s\n' "$content" > "$dst"
}

copy_file() {
  src="$1"
  dst="$2"
  if [ "$DRY_RUN" = "yes" ]; then
    echo "  [dry-run] would copy: $src -> $dst"
    return 0
  fi
  cp "$src" "$dst"
}

make_dir() {
  dir="$1"
  if [ "$DRY_RUN" = "yes" ]; then
    [ -d "$dir" ] || echo "  [dry-run] would create dir: $dir"
    return 0
  fi
  mkdir -p "$dir"
}

touch_file() {
  file="$1"
  if [ "$DRY_RUN" = "yes" ]; then
    [ -f "$file" ] || echo "  [dry-run] would touch: $file"
    return 0
  fi
  touch "$file"
}

backup_file() {
  file="$1"
  backup="${file}.pre-eos-sync-${TODAY}"
  if [ -f "$file" ]; then
    counter=1
    while [ -f "$backup" ]; do
      backup="${file}.pre-eos-sync-${TODAY}.${counter}"
      counter=$((counter + 1))
    done
    if [ "$DRY_RUN" = "no" ]; then
      cp "$file" "$backup"
    fi
    echo "$backup"
  fi
}

# ─────────────────────────────────────────────────────────────────
# Extract sections from template
# ─────────────────────────────────────────────────────────────────

HQ_SECTION="$(awk '
  /^# HQ STANDARDS$/ { capture=1; print; next }
  /^# PROJECT-SPECIFIC$/ { capture=0 }
  capture { print }
' "$TEMPLATE_FILE")"

TEMPLATE_PROJECT_SECTION="$(awk '
  /^# PROJECT-SPECIFIC$/ { capture=1 }
  capture { print }
' "$TEMPLATE_FILE")"

if [ -z "$HQ_SECTION" ]; then
  echo "ERROR: could not extract HQ STANDARDS section from template" >&2
  exit 4
fi

# ─────────────────────────────────────────────────────────────────
# Step 1 — Sync CLAUDE.md
# ─────────────────────────────────────────────────────────────────

echo "[1/5] Syncing CLAUDE.md..."

TARGET_CLAUDE="$TARGET/CLAUDE.md"

CLAUDE_HEADER="# CLAUDE.md — ${PRODUCT_NAME}

> **Synced from:** rore-tech-hq @ ${HQ_SHA} on ${TODAY}
> Do not edit the HQ STANDARDS section in this product project.
> Updates flow from HQ at phase kickoff or critical push.
"

if [ ! -f "$TARGET_CLAUDE" ]; then
  echo "  No existing CLAUDE.md. Creating from template."

  NEW_CONTENT="${CLAUDE_HEADER}
${HQ_SECTION}

${TEMPLATE_PROJECT_SECTION}"

  write_file "$TARGET_CLAUDE" "$NEW_CONTENT"
  FILES_ADDED+=("CLAUDE.md")
  ANOMALIES+=("CLAUDE.md created fresh — fill in PROJECT-SPECIFIC sections P1–P10")
  NEXT_ACTIONS+=("Open CLAUDE.md, fill in P1–P10 with actual product specifics, then commit")

else
  HAS_PROJECT_MARKER="no"
  if grep -qE "$PROJECT_SPECIFIC_MARKER" "$TARGET_CLAUDE"; then
    HAS_PROJECT_MARKER="yes"
  fi

  if [ "$HAS_PROJECT_MARKER" = "no" ]; then
    PROPOSAL="$TARGET/CLAUDE.md.proposed"
    ORIGINAL_CONTENT="$(cat "$TARGET_CLAUDE")"

    PROPOSAL_CONTENT="# CLAUDE.md — ${PRODUCT_NAME}

> **Synced from:** rore-tech-hq @ ${HQ_SHA} on ${TODAY}
> **Status:** PROPOSAL — manual merge required.
>
> The existing CLAUDE.md does not yet have the sectioned format.
> Review this file and merge your project-specific content into the
> PROJECT-SPECIFIC section below, then rename this file to CLAUDE.md.
> The original CLAUDE.md is preserved unchanged.

${HQ_SECTION}

${TEMPLATE_PROJECT_SECTION}

---

# === ORIGINAL CLAUDE.md CONTENT (FOR REFERENCE) ===
# Merge product-specific content from below into PROJECT-SPECIFIC
# sections P1–P10 above, then delete this section.

${ORIGINAL_CONTENT}"

    write_file "$PROPOSAL" "$PROPOSAL_CONTENT"
    FILES_ADDED+=("CLAUDE.md.proposed")
    FILES_PRESERVED+=("CLAUDE.md (unchanged — proposal written to CLAUDE.md.proposed)")
    ANOMALIES+=("PROJECT-SPECIFIC marker not found in existing CLAUDE.md. Wrote CLAUDE.md.proposed for manual merge. Original CLAUDE.md preserved.")
    NEXT_ACTIONS+=("Manually merge CLAUDE.md.proposed into a new CLAUDE.md, then rerun sync to verify idempotency")

    echo "  ANOMALY: existing CLAUDE.md lacks sectioned format. Wrote CLAUDE.md.proposed."

  else
    PROJECT_SECTION="$(awk '
      /^# PROJECT-SPECIFIC$/ { capture=1 }
      capture { print }
    ' "$TARGET_CLAUDE")"

    if [ -z "$PROJECT_SECTION" ]; then
      echo "ERROR: PROJECT-SPECIFIC marker found but extraction returned empty" >&2
      exit 4
    fi

    NEW_CONTENT="${CLAUDE_HEADER}
${HQ_SECTION}

${PROJECT_SECTION}"

    EXISTING_CONTENT="$(cat "$TARGET_CLAUDE")"
    if [ "$EXISTING_CONTENT" = "$NEW_CONTENT" ]; then
      echo "  CLAUDE.md unchanged (idempotent — no diff)."
      FILES_PRESERVED+=("CLAUDE.md (no change needed)")
    else
      BACKUP="$(backup_file "$TARGET_CLAUDE")"
      write_file "$TARGET_CLAUDE" "$NEW_CONTENT"
      FILES_MODIFIED+=("CLAUDE.md (backup: $(basename "$BACKUP"))")
      FILES_PRESERVED+=("PROJECT-SPECIFIC section of CLAUDE.md (verbatim)")
    fi
  fi
fi

# ─────────────────────────────────────────────────────────────────
# Step 2 — Sync ROUNDTABLE.md
# ─────────────────────────────────────────────────────────────────

echo "[2/5] Syncing ROUNDTABLE.md..."

TARGET_ROUNDTABLE="$TARGET/ROUNDTABLE.md"
if [ -f "$TARGET_ROUNDTABLE" ]; then
  if cmp -s "$ROUNDTABLE_FILE" "$TARGET_ROUNDTABLE"; then
    echo "  ROUNDTABLE.md unchanged."
    FILES_PRESERVED+=("ROUNDTABLE.md (no change needed)")
  else
    BACKUP="$(backup_file "$TARGET_ROUNDTABLE")"
    copy_file "$ROUNDTABLE_FILE" "$TARGET_ROUNDTABLE"
    FILES_MODIFIED+=("ROUNDTABLE.md (backup: $(basename "$BACKUP"))")
  fi
else
  copy_file "$ROUNDTABLE_FILE" "$TARGET_ROUNDTABLE"
  FILES_ADDED+=("ROUNDTABLE.md")
fi

# ─────────────────────────────────────────────────────────────────
# Step 3 — Sync Tier 1 templates (in docs/templates/)
# ─────────────────────────────────────────────────────────────────

echo "[3/5] Syncing Tier 1 templates..."

TARGET_TEMPLATES="$TARGET/docs/templates"
make_dir "$TARGET_TEMPLATES"

sync_template() {
  src="$1"
  name="$2"
  dst="$TARGET_TEMPLATES/$name"

  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    FILES_PRESERVED+=("docs/templates/$name (no change needed)")
    return
  fi

  if [ -f "$dst" ]; then
    BACKUP="$(backup_file "$dst")"
    copy_file "$src" "$dst"
    FILES_MODIFIED+=("docs/templates/$name (backup: $(basename "$BACKUP"))")
  else
    copy_file "$src" "$dst"
    FILES_ADDED+=("docs/templates/$name")
  fi
}

sync_template "$PHASE_PROTOCOL_TEMPLATE" "PHASE_PROTOCOL_TEMPLATE.md"
sync_template "$ADR_TEMPLATE" "ADR_TEMPLATE.md"
sync_template "$BUG_REPORT_PROMPT" "BUG_REPORT_PROMPT.md"

make_dir "$TARGET/docs/protocols"
make_dir "$TARGET/docs/decisions"

# ─────────────────────────────────────────────────────────────────
# Step 4 — Sync Tier 2 artifacts (per manifest)
# ─────────────────────────────────────────────────────────────────

echo "[4/5] Syncing Tier 2 artifacts..."

if [ "$TIER1_ONLY" = "yes" ]; then
  echo "  Skipped (--tier1-only)."
  if [ ${#PRODUCT_TIER2[@]} -gt 0 ]; then
    for artifact in "${PRODUCT_TIER2[@]}"; do
      [ -z "$artifact" ] && continue
      FILES_SKIPPED+=("$artifact (--tier1-only set; defer to next sync)")
    done
    NEXT_ACTIONS+=("Re-run without --tier1-only at next phase kickoff to pull in Tier 2 checklists")
  fi
else
  TARGET_STANDARDS="$TARGET/docs/standards"
  make_dir "$TARGET_STANDARDS"

  if [ ${#PRODUCT_TIER2[@]} -eq 0 ] || [ -z "${PRODUCT_TIER2[0]:-}" ]; then
    echo "  No Tier 2 artifacts declared in manifest for $PRODUCT_KEY."
  else
    for artifact in "${PRODUCT_TIER2[@]}"; do
      [ -z "$artifact" ] && continue
      src="$(get_tier2_path "$artifact")"
      name="$(basename "$src")"
      dst="$TARGET_STANDARDS/$name"

      SYNC_HEADER="> **Synced from:** rore-tech-hq @ ${HQ_SHA} on ${TODAY}
> Do not edit in this product. Updates flow from HQ.
"
      SRC_CONTENT="$(cat "$src")"
      SYNCED_CONTENT="${SYNC_HEADER}
${SRC_CONTENT}"

      if [ -f "$dst" ]; then
        EXISTING="$(cat "$dst")"
        if [ "$EXISTING" = "$SYNCED_CONTENT" ]; then
          FILES_PRESERVED+=("docs/standards/$name (no change needed)")
          continue
        fi
        BACKUP="$(backup_file "$dst")"
        write_file "$dst" "$SYNCED_CONTENT"
        FILES_MODIFIED+=("docs/standards/$name (backup: $(basename "$BACKUP"))")
      else
        write_file "$dst" "$SYNCED_CONTENT"
        FILES_ADDED+=("docs/standards/$name")
      fi
    done
  fi
fi

if [ "$PRODUCT_SURVEILLANCE" = "yes" ] && [ "$TIER1_ONLY" = "no" ]; then
  AUDIT_DIR="$TARGET/.audit"
  MARKER="$AUDIT_DIR/SURVEILLANCE_ADJACENT"
  if [ ! -f "$MARKER" ]; then
    make_dir "$AUDIT_DIR"
    touch_file "$MARKER"
    FILES_ADDED+=(".audit/SURVEILLANCE_ADJACENT (opts in to stalkerware-pattern audit)")
  else
    FILES_PRESERVED+=(".audit/SURVEILLANCE_ADJACENT (already present)")
  fi
fi

# ─────────────────────────────────────────────────────────────────
# Step 5 — Update PROJECT_REGISTRY.md at HQ
# ─────────────────────────────────────────────────────────────────

echo "[5/5] Updating PROJECT_REGISTRY.md at HQ..."

if [ ! -f "$REGISTRY_FILE" ]; then
  ANOMALIES+=("PROJECT_REGISTRY.md not found at $REGISTRY_FILE. Skipping registry update.")
else
  TIER2_LIST=""
  if [ ${#PRODUCT_TIER2[@]} -gt 0 ] && [ -n "${PRODUCT_TIER2[0]:-}" ]; then
    for artifact in "${PRODUCT_TIER2[@]}"; do
      [ -z "$artifact" ] && continue
      if [ -z "$TIER2_LIST" ]; then
        TIER2_LIST="$artifact"
      else
        TIER2_LIST="${TIER2_LIST},${artifact}"
      fi
    done
  fi
  [ -z "$TIER2_LIST" ] && TIER2_LIST="(none)"

  if [ "$TIER1_ONLY" = "yes" ]; then
    TIER2_STATUS="Tier 1 only"
  else
    TIER2_STATUS="Tier 1 + Tier 2"
  fi

  NEW_ROW="| $PRODUCT_NAME | $PRODUCT_KEY | $TIER2_STATUS | $HQ_SHA | $TODAY | $TIER2_LIST |"

  if [ "$DRY_RUN" = "yes" ]; then
    echo "  [dry-run] would update PROJECT_REGISTRY.md with row: $NEW_ROW"
  else
    if grep -qE "^\| ${PRODUCT_NAME} \|" "$REGISTRY_FILE" 2>/dev/null; then
      TMP="$(mktemp)"
      awk -v product="$PRODUCT_NAME" -v new_row="$NEW_ROW" '
        $0 ~ "^\\| " product " \\|" { print new_row; next }
        { print }
      ' "$REGISTRY_FILE" > "$TMP"
      mv "$TMP" "$REGISTRY_FILE"
    else
      if grep -q "SYNC_ROWS_END" "$REGISTRY_FILE"; then
        TMP="$(mktemp)"
        awk -v new_row="$NEW_ROW" '
          /SYNC_ROWS_END/ { print new_row; print; next }
          { print }
        ' "$REGISTRY_FILE" > "$TMP"
        mv "$TMP" "$REGISTRY_FILE"
      else
        echo "$NEW_ROW" >> "$REGISTRY_FILE"
      fi
    fi
  fi
fi

# ─────────────────────────────────────────────────────────────────
# Write SYNC_REPORT.md to target project
# ─────────────────────────────────────────────────────────────────

echo ""
echo "Writing SYNC_REPORT.md..."

REPORT="$TARGET/SYNC_REPORT.md"

# Render a tracking array as a markdown bullet list, or "(none)" if empty.
# Takes the array name as argument; uses eval for indirect expansion
# (POSIX-compatible alternative to namerefs which are bash 4.3+).
render_list() {
  arr_name="$1"
  eval "items=( \"\${${arr_name}[@]:-}\" )"
  out=""
  if [ ${#items[@]} -eq 0 ] || [ -z "${items[0]:-}" ]; then
    echo "(none)"
    return
  fi
  for item in "${items[@]}"; do
    [ -z "$item" ] && continue
    if [ -z "$out" ]; then
      out="- $item"
    else
      out="${out}
- $item"
    fi
  done
  echo "$out"
}

ADDED_LIST="$(render_list FILES_ADDED)"
MODIFIED_LIST="$(render_list FILES_MODIFIED)"
PRESERVED_LIST="$(render_list FILES_PRESERVED)"
SKIPPED_LIST="$(render_list FILES_SKIPPED)"
ANOMALIES_LIST="$(render_list ANOMALIES)"
NEXT_ACTIONS_LIST="$(render_list NEXT_ACTIONS)"

REPORT_CONTENT="# SYNC_REPORT — ${PRODUCT_NAME}

> Auto-generated by \`rore-tech-hq/eos/sync/sync-to-project.sh\`. Each
> sync overwrites this file. Prior sync history is in git log of the
> HQ repo's PROJECT_REGISTRY.md.

## Header

| Field | Value |
|---|---|
| Product | ${PRODUCT_NAME} |
| Product key | ${PRODUCT_KEY} |
| Sync date | ${TODAY} |
| Sync time | ${NOW} |
| HQ commit (short) | ${HQ_SHA} |
| HQ commit (full) | ${HQ_SHA_FULL} |
| Tier1-only mode | ${TIER1_ONLY} |
| Dry run | ${DRY_RUN} |

## Files added

${ADDED_LIST}

## Files modified

${MODIFIED_LIST}

## Files preserved (no changes needed, or PROJECT-SPECIFIC content kept verbatim)

${PRESERVED_LIST}

## Files skipped

${SKIPPED_LIST}

## Anomalies

${ANOMALIES_LIST}

## Next actions

${NEXT_ACTIONS_LIST}

---

*Per-sync paper trail. When you want to know \"when did we adopt EOS
vX.Y on this project?\", read the chain of these reports in git
history.*"

write_file "$REPORT" "$REPORT_CONTENT"

# ─────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────

echo ""
echo "─────────────────────────────────────────────────────────"
echo " Sync complete"
echo "─────────────────────────────────────────────────────────"
echo " Files added:     ${#FILES_ADDED[@]}"
echo " Files modified:  ${#FILES_MODIFIED[@]}"
echo " Files preserved: ${#FILES_PRESERVED[@]}"
echo " Files skipped:   ${#FILES_SKIPPED[@]}"
echo " Anomalies:       ${#ANOMALIES[@]}"
echo ""

if [ ${#ANOMALIES[@]} -gt 0 ] && [ -n "${ANOMALIES[0]:-}" ]; then
  echo " ⚠  ANOMALIES requiring attention:"
  for a in "${ANOMALIES[@]}"; do
    [ -z "$a" ] && continue
    echo "    - $a"
  done
  echo ""
fi

if [ "$DRY_RUN" = "yes" ]; then
  echo " (dry-run — no files modified)"
  echo ""
fi

echo " Review with:"
echo "   cd $TARGET"
echo "   git status"
echo "   git diff"
echo "   cat SYNC_REPORT.md"
echo ""
echo " Then commit manually if approved."
echo "─────────────────────────────────────────────────────────"

for a in "${ANOMALIES[@]}"; do
  [ -z "$a" ] && continue
  case "$a" in
    *"CLAUDE.md.proposed"*) exit 2 ;;
  esac
done

exit 0
