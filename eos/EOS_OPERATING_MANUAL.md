# RORE Tech — Engineering Operating System (EOS)

> **Version:** 0.1 (short anchor draft)
> **Status:** Draft. Will be finalized after the universal checklists (B, C)
> and the CLAUDE.md template (D) have been used through one real phase
> transition. Until then, treat this file as the smallest workable
> description of how the system fits together — not the full reference.
>
> **Why short.** The Manual exists to make the checklists legible, not the
> other way around. A long Manual written before the checklists are proven
> ends up describing artifacts that get revised, and then the Manual lies.

---

## 1. What EOS is and what it isn't

**Is.** A lightweight standards-and-protocols layer that sits above every
RORE Tech product project. Its specific job is to catch the kind of
quiet-but-critical setup, configuration, and transition steps that get
missed when a solo founder is moving fast across multiple products. The
test of every EOS artifact is concrete: *would this have caught the
eight Firebase gaps in VibeFire Phase 1 if it had existed two weeks
ago?*

**Isn't.** A methodology. An ISO clone. A management framework. A
substitute for engineering judgment. EOS adds process only where the
absence of process has produced a specific, repeatable failure. Process
without that justification is overhead.

---

## 2. The three-layer model

EOS has three layers, not four. Phase Protocols and Exit Gates are one
artifact, not two — see Section 3.

```
Layer 1 — PLAYBOOK (HQ canonical)
    The standards. What "good" looks like across all products.
    Lives in this Project. Source of truth.

Layer 2 — CLAUDE.md (per product, sectioned)
    How a specific product applies the standards. Has an HQ STANDARDS
    section (mirrors current Playbook standards) and a PROJECT-SPECIFIC
    section (everything unique to this product). HQ updates flow into
    the HQ STANDARDS section without touching the rest.

Layer 3 — PHASE PROTOCOL (per product, per phase)
    The plan for the current phase, including the Exit Gate that says
    when the phase is actually done. One document per phase. Created
    from a template at the start of each phase, completed as the phase
    runs, archived when the phase ships.
```

That's the whole structure. Adding a fourth layer makes the system
heavier without catching more gaps.

---

## 3. Why Phase Protocols and Exit Gates are one artifact

The Phase Protocol describes what the phase is doing and what "done"
looks like. The Exit Gate is the "what done looks like" portion,
formalized as a checklist. If they're separate documents they drift —
one gets updated, the other gets stale, and the gate ends up checking
against an outdated plan.

**Practical form.** A Phase Protocol document has a fixed structure
that includes an *Exit Gate* section near the end. The Universal Exit
Gate Checklist (an HQ artifact) is the template that section is filled
in from at phase kickoff. Project-specific gate items get added on top
of the universal ones.

If real usage shows this is wrong — for example, gates need to be
edited mid-phase in ways the rest of the protocol shouldn't be — split
them. Not before.

---

## 4. Discipline standard (provisional)

The system only works if four things are true:

1. **Every phase, in every product, opens with a Phase Protocol
   document.** No protocol document, no phase. The act of writing it
   is what surfaces the gaps.
2. **Every phase closes by walking the Exit Gate.** Items either pass
   or get an explicit waiver with reason. Skipping the gate is the
   single most common way the system silently fails.
3. **Every phase that closes generates a 5-line lessons-learned
   intake** sent to HQ. Even when nothing felt unusual — *especially*
   when nothing felt unusual.
4. **HQ reviews the lessons inventory monthly** and updates the
   relevant checklist or standard. Lessons that don't change a
   checklist die in the inventory. That's fine. Most won't.

If any one of these four breaks, the system stops catching gaps and
becomes paperwork. Catching that drift is the founder's job — and the
Override Log pattern from the Roundtable applies here too. We can add
a tracking mechanism for skipped gates if the discipline slips.

---

## 5. How HQ relates to product projects

HQ is the **factory and the canon.** Product projects are the **shop
floor.**

- HQ owns the Playbook, the universal checklists, the templates, the
  cross-project lessons inventory, and the monthly review cadence.
- Product projects own their own CLAUDE.md, Phase Protocols, ADRs,
  and runbooks. They run their own Roundtable when summoned.
- Lessons flow *from* product projects *to* HQ via the intake
  protocol. Standard updates flow *from* HQ *to* product projects via
  the HQ STANDARDS section of CLAUDE.md.

The architect role in HQ does not do product work. The deployed
agents in product projects do not redesign standards. The boundary is
deliberate and prevents agent designs from over-fitting to one
product.

---

## 6. Roles

These are roles, not titles. The founder occupies all of them; the AI
collaborators each play a subset.

- **Operator** — the founder. Owns every decision. Owns the lessons
  intake. Owns the monthly review.
- **Architect** — this Project. Designs and refines EOS artifacts.
  Stress-tests them. Does not run them.
- **Engineer (Claude Code)** — executes inside product projects.
  Follows the CLAUDE.md and Phase Protocol for that product. Reports
  blockers and surprises.
- **Technical co-founder (Claude in chat, product project)** —
  product-level design and strategy partner. Runs the deployed
  Roundtable when summoned. Does not edit HQ standards.

When a role is unclear in a moment, the answer is usually: bring it
back to HQ for a meta-conversation, then return to the product project
to execute.

---

## 7. Future state — the Agent Factory hooks

Eventually EOS supports specialized agents that automate parts of the
process. Premature automation codifies chaos, so these are not built
yet. They are listed here so the structure has explicit homes for
them when they arrive.

| Future agent | Lives in | Triggered by | Built when |
|---|---|---|---|
| Gap detector | HQ Project | Phase kickoff or pre-launch review | Universal Exit Gate has been used through 3 phase transitions and is stable |
| Postmortem extractor | HQ Project | Phase close, when 5-line intake arrives | Lessons inventory has 10+ entries and a clear pattern of recurring themes |
| Standards sync | HQ Project | When an HQ Playbook standard changes | At least 2 product projects use the sectioned CLAUDE.md template |
| Phase Protocol generator | Product Project | Phase kickoff | Phase Protocol template has been used through 3 phases without major edits |

The trigger to build any of these is *the standard it would apply has
been stable across 2-3 projects.* Until then, the founder runs the
process manually and the friction itself is data.

---

## 8. What's intentionally not in this Manual

- **A complete ADR or runbook standard.** Real but secondary. Will
  earn dedicated sections after the primary tripwires (Phase Exit
  Gate, Firebase Setup Checklist) prove themselves.
- **A "Definition of Done" per artifact type.** Same — useful, not
  yet load-bearing. Add when the second time you ask "is this done?"
  and don't have a clean answer.
- **Detailed escalation rules.** The Roundtable plus the Operator
  cover this for now. Formalize only if a real escalation gets
  mishandled.
- **Metrics and KPIs for the EOS itself.** The metric is whether
  setup gaps stop slipping through. We'll know.

---

*Source-of-truth Manual. Version 0.1. Maintained in the RORE Tech HQ
Project. Will be expanded after B, C, and D are built and used.*
