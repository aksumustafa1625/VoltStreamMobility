# ADR-014: Custom metadata cannot be inserted by DML, and that is the feature

## Status

**Accepted**

## Date

2026-08-19

## Author

Mustafa Aksu

## Context

Custom Metadata records cannot be created or edited with ordinary DML. For most
uses that is an inconvenience; here it decides the design.

The corpus is statutory text. The question is who may change it and how the
change is noticed. A custom object would let an administrator type a new
provision into production at the moment they read the gazette — fast, and
invisible to anyone reviewing the system afterwards.

## Decision

Keep the corpus as **Custom Metadata**, and treat the DML restriction as a
guarantee rather than a limitation.

The corpus is a **build artifact**. Every legal change arrives through a
deployment, appears in a diff, and is reviewed like code.

The corollary: **an unresolvable citation key throws.** If the engine is asked
for a provision that is not in the corpus, it fails loudly rather than returning
an empty source list — because a silently empty list is exactly what would let
the transcript gate (ADR-010) pass on nothing.

## Alternatives Considered

- **A custom object for the corpus.** Rejected: it makes legal text editable in
  production without review, which is the outcome this decision exists to
  prevent.
- **Custom metadata plus an admin UI that deploys.** Rejected as
  disproportionate, and it would reintroduce the same speed-over-review pressure.
- **Skip unresolvable keys and carry on.** Rejected: a check that passes because
  there was nothing to check is worse than no check.

## Consequences

- Legal changes require a deployment. That is slower, and it is the point.
- The corpus in the repository is the corpus in the org, with no drift path.
- A missing provision is a loud failure at the moment of use.
- Deploying custom metadata records has one sharp edge worth knowing: a record
  file throws `UNKNOWN_EXCEPTION` unless `xmlns:xsd` is declared on the root
  element.

## References

- `force-app/main/default/customMetadata/`
- `force-app/main/default/classes/EichrechtService.cls` — citation resolution
