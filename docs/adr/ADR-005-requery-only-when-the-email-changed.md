# ADR-005: On update, the trigger re-queries only when the matching field actually changed

## Status

**Accepted**

## Date

2026-05-05

## Author

Mustafa Aksu

## Context

The Opportunity trigger runs on every update. Most updates have nothing to do
with the reseller — a stage change, an amount edit, a close-date shift — and a
naive handler re-runs the match every time.

At one record that is invisible. At a 200-record data load it is a query and a
match per record for a field nobody touched, and the governor limit is the thing
that notices first.

## Decision

Compare against `Trigger.oldMap` and re-resolve only when
`Reseller_Email__c` has actually changed:

- unchanged email → no query, lookup preserved
- changed email → re-match
- cleared email → lookup cleared

Editing an unrelated field therefore adds **zero SOQL**.

## Alternatives Considered

- **Always re-match.** Rejected: pays the full cost on every unrelated edit.
- **Skip updates entirely, match only on insert.** Rejected: the lookup would go
  stale the first time a rep corrected a typo in the email.
- **A Boolean "needs rematch" flag maintained by a formula.** Rejected: another
  field to explain, holding information `Trigger.oldMap` already carries.

## Consequences

- Bulk updates that do not touch the email are free.
- The three cases are explicit branches, and each has its own test — including
  the one that is easy to forget, where clearing the email must clear the lookup
  rather than leave a stale partner attached.
- The handler now depends on `Trigger.oldMap`, so the logic that reads it lives
  in the handler and the pure matching stays in the helper.

## References

- `force-app/main/default/classes/OpportunityTriggerHandler.cls`
- `OpportunityTriggerHandlerTest` — update-path cases
