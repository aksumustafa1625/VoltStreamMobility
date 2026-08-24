# ADR-004: A missing reseller is silent, and the lookup is read-only on the layout

## Status

**Accepted**

## Date

2026-05-05

## Author

Mustafa Aksu

## Context

The trigger resolves `Opportunity.Reseller__c` from an email. Two questions
follow: what happens when no reseller matches, and what happens when a user
edits the lookup by hand.

Both have a tempting answer that is wrong. Blocking the save on a missing match
makes channel attribution a gating field — a rep cannot record a deal because a
partner record does not exist yet. And leaving the lookup editable means two
sources of truth for the same fact.

## Decision

**No-match is silent.** The Opportunity saves with the lookup null. Attribution
is reporting, not validation, and reporting must never stand between a rep and a
recorded deal.

**The lookup is read-only on the layout.** Salesforce would permit manual
editing; the permission set restricts `Opportunity.Reseller__c` to read-only, so
the trigger is the only writer. A field that is sometimes derived and sometimes
typed cannot be trusted for reporting, and a user who edits it has no way to
know the trigger will overwrite them on the next email change.

## Alternatives Considered

- **A validation rule requiring a match.** Rejected: it converts a data-quality
  aspiration into a blocked save, and the rep cannot fix the cause.
- **An error toast on save.** Rejected: same interruption, less enforcement.
- **Leave the lookup editable and let the trigger yield to manual values.**
  Rejected: it requires a second field to record "was this manual", and the rule
  becomes unexplainable to a user.
- **Queue unmatched Opportunities for review.** A reasonable future addition; out
  of scope for a mechanic whose point is the matching itself.

## Consequences

- Deals are never blocked by partner data quality.
- The reporting field has exactly one writer, so a report on it means one thing.
- An unmatched Opportunity is invisible unless someone looks for nulls — the
  known cost, and the reason a review queue is on the roadmap rather than
  dismissed.

## References

- `force-app/main/default/classes/OpportunityTriggerHelper.cls`
- `force-app/main/default/permissionsets/`
