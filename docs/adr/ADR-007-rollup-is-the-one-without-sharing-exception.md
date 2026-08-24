# ADR-007: The Task roll-up is the single deliberate `without sharing` exception

## Status

**Accepted**

## Date

2026-05-20

## Author

Mustafa Aksu

## Context

Every class in this project that touches data is `with sharing` and queries
`WITH USER_MODE`. That posture is deliberate and it is tested — one test runs as
a user holding the permission set and nothing else.

The Task roll-up cannot join it. `Opportunity.Score__c` and
`Completed_Task__c` hold the total and completed Task counts for the record. If
the roll-up counted only the Tasks the *saving user* can see, the number written
to the Opportunity would depend on who happened to save last.

That is not a security boundary being respected. It is a stored field becoming
non-deterministic, and every report built on it becoming wrong.

## Decision

`TaskSelector` and `TaskTriggerHelper` are **`without sharing`**, and nothing
else in the project is.

The reasoning is written **in each class header**, not in a commit message and
not only here, so the exception cannot be mistaken for an oversight by someone
reading the file on its own.

The scope is deliberately narrow: the exception covers counting Tasks for the
roll-up. It does not extend to returning Task data to a user.

## Alternatives Considered

- **`with sharing` and accept per-user counts.** Rejected: a stored aggregate
  whose value depends on the saver is worse than no aggregate.
- **Recalculate asynchronously as an integration user.** Workable, and it adds a
  job, a user and a delay to solve what one declaration solves synchronously.
- **Compute the count at read time in a controller.** Rejected: it cannot be
  sorted or reported on, which is the reason the field exists.

## Consequences

- The counts are a property of the record rather than of the reader.
- The project has exactly one sharing exception, so "is this class `with
  sharing`?" has a default answer and one documented deviation.
- The `without sharing` declaration must not spread. Keeping it to two classes
  is why it is recorded at this length.

## References

- `force-app/main/default/classes/TaskSelector.cls`, `TaskTriggerHelper.cls` — class headers
- `EichrechtBerechtigungTest.cls` — the counterpart proving the default posture
