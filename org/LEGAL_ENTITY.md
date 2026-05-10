# Legal Entity — Canonical Facts

> **What this is.** The single source of truth for RORE Tech's
> legal entity facts. Every legal page on every product
> references values from this file — never restates them.
> Drift between this file and any product's legal pages is a
> compliance gap caught by the `deprecated-strings.txt` audit.
>
> **Authority.** This file is canonical at HQ. When entity facts
> change (entity-type election, address change, governing law
> change), this file is updated *first* and the change flows to
> products via the standard cycle.
>
> **Lesson trace.** HQ STANDARDS H9. Derived from
> `roretech-website-LL-008` (Delaware vs Massachusetts drift)
> and `roretech-website-LL-009` (product naming drift).

---

## Entity facts

| Field | Value |
|---|---|
| **Legal name** | RORE Tech LLC |
| **Trade name (display, ™)** | RORE Tech™ |
| **Entity type** | Single-member LLC |
| **State of formation** | Massachusetts, USA |
| **Tax classification** | Disregarded entity (default; income on owner's Schedule C / Form 1040). Form 8832 not filed. |
| **Governing law for ToS / Privacy / contracts** | Massachusetts |
| **Fiscal year end** | December 31 |
| **EIN** | [On file separately — referenced when needed] |
| **D-U-N-S** | [Pending application as of 2026-05-10 — update when issued] |

---

## Addresses

### Mailing / business address

[Operator to fill — non-residential. Used for:]
- Play Console developer profile (public-facing).
- App Store Connect developer profile (public-facing when iOS launches).
- Business registrations and forms.
- Customer support correspondence.

> **Why non-residential.** Per `roretech-website-LL-014`, public
> developer addresses are indexed alongside paid apps. Use
> registered LLC address, registered agent, mail forwarding,
> or UPS Store mailbox. Do not use a personal home address.

### Registered agent

[Operator to fill — for Massachusetts LLC service of process.]

---

## Tax forms — canonical answers

> Used when filling W-9 (Play Console payments), W-8BEN-E
> (international), or equivalent for any payments service.

For **single-member disregarded LLC** (RORE Tech LLC's current
status):

| W-9 field | Value |
|---|---|
| Line 1 (Name) | [Operator's personal legal name] |
| Line 2 (Business name) | RORE Tech LLC |
| Line 3 (Federal tax classification) | "Individual/sole proprietor or single-member LLC" |
| TIN | [Operator's personal SSN — NOT the LLC's EIN] |

> **Why SSN, not EIN.** Per `securityspy-LL-020`. For tax
> purposes, a single-member LLC is a disregarded entity by
> default; income is reported on the owner's personal return;
> TIN matching at the IRS uses the personal SSN. Entering the
> EIN triggers a TIN-name mismatch and forces manual ID
> verification. If RORE Tech ever elects S-Corp taxation (via
> Form 8832 / Form 2553), this changes — update this file at
> that time.

---

## Trademark

| Mark | Status | Classes | Notes |
|---|---|---|---|
| RORE Tech | Application pending (USPTO) | International Class 9 (downloadable software, apps, security software), International Class 42 (SaaS, software design and development services) | Use ™ symbol, not ®, until registration issues. Watch for USPTO office actions during examination — strict response deadlines (typically 3-6 months); missed response abandons the application. |

---

## What this file is NOT

- **Not a legal document.** It's a reference for canonical facts.
  Actual legal documents (Operating Agreement, Articles of
  Organization, etc.) live with the operator's attorney and in
  secure storage.
- **Not the source for legal advice.** When real legal questions
  arise, consult a Massachusetts attorney familiar with
  single-member LLCs.
- **Not the place to put credentials.** EIN and SSN are
  referenced as fields here, but actual values live in a
  password manager, not in this file.

---

## Open items related to legal entity

These flow from `RORE_TECH_ORG.md` Section 9. Update both files
when any item resolves.

1. **Governing law mismatch correction.** Some legal pages on
   product sites still reference Delaware. All occurrences must
   be replaced with Massachusetts. The
   `eos/audit/deprecated-strings.txt` audit pattern catches new
   occurrences; existing ones need a one-time fix pass.

2. **D-U-N-S issuance.** When D-U-N-S issues, update this file
   and `RORE_TECH_ORG.md`. May enable Play Console Organization
   account upgrade and Apple Developer enrollment.

3. **Trademark registration.** When RORE Tech mark registers,
   change ™ to ® in product copy and store listings.

---

*Canonical entity facts. Maintained in
`rore-tech-hq/org/LEGAL_ENTITY.md`. Last updated: 2026-05-10
(initial draft).*
