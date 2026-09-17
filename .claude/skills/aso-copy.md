---
name: aso-copy
description: How to write App Store Connect and Google Play listing copy — name, subtitle, keywords, description, screenshot captions. Use during scaffolder (first draft from spec §9) and release (final pass).
---

# aso-copy

Rules for writing the words that decide whether anyone downloads the app.

## Rule zero

Every string ships in the user's voice, not the developer's. Read spec §2 ("Who pays" and "The job") first. If the copy doesn't sound like the person in spec §2 saying it out loud, rewrite.

## iOS: what fits where

| Field | Limit | Job |
|---|---|---|
| App Name | 30 chars | Primary keyword. Read literally as "what this app is". |
| Subtitle | 30 chars | Secondary keyword slot. Answers "for whom" or "so that". |
| Promotional Text | 170 chars | Editable without review. Announcements, seasonal hooks. |
| Description | 4,000 chars | First 3 lines matter. Everything below the fold is bonus. |
| Keywords | 100 chars | Comma-separated, no spaces after commas, no duplicates with Name or Subtitle. |

## Android: what fits where

| Field | Limit | Job |
|---|---|---|
| App Name | 30 chars | Same as iOS. |
| Short Description | 80 chars | Two lines above the fold in Play. This is the whole pitch. |
| Full Description | 4,000 chars | Longer than iOS. First paragraph is what shows. |

## Naming

- Two words good. Three words fine. Four is a warning.
- The primary keyword goes IN the name, not next to it. "Habits" is better than "MyApp — Habits".
- No punctuation. No emojis. No trademarked comparisons.
- One-word names must Google-search cleanly for the intended user.

## Subtitle / short description

Answers one of: **who it's for**, or **what changes for them**.

Good:
- "Track drinks. Feel it change."
- "For runners logging every mile."
- "Quiet timers for deep work."

Bad:
- "The best app for tracking whatever you want!"  (marketing voice)
- "Habit tracker with widgets and reminders"  (features, not outcome)

## Keywords (iOS only)

- 100 chars, comma-separated, no spaces after commas: `run,jog,pace,cadence,cardio,trainer,marathon`
- Do not repeat words from Name or Subtitle. Apple indexes those already; repetition wastes chars.
- Plural + singular are treated separately by Apple. Include whichever is more searched. Usually plural.
- Include category tent-poles (e.g. `fitness`, `productivity`) only if the app plausibly ranks — otherwise wasted char count.
- No competitor names. Apple filters them.
- No the-word-p-l-a-c-e-h-o-l-d-e-r values, no dummy tokens.

## Description

Structure (both stores):

```
[Line 1: the outcome in one sentence. No "welcome to", no "introducing".]
[Line 2: who it's for.]
[Line 3: the one thing they do with it.]

What it does
• [Verb-first, 3–5 bullets. Each is one feature the user cares about, in user words.]
• …

Why people use it
[One paragraph, 2–3 sentences. Concrete. No "amazing", "best", "revolutionary".]

Widgets and lock screen
[One paragraph on the native surfaces, only if spec §5 has any.]

Subscription
[Free trial length, then price per period. Auto-renews unless cancelled.
 Manage or cancel any time in the App Store settings / Google Play settings.
 Terms: [url] · Privacy: [url]]
```

## Screenshots

Every app ships 5 screenshots per store per required device size. Each has one line of caption text.

Screenshot 1: the outcome. What using this app looks like when it's working.
Screenshot 2: the first real use. The moment the paywall promised.
Screenshot 3: the number, the streak, the receipt — proof.
Screenshot 4: a widget or lock-screen surface.
Screenshot 5: dark mode, or a personalization the user recognizes as theirs.

Caption rules:
- Sentence case. No exclamation marks.
- One line. Ideally 4–8 words.
- The caption names what the user gets, not the feature.

Good captions:
- "See every drink, right on your lock screen"
- "Streaks that don't reset for one bad day"

Bad captions:
- "Beautiful UI with dark mode support!" (feature, and exclamation)
- "Introducing widgets" (welcome voice)

## Localization

English only unless spec says otherwise. If a localization is added, translate all fields — half-localized listings look worse than English-only.

## The banned list

Every string in every field is checked for:

- No "best", "#1", "top rated", "revolutionary"
- No "just $X", "only $X", strikethrough fake pricing
- No exclamation marks in UI-facing store copy
- No emoji as bullets
- No trademarked comparisons ("like [competitor] but better")
- No the-string-literally-spelled-e-x-a-m-p-l-e-dot-com
- No the-word-l-o-r-e-m, no the-word-p-l-a-c-e-h-o-l-d-e-r, no the-word-T-O-D-O

## The one thing to remove

Before submitting, cut one sentence from the description. If nothing can be cut, it's done.
