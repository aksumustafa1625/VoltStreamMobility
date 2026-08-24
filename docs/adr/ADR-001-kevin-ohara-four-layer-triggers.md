# ADR-001: Every trigger routes through the Kevin O'Hara framework, with a four-layer separation

## Status

**Accepted**

## Date

2026-05-05 (Phase 1)

## Author

Mustafa Aksu

## Context

Three objects carry automation: Opportunity (reseller auto-linking), Reseller
(field normalisation) and Task (roll-up onto the parent Opportunity). The Task
roll-up writes to Opportunity, which is itself an automated object — the shape
that produces recursion when nothing guards it.

Inline trigger logic does not survive three objects. Context routing, recursion
control and bypass become ad-hoc conditionals repeated per object, and the
business logic cannot be unit-tested without DML.

## Decision

Vendor **Kevin O'Hara's `sfdc-trigger-framework`** and apply four layers, not
three:

- **Trigger** — one per object, routing only. Constructs the handler, calls `.run()`.
- **Handler** — dispatches trigger contexts. No business logic.
- **Helper** — the business rules, as static methods over collections.
- **Selector** — the SOQL boundary.

The Helper layer is the one that earns its keep: because helpers take
collections and return results without touching `Trigger` context, the matching
algorithm is unit-tested with no DML at all.

## Alternatives Considered

- **Logic in the trigger body.** Rejected: untestable without DML, recursion
  control hand-rolled three times.
- **Three layers, folding Helper into Handler.** Rejected: the handler would
  then depend on trigger context, and every test of a matching rule would need
  to insert records to reach it.
- **A hand-written base class.** Rejected: it would reimplement recursion
  control, the bypass API and max-loop protection that this framework ships with
  its own tests.

## Consequences

- `TriggerHandler.bypass()` is available for data loads and for fixtures.
- Helper tests are fast and assert on logic directly; handler tests go through
  DML so the trigger actually fires. The suite is layered the same way the code is.
- The framework's own test class is carried in the repository and counts toward
  the raw test total.
- The same layout is used in the sibling `urla-shoes` and `urlashoes-sandbox`
  projects, so all three are structurally comparable.

## References

- [`sfdc-trigger-framework`](https://github.com/kevinohara80/sfdc-trigger-framework)
- `force-app/main/default/classes/TriggerHandler.cls`
- README "Design decisions"
