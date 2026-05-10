# AI Publishing Pipeline Checklist

> **Version:** 0.1
> **Owner:** RORE Tech HQ (`rore-tech-hq/eos/checklists/AI_PUBLISHING_PIPELINE.md`)
> **When to use.** Any product where an LLM produces content that
> ships externally — to followers, to customers, to a public feed,
> to a third party. Or any product that ingests copyrighted source
> material into an AI pipeline. Both halves matter.
>
> **What this catches.** Hallucinated specifics in published
> content (XAGENT). Close-paraphrase of copyrighted source material
> (Trade Edge / EagleEye). AI features that bypass a product's
> stated privacy commitment (Edge Journal AI Review). Cost runaway
> on per-call AI features (XAGENT preview button). Auto-publish
> without human review during early operation (XAGENT first 24
> hours).
>
> **The bar.** Would walking this checklist have caught the ten
> AI-publishing lessons across XAGENT, Trade Edge, and Edge Journal?
> Section by section, yes.
>
> **Lesson trace.** Cluster DC-C in `eos/lessons/INVENTORY.md`.
> Specifically: `xagent-LL-008`, `LL-009`, `LL-010`, `LL-014`,
> `LL-017`, `LL-019`; `tradeedge-LL-016`, `LL-017`, `LL-019`;
> `roreedge-LL-016`. Plus cross-cutting CC-9 (privacy as
> architectural constraint), CC-3 (loud failure), CC-4 (real
> samples).
>
> **Prologue — External Service Kickoff matrix.** Before walking
> Sections 1–5 below, complete the matrix below for every external
> AI service this pipeline calls. *(H13 application.)*

---

## Prologue — External Service Kickoff matrix

