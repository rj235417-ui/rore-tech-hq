# HQ — Lesson ID collision between parallel sessions

1. Phase and product: HQ inventory protocol, 2026-05-19.

2. What went well: The collision was caught at merge time, not
   after canonical IDs had been referenced in product code,
   commits, or external artifacts. Option A merge (preserve v0.2
   IDs, integrate richer content, renumber net-new lessons)
   resolved cleanly.

3. What slipped: Two parallel sessions assigned the same lesson
   ID range (LL-022 onward) with different content. The product-
   side session drafted from the Phase 4 handoff using its own
   numbering; the HQ session had already committed v0.2 with
   different content under the same IDs. Without a coordination
   mechanism, this kind of collision will recur.

4. Process implication: Lesson IDs must be assigned by HQ at
   filing time, not by the product project at drafting time.
   Product-side drafts should use placeholder IDs (LL-NEXT-1,
   LL-NEXT-2, ...) and HQ assigns final IDs during merge.
   Update INTAKE_PROTOCOL.md to make this explicit.

5. One-line ask of HQ: at next monthly review, update
   INTAKE_PROTOCOL.md to require LL-NEXT-N placeholder IDs in
   product-side drafts, with HQ assigning final IDs at merge.
