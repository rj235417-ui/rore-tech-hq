# Project Registry

> **What this is.** The canonical record of which RORE Tech product
> projects are on which version of the EOS, when each last synced
> from HQ, and which Tier 2 artifacts each carries.
>
> **Updated by.** `rore-tech-hq/eos/sync/sync-to-project.sh`
> automatically on every successful sync. The script is idempotent —
> running it twice on the same product on the same day updates the
> row in place; it never adds duplicates.
>
> **Read manually.** When you ask "is product X up to date with
> current HQ?", this table answers in one row.
>
> **Audit trail.** Per-sync paper trail lives in each product's
> `SYNC_REPORT.md` (overwritten each sync) and in this file's git
> history. To find when product X adopted EOS version Y, run
> `git log -p org/PROJECT_REGISTRY.md` and grep for the product.

---

## Active products

| Product | Key | Status | HQ Commit | Last Sync | Tier 2 |
|---|---|---|---|---|---|
| VibeFire | VIBEFIRE | Tier 1 only | f740c8c | 2026-05-11 | FIREBASE_FLUTTER_SETUP,PLAY_STORE_SUBMISSION,SIGNING_KEY_BIRTH_CERTIFICATE,LAUNCH_PLAN_TEMPLATE |
| Vibe Spinner | VIBE_SPINNER | Tier 1 only | 1c5833b | 2026-05-12 | PLAY_STORE_SUBMISSION,SIGNING_KEY_BIRTH_CERTIFICATE,DEPLOYMENT_CHECKLISTS,LAUNCH_PLAN_TEMPLATE |
| RORE Edge Journal | RORE_EDGE_JOURNAL | Tier 1 only | 21b02e4 | 2026-05-13 | EXTERNAL_DATA_IMPORTER,DEPLOYMENT_CHECKLISTS,SIGNING_KEY_BIRTH_CERTIFICATE,AI_PUBLISHING_PIPELINE,LAUNCH_PLAN_TEMPLATE |
<!-- SYNC_ROWS_END -->

---

## Column meanings

- **Product** — display name (from `PRODUCT_<KEY>_NAME` in manifest).
- **Key** — short uppercase identifier (matches manifest).
- **Status** — `Tier 1 only` (HQ STANDARDS + Roundtable + templates,
  no checklists yet) or `Tier 1 + Tier 2` (full sync including
  product-specific checklists).
- **HQ Commit** — the short git SHA of `rore-tech-hq` at the moment
  of the last sync. Lets you reproduce exactly what was synced.
- **Last Sync** — date of last successful sync.
- **Tier 2** — comma-separated list of Tier 2 artifacts declared in
  the manifest for this product. The list reflects the *intent* of
  the manifest, not necessarily what's currently in `docs/standards/`
  on disk (especially if the last sync was `--tier1-only`).

---

## Inactive / archived products

> Move rows here when a product is sunset. Keeps the active table
> readable.

| Product | Key | Sunset date | Last EOS version | Notes |
|---|---|---|---|---|
| (none) | — | — | — | — |

---

## When to inspect this file

- **Before doing a monthly review.** Spot any product with a Last
  Sync date older than ~2 months — that's a candidate for a sync
  refresh at the product's next phase kickoff.
- **Before pushing a major HQ STANDARDS update.** The list of
  products is the list you need to plan re-syncs for. Critical
  updates may require push; non-critical can wait for natural pull.
- **When a Roundtable session in any product cites a chair behavior
  that doesn't match current HQ.** Suspicion: the product is on a
  stale ROUNDTABLE.md. Check this file's Last Sync for the affected
  product and re-sync if behind.

---

*Project registry. Maintained automatically by
| VibeFire | VIBEFIRE | Tier 1 only | f740c8c | 2026-05-11 | FIREBASE_FLUTTER_SETUP,PLAY_STORE_SUBMISSION,SIGNING_KEY_BIRTH_CERTIFICATE,LAUNCH_PLAN_TEMPLATE |
| Vibe Spinner | VIBE_SPINNER | Tier 1 only | 1c5833b | 2026-05-12 | PLAY_STORE_SUBMISSION,SIGNING_KEY_BIRTH_CERTIFICATE,DEPLOYMENT_CHECKLISTS,LAUNCH_PLAN_TEMPLATE |
| RORE Edge Journal | RORE_EDGE_JOURNAL | Tier 1 only | 21b02e4 | 2026-05-13 | EXTERNAL_DATA_IMPORTER,DEPLOYMENT_CHECKLISTS,SIGNING_KEY_BIRTH_CERTIFICATE,AI_PUBLISHING_PIPELINE,LAUNCH_PLAN_TEMPLATE |
`rore-tech-hq/eos/sync/sync-to-project.sh`. The `SYNC_ROWS_END`
HTML comment marker is the insertion point for the script —
new rows go just before it.*
