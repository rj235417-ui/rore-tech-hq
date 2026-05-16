# HQ — Inventory captured directly, intake protocol bypassed

1. Phase and product: HQ — inventory protocol, 2026-05-16.

2. What went well: Eleven lessons (LL-022 through LL-032) were
   captured at full inventory depth during Vibe Spinner Phase 2
   close and Phase 3 session 1. The richness of capture would
   have been hard to recreate after the fact.

3. What slipped: The intakes referenced lesson IDs (LL-022,
   LL-028, LL-031, LL-032) as if they already existed when
   they did not — the additions file was the source. The
   intake protocol assumes lessons land first as intakes and
   become inventory entries at monthly review.

4. Process implication: INTAKE_PROTOCOL.md should accommodate
   a "direct inventory capture" path for cases where the
   operator captures a lesson at full inventory depth during
   work. In that path, the inventory entry IS the canonical
   capture and a short intake is not separately required. The
   monthly review still owns the cross-product synthesis;
   direct entries flag themselves with a "captured pre-review"
   marker.

5. One-line ask of HQ: at next monthly review, add a
   "direct inventory capture" path to INTAKE_PROTOCOL.md and
   define when it applies (operator captures at full depth)
   vs when it doesn't (short-form lesson; intake still required).
