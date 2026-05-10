# Intake Protocol — How Lessons Flow from Products to HQ

> **What this is.** The formal description of the cycle's
> Reporting handoff and Update handoff (per HQ STANDARDS H8).
> Lessons surface in product projects as they run; they reach
> HQ as 5-line intakes; HQ reviews monthly; standards and
> checklists update; the next phase pulls the updated version
> at adoption.
>
> Without this protocol, intakes either don't get drafted, don't
> reach HQ, or pile up at HQ without driving updates. The
> protocol exists to make the path predictable.
>
> **Lesson trace.** HQ STANDARDS H6, H8. Derived from cross-cutting
> need surfaced when compiling the lessons inventory v0.1 — the
> single largest meta-lesson is that 121 lessons existed but no
> standardized path moved them into checklists.

---

## The cycle, end to end

```
   Phase running         →    Phase closes         →    HQ reviews          →    Next phase
   ─────────────              ─────────────              ─────────────              ─────────────
   Lessons surface             5-line intake              Standards / checklists     Pulls current
   into the phase log          drafted at gate            update                     HQ version at
   (Section 3 of                walk; sent to HQ                                     adoption
   Phase Protocol)
```

Four checkpoints. Each has a failure mode if skipped. The
protocol below names what each checkpoint requires.

---

## Checkpoint 1 — Lessons surface in the phase log (continuous)

**When.** Throughout the phase, as work happens.

**Who.** Operator. AI collaborators add to the log when prompted.

**Format.** Phase Protocol Section 3 — Phase log. One entry per
session, surprise, decision, or change. 1-3 lines per entry.
Brief enough that updating during work is cheap.

**What surfaces here.**
- Anything that took longer than expected.
- Anything that surprised the operator or an AI collaborator.
- Decisions made (linked to ADRs if expensive to reverse).
- Workarounds applied (linked to follow-up tickets).
- "Next time, we'd ___" observations.

**Failure mode if skipped.** Lessons surface only at phase close,
when memory is already fading. The 5-line intake at gate walk
becomes a "what did we do?" exercise instead of a "what did we
*learn*?" exercise.

**Discipline.** End every Claude Code session in a phase with one
or two lines added to the phase log. Not optional. The log is
where the intake comes from.

---

## Checkpoint 2 — 5-line intake drafted at gate walk

**When.** Phase close. Specifically: as part of walking the
Universal Phase Exit Gate Section 5.10.

**Who.** Operator drafts; AI collaborator can offer a draft based
on the phase log; operator confirms before sending.

**Format.**

```
1. Phase and product: [Product name, phase number, phase title, dates]
2. What went well: [One specific thing]
3. What slipped: [One specific gap, near-miss, or surprise]
4. Process implication: [Which checklist or standard, if any, should change — or "none"]
5. One-line ask of HQ: [Smallest concrete update requested, or "no change"]
```

**Five lines. Not six.** The constraint forces signal. If "what
slipped" needs three sub-bullets, three lessons are being
compressed; split into multiple intakes if it really is multiple
distinct lessons.

**What "good" looks like:**

```
1. Phase and product: VibeFire Phase 1 — Magic Link auth, May 9-10 2026.
2. What went well: flutterfire configure as a single command resolved 4 of 8 gaps once we found it.
3. What slipped: ActionCodeSettings.url was named in the kickoff plan but skipped in implementation; only caught at end-to-end smoke test.
4. Process implication: add "Implementation matches plan" item to Universal Phase Exit Gate.
5. One-line ask of HQ: confirm the implementation-vs-plan check graduates from Firebase Setup Section 6 to Universal gate.
```

**What "bad" looks like:**

```
1. Phase and product: VibeFire phase 1.
2. What went well: lots of progress.
3. What slipped: many things went wrong.
4. Process implication: more discipline.
5. One-line ask of HQ: better tools.
```

The bad version isn't actionable. The good version produces a
specific HQ change.

**Failure mode if skipped.** HQ has no input. Standards and
checklists drift. The cycle breaks at the outbound side.

---

## Checkpoint 3 — Intake sent to HQ

**When.** Immediately after drafting, at gate walk.

**How.** Three options, in order of preference:

1. **Most preferred — file in the HQ repo.** Operator commits
   the intake to `rore-tech-hq/eos/lessons/intake/` as a
   single Markdown file:
   ```
   YYYY-MM-DD-[product]-phase-[N].md
   ```
   File contents are the 5 lines (plus optional context).
   Commit message: `Intake: [product] phase [N]`.

2. **Acceptable — append to a running log.** Operator appends
   to `rore-tech-hq/eos/lessons/intake/RUNNING_LOG.md`. Each
   entry separated by `---` and the 5-line format. Useful for
   batched intakes when the operator is processing several at
   once.

3. **Last resort — paste into HQ chat session.** When the
   operator doesn't have the HQ repo handy, paste the intake
   into a Claude session in the HQ project, with a one-line
   header "INTAKE: [product] phase [N]." The Claude session
   helps the operator file it later.

**Critical rule.** A drafted intake that doesn't reach HQ is the
same as no intake. The Phase Exit Gate Section 5.10 second
checkbox ("Intake has been sent to HQ") must be honest. If the
intake hasn't reached HQ, the gate has not passed.

