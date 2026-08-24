# ADR-010: Every `§` the agent utters must appear in what an action returned — a binary check

## Status

**Accepted**

## Date

2026-08-20

## Author

Mustafa Aksu

## Context

ADR-009 removes the agent's ability to compute a legal outcome. It does not stop
the agent **citing** something — attaching a plausible `§` to a correct answer,
or repeating a provision it saw during training rather than one the engine
handed it.

A citation is the part a reader checks least, because it looks like evidence.

## Decision

A gate runs over the transcript: **every statutory reference the agent utters
must appear in what an action returned for that question.**

No model, no embedding, no similarity threshold. A citation was either handed
over by the engine or it was invented, and that is a **binary**.

The gate is `scripts/transkriptGate.mjs`, and on every run it proves that it can
fail — a negative control, so a passing gate means the check ran rather than
that the check was vacuous.

## Alternatives Considered

- **Semantic similarity between the citation and the sources.** Rejected: it
  introduces a threshold, and a threshold turns a binary question into a judgement
  call that will eventually be tuned until it passes.
- **A second model checking the first.** Rejected: it replaces a verifiable
  property with another model's opinion.
- **Trusting the action's grounding.** Rejected: the observed failure was an
  action that never ran while the response still sounded grounded.
- **Checking only that some citation exists.** Rejected: an invented citation is
  a citation.

## Consequences

- Invented citations are caught mechanically, and the check itself is checked.
- The gate needs a real transcript, so it needs a published, active agent — which
  is why it does not run on every push (ADR-016).
- The gate's granularity is a stated limit rather than an implied guarantee —
  see ADR-015.
- An unresolvable citation key must **throw** rather than be skipped, or the gate
  would pass over an empty source list. That is ADR-014.

## References

- `scripts/transkriptGate.mjs`
- `.github/workflows/agent-gate.yml`
