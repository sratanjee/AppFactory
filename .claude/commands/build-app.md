---
description: Build one factory app end-to-end from a spec through the 7-agent pipeline.
argument-hint: <spec-file>
---

# /build-app

Build the factory app whose spec is at `$ARGUMENTS`. Run the pipeline in order. Between steps, stop and report to me if any gate condition fires (planner writes QUESTIONS, any step fails verification, reviewer exhausts rounds, release blocker).

## Prep, before any subagent

1. Read the spec at `$ARGUMENTS` and extract the slug from §1.
2. Confirm `apps/<slug>/` does not already exist. If it does, ask me before proceeding.
3. Confirm you are on `main` with a clean working tree; the scaffolder will branch off from here.

## Pipeline

### Step 1 — planner
Launch the `planner` subagent with the prompt: `"Plan the factory app for the spec at $ARGUMENTS. Follow your read-first list, then produce apps/<slug>/PLAN.md or apps/<slug>/QUESTIONS.md."`

Gate:
- If `apps/<slug>/QUESTIONS.md` exists after the run: **STOP**. Print the questions verbatim and wait for me. Do not run the scaffolder.
- If `apps/<slug>/PLAN.md` exists: continue.

### Step 2 — scaffolder
Launch the `scaffolder` subagent with the prompt: `"Scaffold apps/<slug>/ from the spec at $ARGUMENTS and its PLAN.md. Create the app/<slug> branch and make the initial commit."`

Gate: verify `apps/<slug>/pubspec.yaml`, `apps/<slug>/lib/main.dart`, and the `app/<slug>` branch exist. If not, **STOP** and report.

### Step 3 — builder
Launch the `builder` subagent with the prompt: `"Implement the app from apps/<slug>/PLAN.md §8. Run flutter analyze and flutter test after every task and commit on app/<slug>."`

Gate: run `fvm flutter analyze` and `fvm flutter test` in `apps/<slug>/`. If either isn't clean/green, **STOP** and report.

### Step 4 — native-builder
Launch the `native-builder` subagent with the prompt: `"Implement the native surfaces from spec §5 and apps/<slug>/PLAN.md §9. Build clean on iOS Simulator and Android emulator."`

Gate: verify iOS and Android builds succeed. If either fails, **STOP** and report.

### Step 5 — tester
Launch the `tester` subagent with the prompt: `"Test the app and produce the full screenshot matrix at apps/<slug>/qa/. Do not touch lib/."`

Gate: verify `apps/<slug>/qa/` contains the full matrix and integration tests are green on both platforms. If not, **STOP** and report.

### Step 6 — reviewer loop (max 3 rounds)
For round in 1, 2, 3:

1. Launch the `reviewer` subagent, **fresh context every round**, with the prompt: `"Review the factory app in apps/<slug>/ for the spec at $ARGUMENTS. Follow the fresh-context protocol. Update apps/<slug>/REVIEW.md. This is round <N> of 3."`
2. Read `apps/<slug>/REVIEW.md`.
3. If it contains `"Pass. Ship this."`: break out of the loop, continue to release.
4. If it contains `"Not shipped."`: launch the `builder` subagent with the blockers as its task list. Then loop to the next round.

If round 3 ends without a pass: write `"Pipeline stop — human required"` to `apps/<slug>/REVIEW.md` and **STOP**.

### Step 7 — release
Launch the `release` subagent with the prompt: `"Release apps/<slug>/ to TestFlight and Play internal testing. REVIEW.md is signed off."`

Gate: verify TestFlight and Play internal builds succeed via Codemagic. On success, report both build links to me and finish.

## Rules for the orchestrator
- Never skip a step. Never reorder.
- Report each step's start ("Step N: <agent> starting") and completion ("Step N: <agent> done") in one line each.
- If any subagent takes more than 30 minutes, check for progress and report.
- Do not edit `apps/<slug>/` yourself. That is the subagents' job.
