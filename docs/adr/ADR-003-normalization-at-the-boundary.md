# ADR-003: Normalisation happens once, at the trigger boundary, so no save path can bypass it

## Status

**Accepted**

## Date

2026-05-14

## Author

Mustafa Aksu

## Context

Opportunities are matched to resellers by email. Email is case-insensitive to a
human and case-sensitive to a database, so `Partner@X.DE` and `partner@x.de` are
the same partner and two different index entries.

`Reseller__c.Company_Email__c` is marked as an **External ID** for indexed
lookups, and SOQL `IN` against an External ID is **case-sensitive at the storage
layer**. That makes normalisation not a nicety but a correctness requirement: if
one record is stored capitalised, it will never be found.

Records arrive from at least four paths — the UI form, an API insert, Data
Loader, and the scratch-org seed script. Normalising in the component that
happens to be in front of a human covers exactly one of them.

## Decision

Normalise **at the trigger boundary**, on every insert and update, through a
single utility:

`ResellerTriggerHelper.normalizeFields()` lowercases the email, formats the
phone to `(NNN) NNN NN-NN`, and trims whitespace from name and country. All of
it delegates to `StringUtils`, which is the only place any of those rules is
written.

Because every save path in Salesforce passes through the trigger, **there is no
path that stores an unnormalised value.** That is what makes the External ID
lookup safe.

`StringUtils` carries a null-safe contract: blank in → null out, never throws.

## Alternatives Considered

- **Normalise in the LWC.** Rejected: covers the UI and nothing else.
- **Normalise at query time** with `LOWER()` or a formula. Rejected: it defeats
  the External ID index, which is the reason the field is marked at all.
- **A case-insensitive formula field alongside the real one.** Rejected: two
  fields holding the same fact, and the wrong one will eventually be queried.
- **Inline the lowercasing where it is needed.** Rejected: the same rule in
  several files diverges the moment one is edited.

## Consequences

- Stored values are canonical, so the indexed lookup is correct by construction.
- Changing a normalisation rule means changing `StringUtils` and nothing else.
- The trigger runs on every save of every Reseller, which is the cost of the
  guarantee.
- Tests assert the case-insensitive match explicitly — `PARTNER@X.DE` finding
  `partner@x.de` — because that is the behaviour the External ID would otherwise
  quietly break.

## References

- `force-app/main/default/classes/StringUtils.cls`, `ResellerTriggerHelper.cls`
- `force-app/main/default/objects/Reseller__c/fields/Company_Email__c.field-meta.xml`
