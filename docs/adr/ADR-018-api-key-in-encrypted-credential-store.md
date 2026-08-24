# ADR-018: The import key lives in an External Credential, not in a config record

## Status

**Accepted**

## Date

2026-08-24

## Author

Mustafa Aksu

## Context

The OCPI import path authenticates to an operator endpoint with a token. Its
first home was a configuration record — a custom object or setting holding the
value as text.

That works, and it puts a live credential somewhere a report can read, a Data
Loader export can carry away, and a user with broad object access can open. The
value is protected by object permissions, which is a coarser instrument than a
credential deserves.

Salesforce provides a purpose-built store for exactly this: **External
Credentials**, where the secret is encrypted, never returned to Apex in
readable form, and granted to a running user through a permission set rather
than through record access.

## Decision

Move the token into an **External Credential**, referenced by a **Named
Credential**, and let the platform inject it at callout time. Apex names the
Named Credential; Apex never reads the secret.

Access is granted by a permission set principal, so "who can call this endpoint"
is a permission question rather than a record-visibility question.

## Alternatives Considered

- **A protected Custom Setting.** Better than a plain record and still a value
  Apex can read and log. Rejected once a purpose-built store exists.
- **A Custom Metadata field.** Worse: custom metadata deploys between orgs, which
  is precisely the wrong lifecycle for a secret that should differ per org.
- **An environment-specific config record with tight object permissions.**
  Rejected: it protects the credential with the same mechanism that protects
  ordinary data, and the two do not deserve the same mechanism.

## Consequences

- The secret is not readable from Apex, not exportable through a report, and not
  in the repository.
- Setup gains a step — the credential must be configured per org — and that step
  is documented with the other post-deploy items in the README.
- The endpoint is called through the Named Credential, so the URL is
  configuration rather than a string in a class.
- This closes the last place in the project where a live secret sat in ordinary
  data.

## References

- `force-app/main/default/externalCredentials/`, `namedCredentials/`
- `force-app/main/default/classes/OcpiImportService.cls`
- Commit `feat: the api key goes in the encrypted credential store, not in a config record`
