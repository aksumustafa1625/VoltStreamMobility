# ADR-011: The formula field stays, even where it is knowingly wrong

## Status

**Accepted**

## Date

2026-08-21

## Author

Mustafa Aksu

## Context

`Ladepunkt__c.Eichstatus__c` is a formula field holding legal status. It is
**knowingly one year too generous for a late re-calibration** — a chronology a
formula cannot express, and the reason `EichrechtService` exists in Apex.

The tidy response is to delete a field that is wrong in a known case.

## Decision

**Keep it.** A legal status visible in a list view, without running an agent and
without running a test, is the whole thesis of the project. A reviewer sorts a
column and sees the estate.

Three things make keeping it honest rather than sloppy:

1. **Where the layers differ, the engine is the authority.** Stated, not implied.
2. **The field descriptions have said so since the model was deployed** — a user
   reading the field in Setup learns the limit without reading this repository.
3. **A test names the divergence.** `EichrechtKonsistenzTest` asserts that two
   specific cases **still** diverge. If someone "fixes" the formula, that test
   fails and the fix is discussed rather than silently absorbed.

## Alternatives Considered

- **Delete the formula, expose status only through Apex.** Rejected: it destroys
  the property that makes the compliance state legible without executing
  anything, which is the feature.
- **Make the formula exactly right.** Attempted and abandoned: the chronology
  needs conditional date arithmetic across provisions that a formula cannot
  express. This is a platform limit, not a lack of effort.
- **Leave the divergence undocumented.** Rejected: a wrong field nobody has
  written down is indistinguishable from a bug.
- **A comment in the class explaining it.** Rejected as insufficient — a comment
  does not fail. A test does.

## Consequences

- Compliance state is visible in a list view with zero execution.
- The known-wrong case is asserted rather than mentioned, so it cannot be
  accidentally repaired without a conversation.
- Two layers must be kept in agreement everywhere they are *supposed* to agree,
  which is what the consistency test is for.
- The project ships a knowingly imperfect field and says so in three places.
  That is the cost of the legibility, paid openly.

## References

- `force-app/main/default/objects/Ladepunkt__c/fields/Eichstatus__c.field-meta.xml`
- `force-app/main/default/classes/EichrechtKonsistenzTest.cls`
