# SEO Triage Runbook

> **What this is.** A reference card for the moment you open Google
> Search Console and see a list of "errors" or "warnings." Most of
> them are correct behavior or scanner noise. Some need action.
> Without a triage frame, every line reads as a defect to fix and
> 30+ minutes vanish per encounter.
>
> **When to use.** Any time Search Console reports a "Page indexing"
> issue, a "Coverage" warning, or a "Page experience" flag. Open
> this file before treating anything as a bug.
>
> **Lesson trace.** `roretech-website-LL-012`. Compiled from the
> May 2026 post-launch SEO audit on roretech.com.

---

## The frame: three categories

Every Search Console signal falls into one of three buckets.
Identify the bucket first, then act.

| Bucket | What it means | Action |
|---|---|---|
| **Correct behavior** | Search Console is reporting an outcome that is the *intended* outcome. The system is working as designed. | Dismiss in Search Console, or add a `<link rel="canonical">` to make the canonicalization explicit. No code change needed. |
| **Scanner noise** | A vulnerability scanner or bot probed an endpoint that doesn't exist. Server returned 404. Search Console treats this as a coverage gap. | Ignore. The 404 is correct. |
| **Real defect** | A page that should be indexed isn't, or a page that should redirect doesn't, or content is genuinely missing. | Investigate. May require code or content change. |

Most signals are "Correct behavior" or "Scanner noise." Real
defects are rare on a small static site.

---

## Common signals — classified

### "Page with redirect" — Correct behavior

**What you see in Search Console:** Coverage report shows URLs
like:
- `http://roretech.com/`
- `http://www.roretech.com/`
- `https://www.roretech.com/`

flagged as "Page with redirect — not indexed."

**What's happening:** All three are 301-redirecting to the
canonical `https://roretech.com/`. This is correct behavior — you
*want* one canonical version of the homepage, not four. Google
correctly chose to index the canonical version and is reporting
that the others were redirected.

**Action:**
1. Confirm the canonical URL is indexed (it is, in the same report).
2. Optional: add `<link rel="canonical" href="https://roretech.com/">`
   to the homepage to make canonicalization explicit, which
   sometimes silences the warning.
3. Dismiss in Search Console if the warning persists.

---

### "Not found (404)" on `/index.php`, `/wp-admin`, `/admin.php` — Scanner noise

**What you see in Search Console:** Coverage report shows URLs
like:
- `roretech.com/index.php`
- `roretech.com/wp-admin/`
- `roretech.com/admin.php`

flagged as "Not found (404)."

**What's happening:** The site is not WordPress, doesn't run PHP,
and doesn't have an admin path. Vulnerability scanners (and
sometimes search bots) probe common attack-surface URLs. The
server correctly returns 404. Search Console reports the 404 as a
"coverage issue" without classifying it as scanner-driven.

**Action:** Ignore. The 404 is correct behavior. Do *not* create
those pages. Do *not* return 200 from them. The 404 is the
desired response.

---

### "Page is not indexed: Discovered – currently not indexed" — Probably correct, sometimes real

**What you see in Search Console:** A specific URL is listed as
"Discovered – currently not indexed." Google found the URL but
hasn't indexed it.

**What's happening — most common cause:** The URL is new and
Google hasn't crawled it yet. New pages take 1-7 days to index
even when discoverable.

**Action — most common cause:**
1. Wait. Re-check after 7 days.
2. If still not indexed: request indexing manually via Search
   Console → URL Inspection → Request indexing.

**What's happening — less common cause:** The URL is duplicate
content (same as another indexed page) and Google chose not to
index this version.

**Action — less common cause:** Verify the duplicate. Add
`<link rel="canonical">` pointing to the version Google should
index.

**What's happening — rare cause:** The URL has a `noindex` meta
tag. (This is a real defect if the page should be indexed.)

**Action — rare cause:** Remove the `noindex` if unintended.

---

### "Crawled – currently not indexed" — Probably real

**What you see in Search Console:** A specific URL is listed as
"Crawled – currently not indexed." Google crawled the URL but
chose not to add it to the index.

**What's happening:** Google evaluated the page and decided it
isn't worth indexing. Common reasons: thin content, near-duplicate
of another page, low quality signals, missing canonical tag with
a similar page already indexed.

