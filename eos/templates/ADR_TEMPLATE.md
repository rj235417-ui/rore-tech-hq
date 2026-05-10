# ADR-NNN — [DECISION TITLE]

> **What this is.** An Architecture Decision Record. Captures one
> decision that would be expensive to reverse, so future-you (or a
> future collaborator) understands why the codebase looks the way
> it does. Lives at `docs/decisions/adr-NNN.md` in the product's
> repo.
>
> **The bar.** ADRs are for decisions that are expensive to reverse.
> Schema choices, framework selections, API contract shapes, third-
> party service commitments, irreversible config decisions. Not
> every decision needs an ADR. If reversing the decision is "edit
> a config and redeploy," it doesn't need one. If reversing it is
> "rewrite three files and migrate user data," it does.
>
> **How to number.** Sequential per product. ADR-001, ADR-002, etc.
> Numbers don't get reused even if an ADR is superseded — the old
> ADR is kept and marked "Superseded by ADR-NNN."

---

## Header

| Field | Value |
|---|---|
| ADR number | NNN |
| Title | [Short, decision-focused — e.g., "Use Firestore in locked mode for VibeFire user data"] |
| Status | [Proposed / Accepted / Superseded by ADR-MMM / Deprecated] |
| Date | [YYYY-MM-DD] |
| Phase | [The phase during which this decision was made — links to `docs/protocols/phase-N.md`] |
| Operator | [Who made the call] |

---

## Context

> What's the situation that requires a decision? What forces are
> at play? What constraints exist? Two or three short paragraphs.
> No more.

[Why a decision is needed. What's been tried or considered.
What's at stake.]

---

## Decision

> What we're doing. Stated plainly. The actual decision in one or
> two sentences, then any specifics.

[The decision, as a clear statement.]

---

## Consequences

> What gets better, what gets worse, what becomes harder to change
> later. Honest about the trade-offs.

**Positive:**
- [What this decision enables]
- [What this decision prevents going wrong]

**Negative:**
- [What this decision constrains]
- [What it makes harder to do later]

**Reversal cost:**
- [What it would take to back out of this decision. If "rewrite N
  files and migrate user data," say so. If "edit one config,"
  this probably shouldn't have been an ADR.]

---

## Alternatives considered

> Briefly: what else was on the table, and why we didn't pick it.
> Helps future-you understand whether the rejected options have
> become more attractive since the decision was made.

- **[Alternative A]** — [Why not.]
- **[Alternative B]** — [Why not.]

---

## References

> Links to anything relevant — Phase Protocol, related ADRs,
> external docs, lesson IDs from the inventory if a lesson drove
> the decision.

- Phase: `docs/protocols/phase-[N].md`
- Related ADRs: [...]
- Lesson IDs: [If this decision was driven by a specific lesson —
  e.g., `roreedge-LL-005` for grouping-key-by-broker-account.]
- External: [...]

---

*ADR template v0.1. Sourced from
`rore-tech-hq/eos/templates/ADR_TEMPLATE.md`.*
