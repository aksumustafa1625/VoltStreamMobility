# ADR-015: The gate's granularity is stated, not implied

## Status

**Accepted**

## Date

2026-08-20

## Author

Mustafa Aksu

## Context

The transcript gate (ADR-010) matches citations at **paragraph and statute
level**. It catches an invented paragraph and a repealed ordinance. It does
**not** catch a wrong `Absatz` inside a correct paragraph.

There is a strong pull to describe a check by what it is meant to prevent rather
than by what it actually compares. "The agent cannot invent citations" is a
better sentence than "the agent cannot invent citations above sub-paragraph
level".

## Decision

State the limit in the same breath as the guarantee, everywhere the gate is
described — in the README, in this record, and in the script.

**A check described as tighter than it is would be worse than no check**, because
a reviewer would stop looking at exactly the level where the check stops looking.

## Alternatives Considered

- **Tighten the gate to sub-paragraph level.** The right future work, and not
  free: it requires the corpus to carry `Absatz`-level structure and the engine to
  return it. Deferred deliberately, and named in the roadmap rather than left as
  an unstated gap.
- **Describe it as complete and fix it later.** Rejected. This is the precise
  behaviour the project exists to argue against — a confident claim outrunning
  what was verified.
- **Say nothing about granularity.** Rejected: silence reads as completeness.

## Consequences

- A reader knows exactly what the gate buys, and knows to read `Absatz`
  references themselves.
- The limit is a roadmap item with a name rather than a surprise.
- The same discipline applies to the other claims in the README: each is paired
  with the file that makes it checkable, and the "Honest limits" section exists
  for the ones that are not yet.

## References

- `scripts/transkriptGate.mjs`
- README "Honest limits"