**Action:**
1. Check the page in URL Inspection → Test live URL.
2. If thin/duplicate: the page genuinely isn't index-worthy as is;
   improve content or remove.
3. If unique and substantive: add Open Graph metadata, structured
   data, or improve internal linking. Re-request indexing.

This one is more often a real defect than the others.

---

### "Soft 404" — Real defect

**What you see in Search Console:** Page returns HTTP 200 but
Google decided it looks like a 404 (empty content, "Not found"
text, etc.).

**What's happening:** Either the page is genuinely empty (a real
defect — the page should serve content) or the page returns 200
when it should return 404 (placeholder/coming-soon pages without
proper status codes are common offenders).

**Action:**
1. Visit the URL in a browser. Does it look like content?
2. If empty/coming-soon: change the status to 404 (preferred) or
   add real content.
3. If it looks fine: check for client-side rendering that delays
   content load past Google's render budget.

---

### "Discovered – currently not indexed" specifically for category/index pages — Probably correct

**What you see in Search Console:** A category index, archive
page, or auto-generated list (e.g., a tag page) shows as
discovered-not-indexed.

**What's happening:** Google de-prioritizes index/archive pages
that don't add unique value over the underlying content pages.
This is a deliberate Google ranking decision, not a defect.

**Action:** Usually no action. If the index page genuinely matters
(e.g., it's the canonical landing page for a category): add
unique content to differentiate it from the items it links to.

---

### "Mobile usability: Text too small" / "Clickable elements too close" — Real

**Action:** These are real. Fix the CSS. Mobile usability is a
ranking factor.

---

### "Core Web Vitals: LCP / CLS / FID issues" — Real, possibly

**What you see:** Pages flagged for poor Core Web Vitals scores
(Largest Contentful Paint, Cumulative Layout Shift, First Input
Delay / Interaction to Next Paint).

**What's happening:** Google measured page-load metrics from real
users and flagged the page as slow or janky.

**Action:**
1. Check whether the metrics come from "lab data" (synthetic test)
   or "field data" (real users). Field data wins.
2. If field data: investigate the specific metric. LCP is usually
   image loading; CLS is usually layout shift from late-loading
   ads, fonts, or iframes; FID/INP is usually heavy JavaScript on
   first interaction.
3. Pages with low traffic may not have enough field data to
   trigger the warning *or* to fix it. In that case, lab data is
   the fallback; treat as advisory.

---

## When to make canonicalization explicit

Several signals above resolve when you add proper canonical tags.
The standard pattern:

```html
<link rel="canonical" href="https://roretech.com/page-name.html">
```

Add to `<head>` of every indexable page. The canonical URL is the
*one* version of the page that Google should index — every
variant (http, www, trailing-slash, query-param) points to the
same canonical.

For RORE Tech specifically: every product page, every legal page,
and the homepage all need explicit canonicals. Without them,
Google chooses; with them, you choose.

---

## When to use `robots.txt` vs `<meta name="robots">` vs `noindex`

| Goal | Mechanism |
|---|---|
| Block crawling entirely (Google never sees the page) | `robots.txt` |
| Allow crawling but exclude from index | `<meta name="robots" content="noindex">` |
| Block specific bots (e.g., AI scrapers) | `robots.txt` per-User-Agent |
| Block a specific page from being indexed | `noindex` meta tag |

Common mistake: blocking a page in `robots.txt` to "deindex" it.
That doesn't work — Google can't read the `noindex` if it can't
crawl. Use `noindex`, then add `robots.txt` block later if needed.

---

## What's intentionally not in this runbook

- **Schema.org / structured data implementation.** That's a
  longer topic; if it becomes important, it gets its own runbook.
- **Backlink strategy, content marketing, keyword research.** Out
  of scope. This is for triaging Search Console signals, not for
  SEO strategy.
- **Bing Webmaster Tools, Yandex, etc.** Same triage frame
  applies, but the specific signal names differ. If the operator
  uses other webmaster tools, this runbook gets a parallel
  section.

---

*Source-of-truth runbook. Maintained in
`rore-tech-hq/eos/runbooks/SEO_TRIAGE.md`. v0.1 derived from the
May 2026 roretech.com SEO audit (`roretech-website-LL-012`).*
