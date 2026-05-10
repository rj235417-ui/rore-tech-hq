#!/bin/bash
# audit/link-consistency.sh
#
# Verifies:
#   1. No filenames with whitespace or non-portable characters in
#      committed paths.
#   2. Internal links use consistent .html-extension conventions
#      (or consistent extensionless conventions, but not mixed).
#
# Catches: filename rename slips that ship under a corrected name
# while the broken file is still referenced (per
# roretech-website-LL-002). Footer links written without .html
# that work only because Netlify's pretty-URL fallback masks them
# (per roretech-website-LL-004).
#
# Returns: 0 (PASS) if clean, 1 (FAIL) otherwise.
#
# Run modes:
#   ./audit/link-consistency.sh           # against the working tree
#   ./audit/link-consistency.sh --staged  # against staged diff

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

MODE="${1:-tree}"
EXIT_CODE=0

# --- Check 1: filename hygiene ---

if [[ "$MODE" == "--staged" ]]; then
  ALL_FILES=$(git diff --cached --name-only --diff-filter=ACM || true)
else
  ALL_FILES=$(git ls-files)
fi

# Flag filenames containing whitespace or non-portable characters
# (anything that isn't alphanumeric, underscore, hyphen, dot, slash).
echo "$ALL_FILES" | while read -r file; do
  [[ -z "$file" ]] && continue
  if [[ "$file" =~ [[:space:]] ]]; then
    echo "[link-consistency] FAIL: filename contains whitespace: $file"
    EXIT_CODE=1
  fi
  # Allow alphanumeric, underscore, hyphen, dot, slash; flag others.
  if [[ "$file" =~ [^a-zA-Z0-9_./\-] ]]; then
    echo "[link-consistency] FAIL: filename contains non-portable character: $file"
    EXIT_CODE=1
  fi
done

# --- Check 2: link-extension consistency ---
#
# This check is opinionated. The convention chosen is:
# every internal link to an HTML page includes the .html extension.
# (Pretty URLs without the extension work on Netlify but break
# elsewhere, and silently mask broken links.)
#
# Detection: find <a href="/something"> or <a href="something">
# where "something" looks like it could be a page path
# (no extension, no trailing slash, no fragment-only).

HTML_FILES=$(echo "$ALL_FILES" | grep -E '\.html?$' || true)

for html in $HTML_FILES; do
  [[ -z "$html" ]] && continue
  [[ ! -f "$html" ]] && continue

  # Find href values that look like page paths without .html
  # Allow: trailing slashes (treated as directory), explicit .html,
  # external URLs, fragments, mailto:, tel:.
  BAD_LINKS=$(grep -oE 'href="[^"]+"' "$html" \
    | sed -E 's/.*="([^"]+)".*/\1/' \
    | grep -vE '^(https?:|//|mailto:|tel:|#|javascript:|data:)' \
    | grep -vE '\.(html?|css|js|png|jpe?g|svg|gif|webp|pdf|ico|xml|json|txt)' \
    | grep -vE '/$' \
    | grep -vE '^#' \
    || true)

  if [[ -n "$BAD_LINKS" ]]; then
    while read -r bad; do
      [[ -z "$bad" ]] && continue
      echo "[link-consistency] FAIL: $html has internal link without .html extension: $bad"
      EXIT_CODE=1
    done <<< "$BAD_LINKS"
  fi
done

if [[ $EXIT_CODE -eq 0 ]]; then
  echo "[link-consistency] All filenames clean and links extension-consistent. PASS."
fi

exit $EXIT_CODE
