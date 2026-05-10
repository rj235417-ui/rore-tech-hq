#!/bin/bash
# audit/asset-existence.sh
#
# Verifies every <img src="/...">, favicon path, and <link href="/...">
# in committed HTML resolves to a tracked file in the repo.
#
# Catches: HTML referencing PNGs that exist in the operator's local
# workspace but were never committed. Per roretech-website-LL-003.
#
# Returns: 0 (PASS) if all referenced assets exist as tracked files,
# 1 (FAIL) otherwise. Prints findings.
#
# Run modes:
#   ./audit/asset-existence.sh           # against the working tree
#   ./audit/asset-existence.sh --staged  # against staged diff (pre-commit)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

MODE="${1:-tree}"
EXIT_CODE=0

# Find HTML files to audit
if [[ "$MODE" == "--staged" ]]; then
  HTML_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.html?$' || true)
else
  HTML_FILES=$(find . -type f -name "*.html" -not -path "./node_modules/*" -not -path "./.git/*" -not -path "./dist/*" -not -path "./build/*" -not -path "./out/*")
fi

if [[ -z "$HTML_FILES" ]]; then
  echo "[asset-existence] No HTML files to audit. PASS."
  exit 0
fi

# For each HTML file, extract local asset references
for html in $HTML_FILES; do
  # Match src="/path", src="path", href="/path" — relative or root-relative.
  # Skip http://, https://, //, data:, mailto:, tel:, #fragments.
  REFS=$(grep -oE '(src|href)="[^"]+"' "$html" \
    | grep -vE '"(https?:|//|data:|mailto:|tel:|#|javascript:)' \
    | sed -E 's/.*="([^"]+)".*/\1/' \
    | sort -u || true)

  for ref in $REFS; do
    # Strip query string and fragment
    ref_clean=$(echo "$ref" | sed 's/[?#].*//')

    # Skip empty
    [[ -z "$ref_clean" ]] && continue

    # Resolve relative paths against the HTML file's directory;
    # absolute paths against repo root.
    if [[ "$ref_clean" == /* ]]; then
      target="${ref_clean#/}"
    else
      target="$(dirname "$html")/$ref_clean"
    fi

    # Normalize the path
    target=$(echo "$target" | sed 's|//|/|g; s|^\./||')

    # Check the file is tracked by git (handles both committed and
    # staged-but-not-committed depending on mode).
    if [[ "$MODE" == "--staged" ]]; then
      if ! git ls-files --error-unmatch "$target" >/dev/null 2>&1 \
         && ! git diff --cached --name-only | grep -qF "$target"; then
        echo "[asset-existence] FAIL: $html references $ref but $target is not staged or tracked."
        EXIT_CODE=1
      fi
    else
      if ! git ls-files --error-unmatch "$target" >/dev/null 2>&1; then
        echo "[asset-existence] FAIL: $html references $ref but $target is not tracked by git."
        EXIT_CODE=1
      fi
    fi
  done
done

if [[ $EXIT_CODE -eq 0 ]]; then
  echo "[asset-existence] All asset references resolve to tracked files. PASS."
fi

exit $EXIT_CODE
