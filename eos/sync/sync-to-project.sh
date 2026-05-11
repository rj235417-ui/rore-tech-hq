#!/bin/bash
# rore-tech-hq/eos/sync/sync-to-project.sh
#
# Syncs HQ STANDARDS and manifest-declared Tier 2 artifacts from
# rore-tech-hq into a target product project repo.
#
# USAGE:
#   ./sync-to-project.sh [--tier1-only] [--product KEY] <target-path>
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
#   - Never runs git commands.
#   - Backs up CLAUDE.md to CLAUDE.md.pre-eos-sync-YYYY-MM-DD before
#     modifying.
#   - Idempotent: running twice produces zero diff on second run.

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

# Markers that separate the two sections of CLAUDE.md
HQ_STANDARDS_MARKER="^# HQ STANDARDS"
PROJECT_SPECIFIC_MARKER="^# PROJECT-SPECIFIC"

# Today's date in ISO format
TODAY="$(date +%Y-%m-%d)"
NOW="$(date +%Y-%m-%dT%H:%M:%S%z)"

# HQ commit SHA — if HQ is a git repo, capture current HEAD
if (cd "$HQ_ROOT" && git rev-parse --git-dir >/dev/null 2>&1); then
  HQ_SHA="$(cd "$HQ_ROOT" && git rev-parse --short HEAD)"
  HQ_SHA_FULL="$(cd "$HQ_ROOT" && git rev-parse HEAD)"
else
  HQ_SHA="not-in-git"
  HQ_SHA_FULL="not-in-git"
fi

# ─────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────

TIER1_ONLY="no"
PRODUCT_KEY=""
DRY_RUN="no"
TARGET=""

