#!/bin/bash
# audit/audit.sh
#
# The runner. Walks pattern files and sub-shell scripts and reports
# PASS/FAIL with line references.
#
# Modes:
#   ./audit/audit.sh                    # full audit (pre-submission)
#   ./audit/audit.sh --pre-commit       # fast subset (pre-commit hook)
#   ./audit/audit.sh --category <name>  # single category
#
# Returns: 0 (all PASS) or 1 (any FAIL).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# --- Configuration ---

# Categories that are part of the fast pre-commit subset
PRE_COMMIT_CATEGORIES=(
  "hardcoded-secrets"
  "debug-affordances"
)

# All categories
ALL_CATEGORIES=(
  "stalkerware-patterns"
  "deprecated-strings"
  "hardcoded-secrets"
  "debug-affordances"
)

# Sub-shell scripts (run separately from grep patterns)
SUBSCRIPTS=(
  "asset-existence.sh"
  "link-consistency.sh"
)

# Stalkerware-patterns is opt-in per product (only run for
# surveillance-adjacent products). Detected by presence of a marker
# file: .audit/SURVEILLANCE_ADJACENT
STALKERWARE_OPT_IN_FILE="$SCRIPT_DIR/SURVEILLANCE_ADJACENT"

# --- Argument parsing ---

MODE="full"
SINGLE_CATEGORY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pre-commit)
      MODE="pre-commit"
      shift
      ;;
    --category)
      MODE="single"
      SINGLE_CATEGORY="$2"
      shift 2
      ;;
    -h|--help)
      sed -n '1,15p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      exit 2
      ;;
  esac
done

# --- Determine which categories to run ---

CATEGORIES_TO_RUN=()

if [[ "$MODE" == "single" ]]; then
  CATEGORIES_TO_RUN=("$SINGLE_CATEGORY")
elif [[ "$MODE" == "pre-commit" ]]; then
  CATEGORIES_TO_RUN=("${PRE_COMMIT_CATEGORIES[@]}")
  # Add stalkerware-patterns if opted in
  if [[ -f "$STALKERWARE_OPT_IN_FILE" ]]; then
    CATEGORIES_TO_RUN+=("stalkerware-patterns")
  fi
else
  # Full audit: all categories, with stalkerware only if opted in
  for cat in "${ALL_CATEGORIES[@]}"; do
    if [[ "$cat" == "stalkerware-patterns" ]]; then
      if [[ -f "$STALKERWARE_OPT_IN_FILE" ]]; then
        CATEGORIES_TO_RUN+=("$cat")
      fi
    else
      CATEGORIES_TO_RUN+=("$cat")
    fi
  done
fi

# --- Run grep-pattern categories ---

OVERALL_EXIT=0

for category in "${CATEGORIES_TO_RUN[@]}"; do
  PATTERN_FILE="$SCRIPT_DIR/${category}.txt"
  if [[ ! -f "$PATTERN_FILE" ]]; then
    echo "[$category] SKIP — pattern file not found at $PATTERN_FILE"
    continue
  fi

  # Determine the search target
  if [[ "$MODE" == "pre-commit" ]]; then
    # Search staged diff only
    TARGET=$(git diff --cached --name-only --diff-filter=ACM)
    if [[ -z "$TARGET" ]]; then
      echo "[$category] SKIP — no staged changes"
      continue
    fi
  else
    # Search the full repo (excluding common non-source dirs)
    TARGET=$(git ls-files | grep -vE '^(node_modules/|\.git/|dist/|build/|out/|\.audit/|docs/checklists/)')
  fi

  CATEGORY_EXIT=0

  # Read patterns from file (skip comments and empty lines)
  while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    [[ "$pattern" =~ ^[[:space:]]*# ]] && continue

    # Run grep against target
    HITS=$(echo "$TARGET" | xargs -I {} grep -HnE "$pattern" {} 2>/dev/null || true)

    if [[ -n "$HITS" ]]; then
      echo "[$category] FAIL — pattern: $pattern"
      echo "$HITS" | sed 's/^/  /'
      CATEGORY_EXIT=1
    fi
  done < "$PATTERN_FILE"

  if [[ $CATEGORY_EXIT -eq 0 ]]; then
    echo "[$category] PASS"
  else
    OVERALL_EXIT=1
  fi
done

# --- Run sub-shell scripts (full audit only) ---

if [[ "$MODE" == "full" || "$MODE" == "single" ]]; then
  for script in "${SUBSCRIPTS[@]}"; do
    SCRIPT_PATH="$SCRIPT_DIR/$script"
    if [[ ! -x "$SCRIPT_PATH" ]]; then
      if [[ -f "$SCRIPT_PATH" ]]; then
        echo "[$script] SKIP — not executable"
      else
        echo "[$script] SKIP — not found"
      fi
      continue
    fi

    if "$SCRIPT_PATH"; then
      :
    else
      OVERALL_EXIT=1
    fi
  done
fi

# --- Summary ---

echo ""
if [[ $OVERALL_EXIT -eq 0 ]]; then
  echo "audit: ALL PASS"
else
  echo "audit: FAILURES found above"
fi

exit $OVERALL_EXIT
