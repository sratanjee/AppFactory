---
description: Run /build-app on every spec in specs/00-QUEUE.md order, stop on any QUESTIONS.md, move finished specs to specs/done/.
---

# /run-queue

Execute the eight-spec queue defined in `specs/00-QUEUE.md`. Runs `/build-app` per spec in order, stops the whole run if any spec produces `apps/<slug>/QUESTIONS.md`, and moves completed specs to `specs/done/`.

## Prep

1. Verify `specs/00-QUEUE.md` exists. If not, **STOP** and report.
2. Verify the working tree is clean and you're on `main`. If not, ask the user before proceeding — the queue creates one branch per spec.
3. Verify `specs/done/` exists; create it if missing.

## Parse the queue

Read `specs/00-QUEUE.md` and extract the ordered spec filenames from the table under `## Order`. The table's first column is a slot number; the second column is the spec filename in backticks. Only include specs where the file exists at `specs/<filename>`.

Print the parsed order back to the user in one line each:

```
1. 01-wash-quote.md
2. 02-seizure-log.md
…
```

## Per-spec loop

For each spec in order:

1. Announce: `→ Running /build-app on specs/<filename> (slot N of M)`.
2. Invoke the `/build-app` slash command with the spec path.
3. After it returns:
   - If `apps/<slug>/QUESTIONS.md` exists: **STOP** the whole queue. Report which spec, which questions. Do not continue to the next slot. Do not move any specs.
   - If `apps/<slug>/REVIEW.md` contains `"Pass. Ship this."` OR `"Released to TestFlight"`: consider this spec done.
     - `git mv specs/<filename> specs/done/<filename>` on `main`.
     - Commit: `queue: mark <slug> done, move spec to specs/done/`.
   - Otherwise (build-app halted somewhere in the middle without QUESTIONS.md): **STOP** the queue and report the state of `apps/<slug>/REVIEW.md`.

## Report

At the end, print a summary:
- Slots completed: N
- Slots stopped on: (which, why)
- Slots not attempted: (list)

## Rules

- Never edit spec files.
- Never modify `specs/00-QUEUE.md`.
- If the user passes an argument like `--from 3`, start at slot 3 (skipping 1 and 2 as if already done).
- If the user passes `--only 2,3,5`, run only those slots in order.
- Never run more than one spec's build-app concurrently — sequential only.