**Failure mode if skipped.** Intake exists in the product's phase
protocol but never reaches the HQ side. Lessons are visible
locally but never propagate. Standards stay stale.

---

## Checkpoint 4 — Monthly HQ review

**When.** First weekend of every month, or when the intake
folder accumulates 5+ new entries (whichever comes first).

**Who.** Operator, working in the HQ project.

**Process.**

1. **Read every intake** in `eos/lessons/intake/` since the last
   review. Group by theme.

2. **Update the cross-project lessons inventory.** Each new
   lesson becomes a new entry in `eos/lessons/INVENTORY.md` with
   a unique ID. Pattern: `[product]-LL-NNN` where NNN is the
   next number for that product. New cross-cutting patterns
   surface when a third lesson lands with the same shape (per
   inventory v0.1's note about CC-12 candidate).

3. **Update the relevant checklist or standard.** For each
   lesson where the "Process implication" field named a
   change:
   - If it's a checklist update: edit the checklist file in
     `eos/checklists/`, bump the version, cite the lesson ID.
   - If it's an HQ STANDARDS update: edit
     `eos/templates/CLAUDE_MD_TEMPLATE.md`, bump the version,
     cite the lesson ID.
   - If it's a runbook update: edit the runbook in
     `eos/runbooks/`.
   - If it's a new audit pattern: add to the relevant pattern
     file in `eos/audit/`, with comment naming the lesson ID.

4. **Commit and push.** One commit per logical update is fine;
   batched commits also fine. Commit messages reference the
   intake date.

5. **Mark intakes as processed.** Move each processed intake
   from `eos/lessons/intake/` to `eos/lessons/intake/processed/`.
   Or, if using the running log, append a processing date.

6. **Notify product projects of any critical updates.** For most
   updates, products pull at next phase kickoff (default).
   For critical updates (a new policy-driven pattern, a
   security-relevant standard change), the operator manually
   notifies the relevant product projects so they sync
   immediately.

**What "good" looks like:**

The first review of a month with 4 intakes might yield:
- 2 intakes had "no change" — filed, no action.
- 1 intake updated the Firebase checklist by adding one item.
- 1 intake surfaced a new cross-cutting pattern (third lesson
  on the same theme) and triggered a new HQ STANDARDS section.

Wall-clock: ~30-60 minutes for a month with 4 intakes.

**What "bad" looks like:**

Reading intakes, nodding, not updating anything. The intakes
exist but the standards don't change. After 6 months, the
inventory has 50 intakes and the checklists are unchanged.
This is the failure mode the protocol exists to prevent.

**Failure mode if skipped.** Lessons accumulate; standards don't
move. The cycle breaks at the update side. After a few cycles,
products are pulling the same stale standards every phase, and
the system is paperwork.

---

## Discipline self-check (every review)

The operator asks three questions at the end of every monthly
review:

1. **Are we accumulating intakes that aren't moving anything?**
   If yes: either the intakes aren't actionable (Checkpoint 2
   discipline gap) or the operator is reading without updating
   (Checkpoint 4 discipline gap). Address whichever.

2. **Are intakes reaching HQ on every phase close?** Spot-check
   recent product phase logs. If a phase closed but no intake
   exists in `eos/lessons/intake/`, Checkpoint 3 was skipped.
   Address with the operator.

3. **Are products pulling current standards?** Check the
   HQ STANDARDS version stamp at the top of each active
   product's CLAUDE.md. If any are >1 minor version behind
   current, the next phase kickoff for that product needs an
   adoption check.

These three questions are the closest thing the system has to
self-monitoring until automation arrives. Not skipped.

---

## Future automation hooks

Per the EOS Operating Manual Section 7, automation comes after
the manual process is stable across 2-3 projects. The intake
protocol's automation hooks:

| Future agent | Replaces | Trigger |
|---|---|---|
| **Postmortem extractor** | Manual draft of the 5-line intake | Phase close, when phase log is finalized. Extracts a draft from the phase log; operator confirms or revises. |
| **Standards-update agent** | Manual identification of which checklist or standard to update | Monthly review. Reads new intakes, proposes specific edits to specific files, operator approves before commit. |
| **Standards-sync agent** | Manual pull of HQ STANDARDS at phase kickoff | Phase kickoff. Verifies the product's HQ STANDARDS version against current HQ; flags drift. |

None of these get built until the manual process has run through
2-3 monthly review cycles. The friction in manual operation is
itself information about what the agents need to handle.

---

## What this protocol does NOT cover

- **The substance of any specific lesson.** Lessons are recorded
  as the operator and AI collaborators experience them; this
  protocol describes the path they travel, not what they say.
- **Format negotiations.** The 5-line intake format is fixed.
  Adding lines, sub-bullets, or attachments fights the
  constraint. If a lesson genuinely needs more context, attach
  a separate document — the intake itself stays 5 lines.
- **Cross-project lessons that span multiple products in one
  phase.** Rare. When it happens, file separate intakes (one
  per product) with cross-references.

---

*Source-of-truth intake protocol. Maintained in
`rore-tech-hq/eos/lessons/INTAKE_PROTOCOL.md`. v0.1 derived from
HQ STANDARDS H6 / H8 and the act of compiling the cross-project
inventory v0.1.*
