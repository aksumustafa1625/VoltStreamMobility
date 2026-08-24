# ADR-017: Identifiers are ASCII, strings are German, and a script fails the build on the difference

## Status

**Accepted**

## Date

2026-08-22

## Author

Mustafa Aksu

## Context

This project is German. The corpus is German, the agent answers in German, and
the field labels a user reads are German — which means umlauts everywhere.

Apex rejects umlauts in identifiers. So the codebase has to hold two conventions
at once: ASCII for anything the compiler reads, German for anything a human
reads.

That is a rule people follow until a bulk edit does not. **It happened here**: a
find-and-replace restoring German text reached into a field API name. The
deployment failed, and the cause was several layers away from the symptom.

## Decision

Make the rule mechanical. `scripts/umlautaudit.py` strips strings and comments
from the source and **fails the build on any non-ASCII character left standing**
— that is, on anything in an identifier.

It runs in the deterministic half of CI (ADR-016), so it costs nothing and runs
on every push.

## Alternatives Considered

- **Rely on convention and review.** Rejected on the evidence: this is exactly
  what failed.
- **Wait for the deployment error.** Rejected: the failure surfaces far from its
  cause, and the feedback loop is a deploy long.
- **Romanise everything — `Eichstatus` as `Eichstatus`, labels included.**
  Rejected: it would make the German-language product speak broken German to its
  users, which is the opposite of what the project is demonstrating.
- **A linter rule.** Effectively what this is; a purpose-built script was quicker
  than configuring an ESLint or PMD rule to look at Apex identifiers only.

## Consequences

- The two conventions coexist without depending on anyone remembering.
- A bulk edit that reaches into an identifier fails in seconds rather than at
  deploy time.
- The script is a build dependency, and its own correctness matters — it must
  strip strings and comments accurately or it produces false failures.
- A related test guards the other direction: `GermanTextSerializationTest`
  demonstrates that German survives corpus → engine → action → JSON, rather than
  forbidding the characters that could break it.

## References

- `scripts/umlautaudit.py`
- `force-app/main/default/classes/GermanTextSerializationTest.cls`
- `.github/workflows/ci.yml`
