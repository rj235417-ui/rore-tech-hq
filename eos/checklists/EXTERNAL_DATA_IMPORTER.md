# External Data Importer Checklist

> **Version:** 0.1
> **Owner:** RORE Tech HQ (`rore-tech-hq/eos/checklists/EXTERNAL_DATA_IMPORTER.md`)
> **When to use.** Any product that ingests tabular or
> structured data from external sources — broker CSVs, PDF
> statements, RSS feeds, XML exports, vendor APIs, third-party
> file uploads. Use whenever a new source is added to an
> existing importer or whenever a new importer is built.
>
> **What this catches.** Wrong P&L from compound action verbs
> (Edge Journal, 100% of trades dropped). Multi-million-dollar
> fake losses from synthetic-row math (Edge Journal -$6.5M).
> Phantom positions from skipped corporate-action codes. Cross-
> broker cost-basis blending. Double-counted shares from
> overlapping CSV imports. Schwab dates becoming year 2001. PDF
> text-extraction reflowing lines into broken rows.
>
> **The bar.** Would walking this checklist have caught the
> twelve importer lessons across Edge Journal and Trade Edge?
> Section by section, yes.
>
> **Lesson trace.** Cluster DC-B in `eos/lessons/INVENTORY.md`.
> Specifically: `roreedge-LL-001`, `LL-002`, `LL-003`, `LL-004`,
> `LL-005`, `LL-006`, `LL-007`, `LL-008`, `LL-009`, `LL-010`,
> `LL-014`, `LL-021`; `tradeedge-LL-009`, `LL-010`, `LL-011`,
> `LL-012`. Plus cross-cutting CC-3 (loud failure), CC-4 (real
> samples).

---

## Section 1 — Real samples before spec

> The most expensive importer bug in the inventory came from a
> spec written against a hand-written example instead of a real
> broker export. Five brokers silently dropped 100% of trades
> because the spec assumed `side === "BUY"` while real exports
> used compound action verbs. *(CC-4 application;
> `roreedge-LL-001`.)*

- [ ] **At least one real export sample obtained from every
  source** the importer will support. Hand-written examples,
  documentation snippets, and SDK type signatures do not count.
  A real export means: a file the actual user got from the
  actual provider, in its actual production format.

- [ ] **Real samples cover the edge cases** that matter for the
  domain:
  - For financial data: at least one sample with corporate
    actions (splits, mergers, fractional cancellations); at
    least one with options-eligible accounts (compound action
    verbs); at least one date-format variant per provider.
  - For RSS/news feeds: at least one sample per outlet, watching
    for character encoding and embedded HTML.
  - For PDF statements: a sample where the visual layout differs
    from the extracted-text layout — most do.

- [ ] **Parser spec is written *against* the real sample**, with
  the sample referenced inline. "Webull exports look like X" gets
  the actual text from the actual export, not a paraphrase.

- [ ] **The sample is committed to the repo as a test fixture**
  (sanitized of personal data) so future regressions can be
  caught by replaying it through the parser.

---

## Section 2 — Encoding and ingestion normalization

> Universal pre-processing that runs on every input before any
> content-based detection. Without it, headers don't match,
> dedup doesn't work, parsing fails on the first byte.

- [ ] **UTF-8 BOM is stripped** at the top of every input
  pipeline:
  ```javascript
  text.replace(/^\uFEFF/, "")
  ```
  Fidelity exports specifically prefix files with BOM; without
  stripping, the first header is "\uFEFFRun Date" and detection
  fails. *(`roreedge-LL-003`.)*

- [ ] **Line endings are normalized** (`\r\n`, `\r`, `\n` all
  become `\n`).

- [ ] **Leading/trailing whitespace is trimmed** from every cell
  during parse.

- [ ] **All normalization happens in one place** — a single
  `normalizeInput()` function called at the top of every importer.
  Not duplicated per-broker. Bugs found here get fixed once.

- [ ] **Quote-aware CSV parsing** is used wherever the source
  produces multiline quoted fields. Naive line-splitting will
  silently corrupt every record after the first multiline cell.
  *(`tradeedge-LL-011`.)* Use a real CSV parser (Papaparse, csv-
  parse, etc.), not `split('\n')`.

---

## Section 3 — Vocabulary and exhaustive enumeration

> Every transaction code, every action verb, every status flag the
> source can emit gets an explicit handler — including `SKIP` with
> a reason. Silent fall-through is the most expensive bug class.
> *(CC-3 application; cluster of `roreedge-LL-001`, `LL-007`,
> `LL-008`, `LL-009`, `LL-021`.)*

