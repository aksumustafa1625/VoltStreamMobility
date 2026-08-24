# ADR-006: Test fixtures come from one factory, and every production class ships with a test

## Status

**Accepted**

## Date

2026-05-08

## Author

Mustafa Aksu

## Context

Every test needs a Reseller, an Opportunity or a Task. Written per test class,
the same construction is duplicated across the suite — and when a required field
is added to `Reseller__c`, every one of those duplicates fails and has to be
edited separately.

The second-order problem is worse: some of them get fixed with slightly
different values, and tests start passing for reasons that have drifted from
each other.

## Decision

All fixtures come from **`TestDataFactory`**. No test class re-implements the
constructor pattern. A schema change propagates through one file.

Alongside it, a rule that is not negotiable in this repository: **every
production class ships with its own `*Test.cls`.** Helpers get unit tests with
no DML; triggers and handlers get integration tests through DML so the trigger
actually fires.

## Alternatives Considered

- **Per-class fixture builders.** Rejected: the duplication is the problem.
- **`@testSetup` in each class.** Complementary rather than alternative — it
  controls *when* data is created, not *how it is shaped*.
- **Static test data files.** Rejected: they drift from the schema without
  failing until runtime.

## Consequences

- Adding a required field is a one-file change.
- The factory is a shared dependency: a careless edit breaks the whole suite at
  once, which is preferable to breaking it one class at a time over a month.
- One trap is encoded in the factory rather than rediscovered:
  `Reseller__c.Tier__c` is a read-only formula and must never be set in test
  data. That mistake cost real time before it was written down.

## References

- `force-app/main/default/classes/TestDataFactory.cls`
- README "Testing"