while [[ $# -gt 0 ]]; do
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
      sed -n '3,30p' "$0"
      exit 0
      ;;
    *)
      if [[ -z "$TARGET" ]]; then
        TARGET="$1"
      else
        echo "ERROR: unexpected argument: $1" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "ERROR: target project path required" >&2
  echo "Usage: $0 [--tier1-only] [--product KEY] [--dry-run] <target-path>" >&2
  exit 1
fi

# Resolve target to absolute path
if [[ ! -d "$TARGET" ]]; then
  echo "ERROR: target path does not exist or is not a directory: $TARGET" >&2
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

# ─────────────────────────────────────────────────────────────────
# Load manifest
# ─────────────────────────────────────────────────────────────────

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "ERROR: manifest not found at $MANIFEST_FILE" >&2
  exit 3
fi

# shellcheck source=/dev/null
source "$MANIFEST_FILE"

# ─────────────────────────────────────────────────────────────────
# Determine product key (from flag, or auto-detect from path)
# ─────────────────────────────────────────────────────────────────

if [[ -z "$PRODUCT_KEY" ]]; then
  # Auto-detect: search the path against PATH_HINT_* values
  target_lower="$(echo "$TARGET" | tr '[:upper:]' '[:lower:]')"
  for key in "${KNOWN_PRODUCTS[@]}"; do
    hint_var="PATH_HINT_${key}"
    hints="${!hint_var:-}"
    for hint in $hints; do
      if [[ "$target_lower" == *"$hint"* ]]; then
        PRODUCT_KEY="$key"
        break 2
      fi
    done
  done
fi

if [[ -z "$PRODUCT_KEY" ]]; then
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
  if [[ "$key" == "$PRODUCT_KEY" ]]; then
    known="yes"
    break
  fi
done
if [[ "$known" == "no" ]]; then
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

# Verify HQ artifacts exist
required_files=(
  "$TEMPLATE_FILE"
  "$ROUNDTABLE_FILE"
  "$PHASE_PROTOCOL_TEMPLATE"
  "$ADR_TEMPLATE"
  "$BUG_REPORT_PROMPT"
)
for f in "${required_files[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: required HQ artifact missing: $f" >&2
    exit 4
  fi
done

# Verify Tier 2 artifacts exist (only if we're syncing them)
declare -A TIER2_PATHS
TIER2_PATHS["FIREBASE_FLUTTER_SETUP"]="$HQ_ROOT/eos/checklists/FIREBASE_FLUTTER_SETUP.md"
TIER2_PATHS["PLAY_STORE_SUBMISSION"]="$HQ_ROOT/eos/checklists/PLAY_STORE_SUBMISSION.md"
TIER2_PATHS["EXTERNAL_DATA_IMPORTER"]="$HQ_ROOT/eos/checklists/EXTERNAL_DATA_IMPORTER.md"
TIER2_PATHS["AI_PUBLISHING_PIPELINE"]="$HQ_ROOT/eos/checklists/AI_PUBLISHING_PIPELINE.md"
TIER2_PATHS["SIGNING_KEY_BIRTH_CERTIFICATE"]="$HQ_ROOT/eos/checklists/SIGNING_KEY_BIRTH_CERTIFICATE.md"
TIER2_PATHS["DEPLOYMENT_CHECKLISTS"]="$HQ_ROOT/eos/checklists/DEPLOYMENT_CHECKLISTS.md"
TIER2_PATHS["LAUNCH_PLAN_TEMPLATE"]="$HQ_ROOT/eos/templates/LAUNCH_PLAN_TEMPLATE.md"
TIER2_PATHS["SEO_TRIAGE"]="$HQ_ROOT/eos/runbooks/SEO_TRIAGE.md"

if [[ "$TIER1_ONLY" == "no" ]] && [[ ${#PRODUCT_TIER2[@]} -gt 0 ]]; then
  for artifact in "${PRODUCT_TIER2[@]}"; do
    [[ -z "$artifact" ]] && continue
    path="${TIER2_PATHS[$artifact]:-}"
    if [[ -z "$path" ]]; then
      echo "ERROR: manifest references unknown Tier 2 artifact: $artifact" >&2
      exit 3
    fi
    if [[ ! -f "$path" ]]; then
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

# Helper: do an action unless dry-run
do_action() {
  if [[ "$DRY_RUN" == "yes" ]]; then
    echo "  [dry-run] would: $*"
  else
    eval "$@"
  fi
}

# Helper: backup a file before modifying
backup_file() {
  local file="$1"
  local backup="${file}.pre-eos-sync-${TODAY}"
  if [[ -f "$file" ]]; then
    # Don't overwrite an existing backup from today
    local counter=1
    while [[ -f "$backup" ]]; do
      backup="${file}.pre-eos-sync-${TODAY}.${counter}"
      counter=$((counter + 1))
    done
    do_action "cp \"$file\" \"$backup\""
    echo "$backup"
  fi
}

# ─────────────────────────────────────────────────────────────────
# Step 1 — Sync CLAUDE.md
# ─────────────────────────────────────────────────────────────────

echo "[1/5] Syncing CLAUDE.md..."

TARGET_CLAUDE="$TARGET/CLAUDE.md"
TEMPLATE_CONTENT="$(cat "$TEMPLATE_FILE")"

# Extract HQ STANDARDS section from template (between # HQ STANDARDS and # PROJECT-SPECIFIC)
HQ_SECTION="$(awk '
  /^# HQ STANDARDS$/ { capture=1; print; next }
  /^# PROJECT-SPECIFIC$/ { capture=0 }
  capture { print }
' "$TEMPLATE_FILE")"

# Extract PROJECT-SPECIFIC section structure from template (the empty version)
TEMPLATE_PROJECT_SECTION="$(awk '
  /^# PROJECT-SPECIFIC$/ { capture=1 }
  capture { print }
' "$TEMPLATE_FILE")"

if [[ -z "$HQ_SECTION" ]]; then
  echo "ERROR: could not extract HQ STANDARDS section from template" >&2
  exit 4
fi

if [[ ! -f "$TARGET_CLAUDE" ]]; then
  # No existing CLAUDE.md — create fresh from template
  echo "  No existing CLAUDE.md. Creating from template."

  NEW_CLAUDE="$(cat <<EOF
# CLAUDE.md — $PRODUCT_NAME

> **Synced from:** rore-tech-hq @ $HQ_SHA on $TODAY
> Do not edit the HQ STANDARDS section in this product project.
> Updates flow from HQ at phase kickoff or critical push.

$HQ_SECTION

$TEMPLATE_PROJECT_SECTION
EOF
)"
  do_action "cat > \"$TARGET_CLAUDE\" <<'EOS_CLAUDE_END'
$NEW_CLAUDE
EOS_CLAUDE_END"
  FILES_ADDED+=("CLAUDE.md")
  ANOMALIES+=("CLAUDE.md created fresh — fill in PROJECT-SPECIFIC sections P1–P10")
  NEXT_ACTIONS+=("Open CLAUDE.md, fill in P1–P10 with actual product specifics, then commit")

else
  # CLAUDE.md exists. Check for sectioned format.
  HAS_HQ_MARKER="no"
  HAS_PROJECT_MARKER="no"
  if grep -qE "$HQ_STANDARDS_MARKER" "$TARGET_CLAUDE"; then
    HAS_HQ_MARKER="yes"
  fi
  if grep -qE "$PROJECT_SPECIFIC_MARKER" "$TARGET_CLAUDE"; then
    HAS_PROJECT_MARKER="yes"
  fi

  if [[ "$HAS_PROJECT_MARKER" == "no" ]]; then
    # First sync — existing CLAUDE.md doesn't have sectioned format.
    # Write a proposal instead of overwriting.
    PROPOSAL="$TARGET/CLAUDE.md.proposed"

    PROPOSAL_CONTENT="$(cat <<EOF
# CLAUDE.md — $PRODUCT_NAME

> **Synced from:** rore-tech-hq @ $HQ_SHA on $TODAY
> **Status:** PROPOSAL — manual merge required.
>
> The existing CLAUDE.md does not yet have the sectioned format.
> Review this file and merge your project-specific content into the
> PROJECT-SPECIFIC section below, then rename this file to CLAUDE.md.
> The original CLAUDE.md is preserved unchanged.

$HQ_SECTION

$TEMPLATE_PROJECT_SECTION

---

# === ORIGINAL CLAUDE.md CONTENT (FOR REFERENCE) ===
# Merge product-specific content from below into PROJECT-SPECIFIC
# sections P1–P10 above, then delete this section.

$(cat "$TARGET_CLAUDE")
EOF
)"
    do_action "cat > \"$PROPOSAL\" <<'EOS_PROPOSAL_END'
$PROPOSAL_CONTENT
EOS_PROPOSAL_END"
    FILES_ADDED+=("CLAUDE.md.proposed")
    FILES_PRESERVED+=("CLAUDE.md (unchanged — proposal written to CLAUDE.md.proposed)")
    ANOMALIES+=("PROJECT-SPECIFIC marker not found in existing CLAUDE.md. Wrote CLAUDE.md.proposed for manual merge. Original CLAUDE.md preserved.")
    NEXT_ACTIONS+=("Manually merge CLAUDE.md.proposed into a new CLAUDE.md, then rerun sync to verify idempotency")

    echo "  ANOMALY: existing CLAUDE.md lacks sectioned format. Wrote CLAUDE.md.proposed."

  else
    # Sectioned format exists. Extract PROJECT-SPECIFIC section verbatim
    # and rebuild CLAUDE.md with new HQ STANDARDS + preserved PROJECT-SPECIFIC.
    PROJECT_SECTION="$(awk '
      /^# PROJECT-SPECIFIC$/ { capture=1 }
      capture { print }
    ' "$TARGET_CLAUDE")"

    if [[ -z "$PROJECT_SECTION" ]]; then
      echo "ERROR: PROJECT-SPECIFIC marker found but extraction returned empty" >&2
      exit 4
    fi

    # Compose new CLAUDE.md
    NEW_CLAUDE="$(cat <<EOF
# CLAUDE.md — $PRODUCT_NAME

> **Synced from:** rore-tech-hq @ $HQ_SHA on $TODAY
> Do not edit the HQ STANDARDS section in this product project.
> Updates flow from HQ at phase kickoff or critical push.

$HQ_SECTION

$PROJECT_SECTION
EOF
)"

    # Check if content would actually change (idempotency)
    EXISTING_NORMALIZED="$(cat "$TARGET_CLAUDE")"
    if [[ "$EXISTING_NORMALIZED" == "$NEW_CLAUDE" ]]; then
      echo "  CLAUDE.md unchanged (idempotent — no diff)."
      FILES_PRESERVED+=("CLAUDE.md (no change needed)")
    else
      # Back up and rewrite
      BACKUP="$(backup_file "$TARGET_CLAUDE")"
      do_action "cat > \"$TARGET_CLAUDE\" <<'EOS_CLAUDE_END'
$NEW_CLAUDE
EOS_CLAUDE_END"
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
if [[ -f "$TARGET_ROUNDTABLE" ]]; then
  if cmp -s "$ROUNDTABLE_FILE" "$TARGET_ROUNDTABLE"; then
    echo "  ROUNDTABLE.md unchanged."
    FILES_PRESERVED+=("ROUNDTABLE.md (no change needed)")
  else
    BACKUP="$(backup_file "$TARGET_ROUNDTABLE")"
    do_action "cp \"$ROUNDTABLE_FILE\" \"$TARGET_ROUNDTABLE\""
    FILES_MODIFIED+=("ROUNDTABLE.md (backup: $(basename "$BACKUP"))")
  fi
else
  do_action "cp \"$ROUNDTABLE_FILE\" \"$TARGET_ROUNDTABLE\""
  FILES_ADDED+=("ROUNDTABLE.md")
fi

# ─────────────────────────────────────────────────────────────────
# Step 3 — Sync Tier 1 templates (in docs/templates/)
# ─────────────────────────────────────────────────────────────────

echo "[3/5] Syncing Tier 1 templates..."

TARGET_TEMPLATES="$TARGET/docs/templates"
do_action "mkdir -p \"$TARGET_TEMPLATES\""

sync_template() {
  local src="$1"
  local name="$2"
  local dst="$TARGET_TEMPLATES/$name"

  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    FILES_PRESERVED+=("docs/templates/$name (no change needed)")
    return
  fi

  if [[ -f "$dst" ]]; then
    BACKUP="$(backup_file "$dst")"
    do_action "cp \"$src\" \"$dst\""
    FILES_MODIFIED+=("docs/templates/$name (backup: $(basename "$BACKUP"))")
  else
    do_action "cp \"$src\" \"$dst\""
    FILES_ADDED+=("docs/templates/$name")
  fi
}

sync_template "$PHASE_PROTOCOL_TEMPLATE" "PHASE_PROTOCOL_TEMPLATE.md"
sync_template "$ADR_TEMPLATE" "ADR_TEMPLATE.md"
sync_template "$BUG_REPORT_PROMPT" "BUG_REPORT_PROMPT.md"

# Ensure docs/protocols and docs/decisions exist
do_action "mkdir -p \"$TARGET/docs/protocols\""
do_action "mkdir -p \"$TARGET/docs/decisions\""

# ─────────────────────────────────────────────────────────────────
# Step 4 — Sync Tier 2 artifacts (per manifest)
# ─────────────────────────────────────────────────────────────────

echo "[4/5] Syncing Tier 2 artifacts..."

if [[ "$TIER1_ONLY" == "yes" ]]; then
  echo "  Skipped (--tier1-only)."
  if [[ ${#PRODUCT_TIER2[@]} -gt 0 ]]; then
    for artifact in "${PRODUCT_TIER2[@]}"; do
      [[ -z "$artifact" ]] && continue
      FILES_SKIPPED+=("$artifact (--tier1-only set; defer to next sync)")
    done
    NEXT_ACTIONS+=("Re-run without --tier1-only at next phase kickoff to pull in Tier 2 checklists")
  fi
else
  TARGET_STANDARDS="$TARGET/docs/standards"
  do_action "mkdir -p \"$TARGET_STANDARDS\""

  if [[ ${#PRODUCT_TIER2[@]} -eq 0 ]] || [[ -z "${PRODUCT_TIER2[0]:-}" ]]; then
    echo "  No Tier 2 artifacts declared in manifest for $PRODUCT_KEY."
  else
    for artifact in "${PRODUCT_TIER2[@]}"; do
      [[ -z "$artifact" ]] && continue
      src="${TIER2_PATHS[$artifact]}"
      name="$(basename "$src")"
      dst="$TARGET_STANDARDS/$name"

      # Build the synced-version with header
      SYNCED_CONTENT="$(cat <<EOF
> **Synced from:** rore-tech-hq @ $HQ_SHA on $TODAY
> Do not edit in this product. Updates flow from HQ.

$(cat "$src")
EOF
)"

      if [[ -f "$dst" ]]; then
        EXISTING="$(cat "$dst")"
        if [[ "$EXISTING" == "$SYNCED_CONTENT" ]]; then
          FILES_PRESERVED+=("docs/standards/$name (no change needed)")
          continue
        fi
        BACKUP="$(backup_file "$dst")"
        do_action "cat > \"$dst\" <<'EOS_SYNCED_END'
$SYNCED_CONTENT
EOS_SYNCED_END"
        FILES_MODIFIED+=("docs/standards/$name (backup: $(basename "$BACKUP"))")
      else
        do_action "cat > \"$dst\" <<'EOS_SYNCED_END'
$SYNCED_CONTENT
EOS_SYNCED_END"
        FILES_ADDED+=("docs/standards/$name")
      fi
    done
  fi
fi

# Surveillance-adjacent marker (if applicable)
if [[ "$PRODUCT_SURVEILLANCE" == "yes" ]] && [[ "$TIER1_ONLY" == "no" ]]; then
  AUDIT_DIR="$TARGET/.audit"
  MARKER="$AUDIT_DIR/SURVEILLANCE_ADJACENT"
  if [[ ! -f "$MARKER" ]]; then
    do_action "mkdir -p \"$AUDIT_DIR\""
    do_action "touch \"$MARKER\""
    FILES_ADDED+=(".audit/SURVEILLANCE_ADJACENT (opts in to stalkerware-pattern audit)")
  else
    FILES_PRESERVED+=(".audit/SURVEILLANCE_ADJACENT (already present)")
  fi
fi

# ─────────────────────────────────────────────────────────────────
# Step 5 — Update PROJECT_REGISTRY.md at HQ
# ─────────────────────────────────────────────────────────────────

echo "[5/5] Updating PROJECT_REGISTRY.md at HQ..."

if [[ ! -f "$REGISTRY_FILE" ]]; then
  ANOMALIES+=("PROJECT_REGISTRY.md not found at $REGISTRY_FILE. Skipping registry update.")
else
  # Build the new row for this product
  TIER2_LIST="$(IFS=', '; echo "${PRODUCT_TIER2[*]:-}")"
  [[ -z "$TIER2_LIST" ]] && TIER2_LIST="(none)"
  TIER2_STATUS="$([[ "$TIER1_ONLY" == "yes" ]] && echo "Tier 1 only" || echo "Tier 1 + Tier 2")"

  NEW_ROW="| $PRODUCT_NAME | $PRODUCT_KEY | $TIER2_STATUS | $HQ_SHA | $TODAY | $TIER2_LIST |"

  # Idempotency: if a row for this product already exists with same SHA and date,
  # don't add a duplicate.
  if grep -qE "^\| ${PRODUCT_NAME} \|" "$REGISTRY_FILE" 2>/dev/null; then
    # Update existing row
    if [[ "$DRY_RUN" == "yes" ]]; then
      echo "  [dry-run] would: update existing row for $PRODUCT_NAME in PROJECT_REGISTRY.md"
    else
      TMP="$(mktemp)"
      awk -v product="$PRODUCT_NAME" -v new_row="$NEW_ROW" '
        $0 ~ "^\\| " product " \\|" { print new_row; next }
        { print }
      ' "$REGISTRY_FILE" > "$TMP"
      mv "$TMP" "$REGISTRY_FILE"
    fi
  else
    # Append new row before the closing marker, or at end if no marker
    if [[ "$DRY_RUN" == "yes" ]]; then
      echo "  [dry-run] would: append new row for $PRODUCT_NAME to PROJECT_REGISTRY.md"
    else
      # Find the line "<!-- SYNC_ROWS_END -->" or append at end
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

# Build the report content
build_list() {
  local arr_name="$1[@]"
  local items=("${!arr_name:-}")
  if [[ ${#items[@]} -eq 0 ]] || [[ -z "${items[0]:-}" ]]; then
    echo "(none)"
  else
    for item in "${items[@]}"; do
      [[ -z "$item" ]] && continue
      echo "- $item"
    done
  fi
}

REPORT_CONTENT="$(cat <<EOF
# SYNC_REPORT — $PRODUCT_NAME

> Auto-generated by \`rore-tech-hq/eos/sync/sync-to-project.sh\`. Each
> sync overwrites this file. Prior sync history is in git log of the
> HQ repo's PROJECT_REGISTRY.md.

## Header

| Field | Value |
|---|---|
| Product | $PRODUCT_NAME |
| Product key | $PRODUCT_KEY |
| Sync date | $TODAY |
| Sync time | $NOW |
| HQ commit (short) | $HQ_SHA |
| HQ commit (full) | $HQ_SHA_FULL |
| Tier1-only mode | $TIER1_ONLY |
| Dry run | $DRY_RUN |

## Files added

$(build_list FILES_ADDED)

## Files modified

$(build_list FILES_MODIFIED)

## Files preserved (no changes needed, or PROJECT-SPECIFIC content kept verbatim)

$(build_list FILES_PRESERVED)

## Files skipped

$(build_list FILES_SKIPPED)

## Anomalies

$(build_list ANOMALIES)

## Next actions

$(build_list NEXT_ACTIONS)

---

*Per-sync paper trail. When you want to know "when did we adopt EOS
vX.Y on this project?", read the chain of these reports in git
history.*
EOF
)"

if [[ "$DRY_RUN" == "yes" ]]; then
  echo "  [dry-run] would write SYNC_REPORT.md (${#REPORT_CONTENT} chars)"
else
  echo "$REPORT_CONTENT" > "$REPORT"
fi

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

if [[ ${#ANOMALIES[@]} -gt 0 ]] && [[ -n "${ANOMALIES[0]:-}" ]]; then
  echo " ⚠  ANOMALIES requiring attention:"
  for a in "${ANOMALIES[@]}"; do
    [[ -z "$a" ]] && continue
    echo "    - $a"
  done
  echo ""
fi

if [[ "$DRY_RUN" == "yes" ]]; then
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

# Anomaly exit code (2) only if we wrote a .proposed file
for a in "${ANOMALIES[@]}"; do
  [[ -z "$a" ]] && continue
  if [[ "$a" == *"CLAUDE.md.proposed"* ]]; then
    exit 2
  fi
done

exit 0
