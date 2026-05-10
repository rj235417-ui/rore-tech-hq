# Email Infrastructure Migration Runbook

> **What this is.** Step-by-step procedure for setting up a
> business email address (`support@roretech.com`,
> `privacy@roretech.com`, etc.) on Zoho Mail with full
> deliverability — SPF, DKIM, and DMARC. Designed to be run
> once per address; reusable for future addresses with minor
> adaptation.
>
> **When to use.** First-time setup of a business email address
> for any RORE Tech product. Required before Play Console (and
> App Store) submission — the developer contact email needs to
> deliver and authenticate properly. Also useful when migrating
> from one email provider to another (e.g., from ImprovMX to
> Zoho, which is what RORE Tech actually did).
>
> **Time required.** ~45–60 minutes end-to-end, including DNS
> propagation waits. Most of the wall-clock time is waits, not
> active work.
>
> **Lesson trace.** `securityspy-LL-021`. Compiled from the May
> 2026 setup of `support@roretech.com` for Security SPY launch.
>
> **Tools assumed.** Zoho Mail account (free tier supports up to
> 5 users with custom domain). Netlify DNS as the registrar UI.
> If using a different registrar, the DNS-edit flow changes but
> the records don't.

---

## Pre-flight

Before starting, gather:

- [ ] **Domain name** (e.g., `roretech.com`) and confirmation of
  who controls its DNS.
- [ ] **Existing email setup** documented. What addresses exist?
  Where do they currently route? Will any need to be preserved
  during migration?
- [ ] **Zoho Mail admin account** created. Free tier or paid as
  appropriate.

If any existing email is in use:
- [ ] **Note any addresses that must keep receiving mail** during
  the migration. Zoho cutover is not seamless if a previous
  forwarder (ImprovMX, etc.) is in place.

---

## Why this is fiddly

Three reasons setup takes longer than expected:

1. **Multiple records, multiple verification waits.** MX, SPF,
   DKIM, DMARC each have their own record, their own
   verification step, and their own propagation wait.
2. **Netlify's DNS editor only supports delete + add, not edit.**
   Every "modify a record" operation is two operations. The
   migration involves modifying enough records that this
   doubles the work.
3. **Zoho's admin UI surfaces the records you need but doesn't
   coordinate with the registrar.** You copy values from one
   tab to another.

The runbook below sequences the work to minimize back-and-forth.

---

## Step 1 — Set up Zoho domain and primary mailbox

1.1. **Log into Zoho Mail Admin Console** at
`mailadmin.zoho.com` (region-specific: `.in`, `.eu`, etc.).

1.2. **Add the domain.** Domain → Add Domain → enter
`roretech.com`.

1.3. **Choose verification method: TXT record.** Zoho will
display a TXT record value like `zoho-verification=zb12345.zmverify.zoho.com`.

1.4. **Note this value but DO NOT add it yet.** You'll add it in
Step 3 along with everything else, in one DNS sitting.

1.5. **Decide which address(es) to create.** For RORE Tech: at
minimum `support@roretech.com`. Optional: `privacy@roretech.com`,
`security@roretech.com`, per-product variants.

1.6. **Create the primary mailbox** in the Zoho Mail Admin
Console. The primary mailbox handles the verification and is
the "source" address for outbound mail.

---

## Step 2 — Document existing DNS state (if migrating)

If the domain is new, skip to Step 3.

If migrating from another provider:

2.1. **Export current DNS state** from the registrar. Take a
screenshot or copy the records to a text file. You will be
deleting some of them.

2.2. **Identify records to remove:**
- Old MX records (e.g., ImprovMX's `mx1.improvmx.com`,
  `mx2.improvmx.com`).
- Old SPF record if it includes the previous provider.
- Old DKIM record (if any).

2.3. **Identify records to keep:**
- A / AAAA records for the website.
- CNAME records for any subdomain.
- DMARC record (will be replaced, but note the current value).
- Any verification TXTs from other services (Netlify, Google
  Search Console, etc.).

