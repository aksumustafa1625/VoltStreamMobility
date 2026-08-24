# Security

## Scope

This is a **portfolio and demonstration project** modelling a fictional company,
VoltStream Mobility GmbH. It is not deployed to production and holds no real
customer or partner data. Reseller, Opportunity and Task records in `scripts/`
and in the test classes are fabricated, and demo addresses use domains reserved
for documentation (RFC 2606).

**One category of data here is real**: twenty-five charge points imported from
the public OpenStreetMap map of central Berlin. They are public infrastructure
records — operator, socket type, location — and carry no personal data.

## Credentials

**No API key, token or password exists in this repository — in the working tree
or in the git history.**

- The OCPI import token lives in an **External Credential**, referenced through a
  Named Credential. Apex names the credential and never reads the secret
  ([ADR-018](docs/adr/ADR-018-api-key-in-encrypted-credential-store.md)).
- The live charge-point import needs **no key at all**: the OpenStreetMap
  Overpass API is public and unauthenticated
  ([ADR-008](docs/adr/ADR-008-live-public-data-over-fixtures.md)).

The org identifiers that once appeared in the probe documents under `docs/` —
the admin username, org id and instance subdomain — have been replaced with
placeholders and removed from the history.

## Platform security posture

- **Sharing is explicit on every class.** There is exactly one `without sharing`
  exception, it covers counting Tasks for a roll-up, and the reasoning is in the
  class header as well as in
  [ADR-007](docs/adr/ADR-007-rollup-is-the-one-without-sharing-exception.md).
- **`WITH USER_MODE` is proven, not claimed.** `EichrechtBerechtigungTest` runs
  as a user holding the permission set and nothing else, so field and object
  enforcement is verified by the suite rather than asserted in a document.
- **Access is granted by permission set**, not by widening a profile.
- **The agent cannot make a legal decision.** No date arithmetic exists on its
  side of the call
  ([ADR-009](docs/adr/ADR-009-the-engine-decides-the-agent-explains.md)), and a
  gate checks that every statutory reference it utters was handed to it by an
  action ([ADR-010](docs/adr/ADR-010-transcript-gate-binary-citation-check.md)).

## A note on the legal content

The statutory wording in `Rechtsnorm__mdt` is quoted verbatim where the original
was read, and **left empty where it was not** — two records are deliberately
text-free and say so
([ADR-013](docs/adr/ADR-013-law-is-versioned-metadata-verbatim-or-empty.md)).

Nothing in this repository is legal advice. It is a demonstration of how a
compliance answer can be made deterministic, citable and reproducible.

## Reporting a problem

If you find a security-relevant mistake — including a pattern that would be
unsafe if copied into a real org — please open an issue, or contact the author
via https://mustafaaksu.dev. There is no bug bounty; corrections are genuinely
welcome.