- [ ] **Every transaction code from every source is enumerated**
  with an explicit handler. Robinhood: BTO, STC, BTC, BTD, BUY,
  SELL, SPR, MRGS, SCXL, REC, etc. Schwab: B, S, BR, JNL, etc.
  Each gets a row in a mapping table; no code is implicit.

- [ ] **Compound action verbs use prefix matching, not exact
  match.** `side.startsWith("BUY")` and `side.startsWith("SELL")`,
  not `side === "BUY"`. Real exports contain "Buy to Open", "SELL
  TO CLOSE", "BUY TO OPEN" — none equals "BUY".
  *(`roreedge-LL-001`.)*

- [ ] **Unknown codes produce a loud warning**, not a silent
  drop. Format:
  ```
  WARN: Unhandled transaction code "XYZ" in <source>
        Row: <row identifier>
        Action: skipped (no handler defined)
  ```
  Logged + surfaced to the user post-import as a "skipped: N
  items" report. *(`roreedge-LL-021`.)*

- [ ] **Date formats are exhaustively enumerated** per source.
  Schwab uses `D-Mon` ("7-Mar"), MM/DD/YYYY, and ISO depending
  on the export. A `parseDate()` that fails to handle one falls
  through to year 2001 silently. *(`roreedge-LL-008`.)*
  Every parser branch fails loudly — throws or returns null
  with a logged warning.

- [ ] **Instrument types are filtered explicitly** if the
  importer supports a subset. If the journal is equity-only,
  every parser starts with an OCC-symbol filter that drops
  options. The filter is documented in the spec so future
  maintainers don't assume it's incidental.
  *(`roreedge-LL-009`.)*

---

## Section 4 — State, isolation, and dedup

> Multi-source / multi-tenant data systems repeatedly fail when
> grouping keys are derived in two places, when isolation units
> aren't named at schema time, or when dedup logic encounters
> sentinel values. *(Cluster of `roreedge-LL-004`, `LL-005`,
> `LL-006`, `LL-010`; `tradeedge-LL-009`, `LL-010`, `LL-012`.)*

### 4.1 Isolation unit

- [ ] **The natural unit of isolation is named at schema time**,
  before the first parser is written. For brokerage data: the
  isolation unit is `(broker, account, symbol)`, never `symbol`
  alone. Same-symbol positions on different brokers must not
  blend cost basis. *(`roreedge-LL-005`.)*

- [ ] **The isolation unit is encoded as a single helper
  function**, not derived inline at multiple call sites.
  ```
  function getPositionKey(row) {
    return `${row.source}::${row.account}::${row.symbol}`;
  }
  ```
  Every function that groups, queries, or dedupes positions
  calls this helper. Changing the key changes the helper, and
  every site updates automatically. *(`roreedge-LL-004`.)*

### 4.2 File-level dedup

- [ ] **Content-hash every input file at intake**, store the
  hash, refuse exact re-ingestion. Cost is two lines of code;
  gain is permanent immunity to a class of duplication bugs
  (the user importing the same CSV twice, or a 30-day CSV that
  fully overlaps a full-history CSV). *(`roreedge-LL-006`.)*

- [ ] **Hashes persist across sessions** (localStorage in
  browser, file or DB in backend) and are cleared when the user
  clears the data namespace.

### 4.3 Tolerance dedup excludes sentinel values

- [ ] **Tolerance-based row dedup explicitly excludes record
  types whose canonical values are zero/sentinel.** Synthetic
  corporate-action rows (price = 0.0001, qty = 0) match every
  other zero-row within a date+ticker group, collapsing
  legitimate distinct events. Skip dedup for known sentinel
  record types. *(`tradeedge-LL-012`.)*

### 4.4 Sort stability

- [ ] **Any sort that drives money/share calculations has a
  deterministic tiebreaker.** `Array.sort()` is not guaranteed
  stable for same-key records in older browsers; FIFO cost-
  basis replay then sees sells before their corresponding buys
  and skips silently. Add the original CSV row position as
  final tiebreaker:
  ```
  rows.sort((a, b) =>
    a.date - b.date
    || (a.action === 'BUY' ? -1 : 1)
    || a.csvIdx - b.csvIdx
  );
  ```
  *(`tradeedge-LL-010`.)*

### 4.5 UI selection state persistence

- [ ] **Any UI selection that determines what data the user is
  looking at is persisted, not held in memory.** Account filters,
  date ranges, view modes — all lost on page reload otherwise.
  Persisted in localStorage with a versioned key. *(`roreedge-
  LL-010`.)*