| Question | Answer |
|---|---|
| Which AI provider(s) does this pipeline call? | [e.g., Anthropic Claude API, OpenAI, Replicate] |
| Which billing dashboard owns the cost for each provider? | [e.g., console.anthropic.com — separate from Claude.ai Pro] |
| Which specific model and operation is each call? | [e.g., claude-sonnet-4-7 messages.create with web_search tool] |
| What's the per-call cost band? | [e.g., DIRECT ~$0.01, LIGHT ~$0.10, DEEP ~$0.40] |
| What's the rate limit for this tier? | [Tokens per minute, requests per minute] |
| Does the pipeline also call any non-AI external services? | [e.g., X API for posting, web_search] |
| Per-operation tier verification done? | [Yes / No — paste line from provider's pricing page] |

*(Cross-references `xagent-LL-001` — Anthropic API billing is
separate from Claude.ai Pro; `xagent-LL-002` — X API automated-
posting tier is separate from API-access tier.)*

---

## Section 1 — Source and IP vetting

> Any reference document, training corpus, or knowledge file that
> the AI pipeline consumes goes through this section *before* the
> pipeline is built. Source-vetting is design-phase work, not a
> footnote. *(Trade Edge LL-016 caught this mid-build; the doc had
> to be rewritten v1.0 → v1.1.)*

- [ ] **Every cited source has been checked for terms-of-use
  restrictions on AI training and AI-generated derivative works.**
  Specifically watching for: explicit "do not use to train AI
  systems," explicit "no derivative works," any clause that
  prohibits the specific use the pipeline makes.
  *(Cross-references `tradeedge-LL-016`.)*

- [ ] **Sources with AI-training or no-derivative restrictions are
  excluded** from the pipeline. Excluded means physically not
  loaded into the pipeline's context, not "we paraphrase
  carefully." Paraphrasing doesn't cure a no-derivative-works
  restriction.

- [ ] **A bibliography lists every remaining source** with the
  terms-of-use check date. Lives at the same level as the
  reference document the pipeline consumes (e.g.,
  `PATTERNS_REFERENCE.md` next to its `SOURCES.md`).

- [ ] **Every claim in the reference document is tagged with a
  source identifier or `[IMPL]` for synthesized rules.**
  *(Cross-references `tradeedge-LL-017`.)* Without claim-level
  tagging, a reference document of any size is unreviewable for
  IP risk. Format:
  ```
  Cup-and-handle pattern shows ~62% breakout success [SC]
  ...where threshold ≥ 0.65 confidence triggers alert [IMPL]
  ```

- [ ] **Source diversity is enforced for any pipeline that fetches
  external content.** Multiple domains per topic (not "all news
  comes from one outlet"). Reduces close-paraphrase risk and
  reduces single-source bias.
  *(Cross-references `xagent-LL-017`.)*

---

## Section 2 — Pipeline architecture

> The pipeline shape itself. Single-call generation is the
> hallucination failure mode (XAGENT first 24 hours). The
> research → draft → verify → human-review → publish shape is
> what graduates a pipeline to safe.

- [ ] **Pipeline is research → draft → verify → publish, not
  single-call.** Specifically:
  - **Research stage** uses real-time data sources (web_search,
    curated feeds) and returns structured `{facts, sources,
    hasNews}` JSON.
  - **Draft stage** uses *only* the verified facts from research
    as input, with explicit "do not introduce statistics not in
    the source list" instruction.
  - **Verify stage** extracts every claim from the draft and
    checks against the facts, returning PASS/FAIL per claim.
  - **Publish stage** is gated on Verify PASS.
  *(Cross-references `xagent-LL-008`.)*

- [ ] **Single-call generation is acceptable only for content with
  no falsifiable specifics.** Motivation quotes about known
  figures, hot takes that don't make numerical claims, riddles,
  jokes. Anything with a number, a date, or a named event goes
  through the full pipeline.

- [ ] **Recency is enforced in three places** for any pipeline
  that consumes web_search to produce time-sensitive output:
  1. Explicit cutoff date in the prompt: `Today: ${today}. Only
     include facts where the event occurred after ${cutoffDate}`.
  2. Instruction to reject "still being discussed" framing as
     evidence of recency.
  3. Code-level `staleKeywords` blocklist filtering known stale
     topics (e.g., `'deepseek r1'`, `'gpt-4 launch'`).
  *(Cross-references `xagent-LL-009`.)*

- [ ] **Verifier strictness is tunable per pipeline level**, not
  a single global setting. DIRECT generation needs lighter
  verification than DEEP research output.
  *(Cross-references `xagent-LL-010`.)*

- [ ] **Verifier handles "no recent news" gracefully** —
  pipeline returns a "nothing posted today" signal instead of
  generating a tweet about nothing.
  *(Cross-references `xagent-LL-011`.)*

---

## Section 3 — Consent and disclosure (privacy-first products)

> If the product makes a privacy commitment ("your data stays on
> your device," "we don't send anything to third parties"), then
> any AI feature that violates the commitment requires an
> explicit, dedicated, in-context consent surface. Buried ToS
> disclosure does not cover this. *(CC-9 application;
> `roreedge-LL-016` is the canonical example.)*

- [ ] **AI feature is reviewed against the product's stated
  privacy commitment at design time**, not at compliance-page time.

- [ ] **A dedicated consent modal exists**, shown the first time
  the user invokes the AI feature, listing exactly:
  - **What is sent** (specific fields, not "your data") — display
    with a ✓ icon per item.
  - **What is never sent** (specific fields the commitment
    protects) — display with a ✗ icon per item.
  - **Where it goes** (the third-party provider, with link to
    their privacy policy).
  - **How long it's retained** (per provider's policy).
  - **A required checkbox** to proceed.

- [ ] **Consent is stored** in a named storage key (e.g.,
  `tradeedge_ai_consent`).

- [ ] **Revoke path exists** in a discoverable location — a
  "Revoke AI Consent" item in settings or data manager. Revoking
  prevents future AI calls until re-consented.

- [ ] **Privacy policy mentions the AI feature** with the same
  what-is-sent / what-is-not-sent framing. The policy mirrors
  the consent modal's content; it doesn't replace it.

---

## Section 4 — Cost and UI

> Pay-per-call AI features need cost discipline at the UI layer,
> not just the architecture layer. *(XAGENT-LL-014: Preview
> button silently consumed Anthropic credits at the same rate as
> scheduled posts.)*

- [ ] **Every UI control that triggers a paid AI call displays
  the per-call cost band before clicking.** Format like:
  - DIRECT: ~$0.01–$0.02
  - LIGHT (with web_search): ~$0.05–$0.15
  - DEEP (research + draft + verify): ~$0.25–$0.40

- [ ] **Preview / test affordances route to the cheapest path
  that still answers the question.** A Preview button that costs
  the same as the live action is a UX bug, not a cost bug. For
  XAGENT specifically, `/preview` runs DIRECT (single Claude
  call, no web_search) regardless of what the live pipeline runs.

- [ ] **Per-post cost table is documented** in user-facing docs
  (e.g., the README, the operator guide, or in the consent modal).

- [ ] **Monthly budget alert is set** at the AI provider's
  dashboard. *(Cross-references the External Service Kickoff
  prologue and Firebase Setup Section 1's budget alert.)*

---

## Section 5 — Release graduation

> Auto-publish is a graduation, not a default. *(XAGENT-LL-019:
> for ~24 hours after the agent went live, every generated tweet
> posted automatically. Hallucinated content reached followers
> before the user noticed.)*

- [ ] **The first 100 outputs go through human review.** Auto-
  publish only after the first 100 are approved without
  manual override.

- [ ] **A `/preview` (or equivalent) endpoint exists that runs
  the full pipeline without publishing.** The user invokes
  preview to see what *would* be published, manually approves,
  then publishes.

- [ ] **A draft → human review → post UI affordance exists.** Not
  optional for AI publishing products. The verification pipeline
  in Section 2 is a "second opinion" check, not a substitute for
  human review during the graduation period.

- [ ] **"Use solo before evangelizing" gate applied** for any
  tool meant to be shown to peers. Use the tool for at least N
  real sessions personally before showing anyone. Defects
  trapped in solo use are free; defects trapped in demos cost a
  relationship. *(Cross-references `tradeedge-LL-019`.)*

- [ ] **Persistence layer for pipeline state exists, OR the
  product's Definition of Done explicitly accepts "in-memory
  state lost on every redeploy"** as a known limitation.
  *(Cross-references `xagent-LL-018`.)* In-memory state in
  hosted services is a real choice; the choice gets documented
  rather than defaulted into.

---

## Gate decision

At the end of the walk, one of the following is recorded in the
Phase Protocol:

- **GATE PASSED** — all items PASS, N/A, or WAIVE with reason.
- **GATE PASSED WITH WAIVERS** — same, with explicit waivers
  carrying named follow-up owners and target dates. Waivers in
  Section 1 (IP vetting) or Section 3 (consent) are particularly
  high-risk; review carefully before accepting.
- **GATE FAILED** — one or more items cannot be marked. Pipeline
  is not ready to publish externally.

A GATE FAILED in this domain is genuinely fine. AI publishing
that's not ready to publish should not publish.

---

## What's intentionally not in this checklist

- **Model selection.** Which model to use for which stage is a
  product design decision captured in an ADR, not in this
  checklist.
- **Prompt engineering.** Specific prompts live in the product's
  code or in a `prompts/` directory; this checklist verifies the
  *pipeline shape*, not the prompt content.
- **Fine-tuning or RAG architecture.** If the product uses
  fine-tuning or vector search, those have their own design
  decisions worth ADRs but aren't pipeline-shape items.

---

*Source-of-truth checklist. Maintained in
`rore-tech-hq/eos/checklists/AI_PUBLISHING_PIPELINE.md`. v0.1
absorbs DC-C lessons listed in the lesson trace above.*
