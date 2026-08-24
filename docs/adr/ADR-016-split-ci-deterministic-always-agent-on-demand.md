# ADR-016: The deterministic half runs on every push; the agent gate runs on demand

## Status

**Accepted**

## Date

2026-08-22

## Author

Mustafa Aksu

## Context

Two kinds of check protect this project. One is deterministic — Apex tests, the
formula-versus-engine consistency check, the utter-only-what-you-cite invariant,
the umlaut audit. The other needs a **published, active agent** and a real
transcript.

The second kind cannot run the way the first does. A scratch org does not have a
published agent, and every gate run spends real generations against a Developer
Edition ceiling of **150 an hour**. Wiring it into every push would exhaust the
allocation and make the pipeline fail for reasons unrelated to the change.

## Decision

Split CI into two workflows:

- **`ci.yml`** — the deterministic half. Runs on every push. Costs nothing.
- **`agent-gate.yml`** — the transcript gate. Runs on demand, against an org
  that actually has the agent.

## Alternatives Considered

- **Run everything on every push.** Rejected: the generation ceiling makes it
  unreliable, and an unreliable gate gets ignored.
- **Drop the agent gate and rely on the deterministic checks.** Rejected: the
  citation invariant is the check that covers what the deterministic half cannot
  see.
- **Mock the agent in CI.** Rejected: a mocked transcript proves the gate parses
  a transcript, not that the agent stayed inside its sources.
- **Nightly scheduled run.** A reasonable middle path, deferred — on-demand keeps
  the cost attached to the moment someone wants the answer.

## Consequences

- Every push is fully checked on everything that can be checked for free.
- The agent gate is a deliberate act, so its result is attached to a decision
  rather than to a commit that happened to land.
- A change to agent behaviour can merge without the gate having run. The split is
  documented here so that is a known property rather than a discovered one.

## References

- `.github/workflows/ci.yml`, `.github/workflows/agent-gate.yml`
