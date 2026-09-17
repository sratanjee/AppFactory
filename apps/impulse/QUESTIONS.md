# Impulse — open questions

## Notifications (spec §5, deferred by spec)

Spec §5 explicitly says:
> "If factory core has no notifications subsystem, ship without and log it in QUESTIONS.md; do not build a subsystem for this app."

`packages/core` has no notifications subsystem as of scaffold time. Local per-item notifications ("*Name* is ready to decide.") are **not shipped**. To close this:

- Add a `notifications` subsystem to `packages/core` covering iOS `UNUserNotificationCenter` + Android `NotificationManagerCompat`, with permission gating and a scheduled-notification API.
- Wire per-item scheduling in `ItemsRepo.insert` and cancellation in `ItemsRepo.decide` / delete.

## Deferred UX slices

Not built in this run — will land in a follow-up build once the golden path is verified on both simulators.

- History screen with monthly subtotals + free-tier 30-day cutoff triggering paywall.
- Settings screen (currency override, reminders toggle, CSV export, Reset all data with double confirm).
- Item detail sheet with locked-state countdown + delete overflow.
- Skipped-number count-up animation (~600ms per spec §8). Currently jumps to the new value.
- Countdowns on Waiting-list rows tick per minute.
