# ADR-002: All SOQL lives in a Selector, so a query change touches exactly one file

## Status

**Accepted**

## Date

2026-05-05 (Phase 1), extended in Phase 4

## Author

Mustafa Aksu

## Context

The same records get queried from several places: a helper matching an
Opportunity to a reseller, a controller feeding a component, a batch sweeping the
fleet. Written inline, the same query appears three times with three field lists,
and adding a field to one leaves the others silently stale.

The failure is not theoretical. A query that forgets a field does not error — it
returns records with that field null, and the code downstream treats null as an
answer.

## Decision

Every SOQL statement lives in a Selector class: `ResellerSelector`,
`TaskSelector`, `LadepunktSelector`. Helpers, handlers and controllers call the
selector; none of them write a query.

When a query needs a new field, an index hint or a different `WHERE` clause,
exactly one file changes and every caller inherits it.

This is FFLib Apex Common's convention, adopted without the framework — the
pattern is the valuable part.

## Alternatives Considered

- **Inline SOQL where convenient.** Rejected: it is how field lists drift apart.
- **Adopt FFLib Apex Common wholesale.** Rejected as disproportionate: the
  Selector idea carries almost all of the value here, and the full framework
  brings Unit of Work and Domain layers this project does not need.
- **A single generic "query service".** Rejected: it would take field lists as
  strings and lose compile-time safety, which is most of the point.

## Consequences

- A query written outside `*Selector` is visible in a diff and can be questioned
  in review.
- Inactive resellers are excluded **in the selector's `WHERE` clause** rather
  than filtered in Apex after the fact — cheaper, and explicit at the boundary
  where the rule belongs.
- Selectors accumulate methods as callers ask for different shapes. That is the
  intended place for that growth.

## References

- `force-app/main/default/classes/ResellerSelector.cls`, `TaskSelector.cls`, `LadepunktSelector.cls`