- [ ] **Two functions are not allowed to "restore" the same DOM
  value from different sources.** Pick one source of truth.
  *(`roreedge-LL-010` second half.)*

### 4.6 Multi-account namespace isolation

- [ ] **For browser tools using localStorage with multiple data
  sets**: either prefix every key with a namespace selected at
  import time, OR ship as separate files at distinct paths
  (file:// origins are per-path). Same-file means same
  localStorage; tab isolation isn't a thing. *(`tradeedge-LL-009`.)*

---

## Section 5 — Math correctness and reconciliation

> Any importer that computes financial values (P&L, cost basis,
> share counts, balances) is reconciled against a known-good
> external source before merge. The Edge Journal -$6.5M fake
> loss would have been caught in seconds against the user's
> actual portfolio total. *(CC-4 application;
> `roreedge-LL-002`.)*

- [ ] **Synthetic rows for corporate actions use `avgCost` as
  the synthetic price, not arbitrary placeholders.** Any other
  synthetic price produces fake P&L. The math
  `(syntheticPrice - avgCost) × shares` must equal zero for
  splits and other share-count adjustments.

- [ ] **Math changes happen in `matchTrades` (or the matching
  stage), not in the parser.** Layering split handling at the
  parser level emits synthetic trades that downstream stages
  treat as real. *(`roreedge-LL-002`.)*

- [ ] **Before merge: the importer is run on real historical
  data and reconciled against a known-good total** — the user's
  brokerage statement total, the trader's spreadsheet, whatever
  exists outside the importer. If the totals diverge, the
  divergence is investigated *before* the change is committed.

---

## Section 6 — PDF parsing (when applicable)

> PDF text-extraction libraries can re-flow text in ways that
> don't preserve the visual line structure. Position-based
> parsing of extracted text is brittle. *(`roreedge-LL-014`.)*

- [ ] **Never assume the visual line structure survives text
  extraction.** Open the extracted text and verify what the
  parser actually sees, not what the PDF visually shows.

- [ ] **Parsing anchors on content patterns, not line index.**
  Date regex, currency regex, fixed tokens. Order-preserving
  but position-tolerant.
  ```
  // Bad: line N is symbol, line N+1 is company, line N+2 is data
  // Good: regex matches "{TICKER} {DATE} {DATE} {B|S} {NUMS}"
  //       anywhere on the line, regardless of position
  ```

- [ ] **Parser is validated against a real extracted-text sample**,
  not against the visual PDF.

---

## Section 7 — User-visible feedback

> Every "skip" branch produces a user-visible record. Silent
> drops are how phantom positions persist for years.
> *(CC-3 application; `roreedge-LL-021`.)*

- [ ] **Post-import report shows: imported, skipped, and the
  list of skipped items** (symbol + date + reason). The user
  can scan it. The user can act on it.

- [ ] **For unmatched sells (sell with no buy in import
  window)**: the report names the affected symbols and dates,
  and recommends importing additional history.

- [ ] **For unknown transaction codes**: the report names the
  code and the source so the operator can add a handler.

- [ ] **Browser cache + stale localStorage are part of the
  verify cycle**, not optional. After any importer fix:
  hard-refresh + clear local state + re-run input from scratch.
  Anything less is testing the previous build.
  *(`tradeedge-LL-013`.)*

---

## Gate decision

At the end of the walk, one of the following is recorded:

- **GATE PASSED** — all items PASS, N/A, or WAIVE with reason;
  importer is ready for merge.
- **GATE PASSED WITH WAIVERS** — same, with explicit waivers
  carrying named follow-up owners and target dates. Waivers in
  Section 5 (math reconciliation) are particularly high-risk —
  review carefully before accepting.
- **GATE FAILED** — one or more items cannot be marked.
  Importer is not ready. Specifically, no importer touching
  financial math should ship without Section 5 PASS.

---

## What's intentionally not in this checklist

- **UI design for the importer interface.** Drag-drop, file
  picker, error banners — those are product decisions captured
  in mockups or ADRs.
- **Per-source field mapping.** Each broker's CSV field
  mapping lives in the parser code, not in this checklist. The
  checklist verifies *that* the mapping exists and is
  exhaustive, not the specifics.
- **Performance optimization.** Importing 14,000+ rows is real
  but not in scope here. Performance lives in the product's
  ADRs and runbooks if it becomes a concern.

---

*Source-of-truth checklist. Maintained in
`rore-tech-hq/eos/checklists/EXTERNAL_DATA_IMPORTER.md`. v0.1
absorbs DC-B lessons listed in the lesson trace above.*