2.4. **Plan the cutover.** Mail delivery during the swap is
not reliable. Either: (a) accept ~30 minutes of bounced mail
during migration, or (b) keep both providers working in
parallel during a 24-hour overlap (more complex; usually not
worth it for low-volume email).

---

## Step 3 — DNS configuration (the longest step)

This is the step that doubles in time on Netlify because every
"edit" is delete + add. Plan to do all DNS work in one sitting.

The target end state for `roretech.com`:

| Type | Host | Value | Priority | Why |
|---|---|---|---|---|
| TXT | `@` | `zoho-verification=zb12345.zmverify.zoho.com` | — | Zoho domain verification |
| MX | `@` | `mx.zoho.com` | 10 | Primary mail server |
| MX | `@` | `mx2.zoho.com` | 20 | Secondary mail server |
| MX | `@` | `mx3.zoho.com` | 50 | Tertiary mail server |
| TXT | `@` | `v=spf1 include:zoho.com ~all` | — | SPF — sender authorization |
| TXT | `zmail._domainkey` | (Zoho-generated DKIM TXT, ~256 chars) | — | DKIM — message authentication |
| TXT | `_dmarc` | `v=DMARC1; p=quarantine; rua=mailto:postmaster@roretech.com; pct=100; aspf=r; adkim=r;` | — | DMARC — policy enforcement |

### 3.1 — Remove old records (if migrating)

Delete every record from the "records to remove" list in Step
2.2. Netlify: Domains → roretech.com → DNS → click each record
→ Delete.

### 3.2 — Add Zoho verification TXT

Type: TXT
Host: `@`
Value: `zoho-verification=zb12345.zmverify.zoho.com` (your value)

### 3.3 — Add MX records

All three. Netlify shows MX as a separate type with a Priority
field.

| Host | Value | Priority |
|---|---|---|
| `@` | `mx.zoho.com` | 10 |
| `@` | `mx2.zoho.com` | 20 |
| `@` | `mx3.zoho.com` | 50 |

### 3.4 — Add SPF TXT

Type: TXT
Host: `@`
Value: `v=spf1 include:zoho.com ~all`

If the domain sends from other services (Mailchimp, SendGrid,
etc.), the SPF record needs to include them too:
`v=spf1 include:zoho.com include:sendgrid.net ~all`

There can only be one SPF record per domain. If one already
exists for another service, modify it; don't add a second.

### 3.5 — Add DKIM TXT

Generate the DKIM record in Zoho Admin Console:
- Domain → Email Authentication → DKIM → Add Selector
- Selector name: `zmail` (or any short string)
- Zoho generates a TXT value (long, ~256 chars)

Add to DNS:
Type: TXT
Host: `zmail._domainkey` (use the selector name from above)
Value: (paste the entire Zoho-generated string, including the
`v=DKIM1;` prefix)

DKIM TXT values are long enough that some registrars require
them in quoted segments. Netlify accepts them as one string.

### 3.6 — Add DMARC TXT

Type: TXT
Host: `_dmarc`
Value:
```
v=DMARC1; p=quarantine; rua=mailto:postmaster@roretech.com; pct=100; aspf=r; adkim=r;
```

DMARC policy options:
- `p=none` — monitor only, no enforcement (recommended for first
  week to confirm DKIM/SPF are passing before enforcing).
- `p=quarantine` — failed-auth mail goes to spam (recommended
  ongoing).
- `p=reject` — failed-auth mail is rejected outright (aggressive;
  use after confirming clean reports).

`rua=mailto:...` is the address that gets DMARC aggregate reports.
Use a real address you'll check, even if rarely.

---

## Step 4 — Verification waits

After saving DNS:

4.1. **Wait 10–15 minutes** for initial propagation. DNS can take
up to 48 hours but most changes are visible within minutes.

4.2. **In Zoho Admin Console: click Verify** on the domain.
Should turn green if the verification TXT propagated.

4.3. **Test MX:** `dig MX roretech.com` from the command line.
Should return all three Zoho MX records.

4.4. **Test SPF:** `dig TXT roretech.com` should include the SPF
record.

