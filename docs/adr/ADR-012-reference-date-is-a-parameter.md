# ADR-012: The reference date is a parameter, never `TODAY()`

## Status

**Accepted**

## Date

2026-08-19

## Author

Mustafa Aksu

## Context

Every calculation in the engine is a comparison against a date: has the
calibration expired, is the re-calibration window open, was this lawful at the
time. The obvious source for "now" is `TODAY()` or `System.today()`.

That makes the engine a function of the wall clock, with two consequences. A
test cannot assert the last lawful day and the first unlawful one on the same
records, because the answer changes overnight. And an audit cannot reproduce
what the engine said in March, because March is gone.

## Decision

The reference date is a **parameter** on every entry point into
`EichrechtService`. Nothing inside the engine reads the clock.

The same facts always produce the same answer.

## Alternatives Considered

- **`System.today()` inside the engine.** Rejected: untestable at boundaries and
  unreproducible after the fact.
- **A settable static for tests only.** Rejected: it makes the engine testable
  and leaves production non-reproducible, which is the half that matters for an
  audit.
- **Store the evaluation date on the record and read it back.** Complementary,
  not alternative — the batch does record when it ran. It does not remove the
  need for the engine itself to be a pure function of its inputs.

## Consequences

- A test asserts **the last lawful day and the first unlawful day on identical
  records**, which is not possible against a clock.
- An audit can ask what the engine said on a given date and get the answer by
  passing that date.
- Every caller must supply a date, including the batch. That is the intended
  friction: "as of when" becomes an explicit part of every question.
- Determinism here is what makes the transcript gate meaningful — a
  non-deterministic engine would make a citation check unstable for reasons
  unrelated to the agent.

## References

- `force-app/main/default/classes/EichrechtService.cls`
- `force-app/main/default/classes/EichrechtBatch.cls`
