# Bug Report Prompt — for Claude Code

> **What this is.** The format Claude Code sessions use for bug-fix
> work. Descriptive, not prescriptive. The format exists because
> prescriptive prompts ("change line 42 to use `startsWith`") encode
> the operator's current hypothesis — which may be wrong, which goes
> stale fast, and which produces regressions on rebuild.
> Descriptive prompts let the agent investigate and propose the
> right fix.
>
> **When to use this.** Any bug-fix session where the goal is "the
> bug is fixed" rather than "this specific edit is made." If the
> change is genuinely mechanical (rename a variable, bump a
> dependency, move a file), prescriptive is fine. Otherwise, use
> this format.
>
> **Lesson trace.** This format is HQ STANDARDS H14, derived from
> `vibespin-LL-018`, `roreedge-LL-022`, and `xagent-LL-006`.
>
> **How to use.** Copy the four sections below into the Claude
> Code prompt. Fill each one. Send.

---

## SYMPTOM

> What the user sees, on which device, with which input. Specific.
> The exact behavior, the exact error message, the exact unexpected
> output. Not "it doesn't work" — what specifically goes wrong, on
> what specifically happens.

[e.g., "On Android 15 (Pixel 9), tapping 'Send Link' on the sign-in
screen sends the email successfully, but tapping the link from the
email opens a browser tab showing 'continue URL is required for
email signin' instead of opening the app and authenticating."]

---

## HISTORY

> When did this start? What was changed in or around this code
> recently? What has already been tried? What was ruled out?

[e.g., "Worked in dev environment when tested with the Firebase
Auth Emulator. Broke when we switched to the live Firebase project
in commit abc123. We've already verified: SHA-1 + SHA-256 are in
Firebase Console, `google-services.json` matches the project ID,
the deep link is correctly registered in `AndroidManifest.xml`. We
have NOT verified: the exact `ActionCodeSettings` object being passed
to `sendSignInLinkToEmail`."]

---

## REQUIREMENT

> The invariant that must be true after the fix. What does the
> system look like when this is fixed correctly? Stated as a
> behavior, not as an implementation detail.

[e.g., "Tapping the magic-link email on a Pixel 9 must open the
app (not the browser), authenticate the user, and land on the
post-auth screen. The same flow must work whether the user is
already running the app, has it backgrounded, or is launching it
fresh from the email."]

---

## ACCEPTANCE TEST

> The specific check that confirms the fix. What does the operator
> do or look at to know the fix is real? Reproducible. Concrete.

[e.g., "On a clean install of the Pixel 9 (uninstall app first),
launch app → enter email → tap 'Send Link' → check email arrives in
30s → tap link from email → app opens (not browser) → app shows
'Welcome [email]' on the post-auth screen. Repeat after killing the
app. Repeat after rebooting the device."]

---

## (Optional) CONSTRAINTS

> Anything that constrains the fix shape. "Don't add a new
> dependency." "The fix must work without changing the package
> name." "Cannot touch `/games/vibespinner/` (live PWA)."
> Constraints get their own section so the agent can call them
> out if proposed fixes would violate them.

[List, or "none"]

---

## (Optional) ROUNDTABLE NOTE

> If this bug-fix touches a regulated surface, a privacy commitment,
> or a platform-policy area, summon the relevant chairs in the
> session ("Compliance + Engineering only on this") so the fix is
> reviewed before merge. Specify the summons here.

[e.g., "Compliance + User Advocate only on this — the fix may
touch the AI Consent modal flow."]

---

*Bug Report Prompt v0.1. Sourced from
`rore-tech-hq/eos/templates/BUG_REPORT_PROMPT.md`.*