4.5. **Test DKIM:** `dig TXT zmail._domainkey.roretech.com` should
return the long DKIM string.

4.6. **Test DMARC:** `dig TXT _dmarc.roretech.com` should return
the DMARC policy.

If any of these don't return: wait longer (up to 48 hours) and
retry. If they still don't return after 48 hours: the record
wasn't saved correctly. Re-check in Netlify.

---

## Step 5 — End-to-end mail test

5.1. **Send a test email FROM the new address TO a Gmail
account.** Use Zoho Mail web client.

5.2. **In Gmail: open the email → click ⋮ → Show original.**
Verify all three:
- `SPF: PASS`
- `DKIM: PASS`
- `DMARC: PASS`

If any show `NEUTRAL`, `FAIL`, or `SOFTFAIL`: the corresponding
record isn't right. Re-check.

5.3. **Send a test email FROM Gmail TO the new address.** Verify
it lands in the Zoho inbox.

5.4. **If forwarding is set up** (e.g., to your personal email):
verify the forward works.

---

## Step 6 — Promote primary mailbox and retire alias

If migrating from a Zoho-on-different-domain setup (e.g., the
domain was previously verified under `zohomail.com`):

6.1. **In Zoho Admin Console:** Mail Accounts → primary user →
Change primary email address. Set to the new
`support@roretech.com`.

6.2. **Add the previous `zohomail.com` address as an alias** so
existing correspondence isn't broken.

6.3. **Update Play Console** (and any other external system) to
point to the new address.

---

## Step 7 — Update Play Console (or App Store)

7.1. **Play Console → All apps → app → Store presence → Store
listing → Contact details.** Update the email address. Wait
for re-verification (Google may send a confirmation email to
the new address — clicking it activates the change).

7.2. **Play Console → Account → Developer account →
Account details.** Update the support email if different from
the listing contact.

---

## Common failure modes

### MX records returning NXDOMAIN

DNS hasn't propagated. Wait. If it persists past 4 hours, check
that the records were actually saved in Netlify (sometimes the
Save button doesn't fire visibly).

### SPF returning SOFTFAIL on Gmail's "Show original"

The SPF record uses `~all` (soft fail) instead of `-all` (hard
fail). For most cases `~all` is correct — gives some forgiveness
during migration. Switch to `-all` only after a week of clean
authentication.

### DKIM returning NEUTRAL

Two common causes:
1. The DKIM TXT record was truncated when copied to DNS (long
   strings sometimes get clipped). Re-paste the full value.
2. Mail was sent before DKIM propagated. Wait, retry.

### DMARC returning PASS but mail going to spam anyway

DMARC is one signal of many for spam scoring. New domains have
no sender reputation; recipients err toward spam until reputation
builds. Consistent volume + DKIM/SPF passing + recipients marking
"Not Spam" gradually builds reputation.

### Receiving "Sender Address Rejected: Domain not found"

The sending side's DNS lookup failed for your domain. Usually a
transient DNS issue at the sender; retry.

---

## What to put in the password manager

For `support@roretech.com` (or whichever address):
- **Account login** — Zoho Mail credentials (email + password).
- **Domain verification TXT value** — keep for reference if a
  future verification ever resets.
- **DKIM private/public key reference** — Zoho holds the private
  key; you only need the public key (the TXT value), which is
  also in DNS.

---

## What's intentionally not in this runbook

- **Custom domain on Gmail (Google Workspace).** Different
  provider, different DNS values; would warrant a separate
  runbook.
- **Multi-domain email setups.** This runbook covers one domain.
  Multi-domain (e.g., separate `journal.roretech.com`) is
  unusual at RORE Tech's current scale.
- **Email marketing / transactional email.** SendGrid, Mailgun,
  Postmark have their own DKIM/SPF setup. Out of scope here.

---

*Source-of-truth runbook. Maintained in
`rore-tech-hq/eos/runbooks/EMAIL_INFRA_MIGRATION.md`. v0.1
derived from the May 2026 setup of `support@roretech.com` for
Security SPY launch.*
