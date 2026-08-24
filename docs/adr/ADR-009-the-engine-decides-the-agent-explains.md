# ADR-009: The engine decides, the agent explains — and no date arithmetic exists on the agent's side

## Status

**Accepted**

## Date

2026-08-19

## Author

Mustafa Aksu

## Context

The agent answers questions about whether a charge point is lawful under
**MessEG** and **MessEV**. That answer is a legal statement, and a wrong one
delivered in fluent German is worse than no answer, because it is believed.

**This was measured, not anticipated.** During the build the agent was asked the
same question twice and gave two different wrong answers, both of them phrases
lifted out of its own instructions, because a misconfigured action never ran. It
sounded correct in German both times. Nothing in the response indicated that no
computation had happened.

That failure mode — plausible prose in place of an absent computation — is the
one the whole design exists to remove.

## Decision

**The engine decides. The agent explains.**

- Per-record legal status is a **formula field**, visible in a list view. A
  reviewer sees compliance state without running an agent and without running a
  test.
- Chronology a formula cannot express is **Apex** (`EichrechtService`).
- The agent's only jobs are to pick which deterministic check runs and to narrate
  the result in German.

The agent **cannot** make a legal decision, and the reason is structural rather
than instructional: **no date arithmetic exists on its side of the call.**
`PruefeEichfristen` resolves the records, calls the engine, and returns the
engine's sentences unchanged.

## Alternatives Considered

- **Let the model reason about the dates, with a careful prompt.** Rejected on
  the evidence above. An instruction is not a mechanism, and the observed failure
  was the model reciting its instructions instead of executing them.
- **Model-graded self-checking.** Rejected: the same model that produced the
  answer would decide whether the answer is right.
- **A confidence threshold on the model's output.** Rejected: confidence is not
  correctness, and a fluent wrong answer scores high.
- **No agent at all.** Considered seriously. The formula field alone satisfies
  the compliance requirement; the agent adds a German-language explanation over
  it. It is deliberately additive — remove it and nothing legal is lost.

## Consequences

- The failure mode is eliminated by construction rather than mitigated by
  prompting.
- The agent is replaceable. A different model, or none, changes the explanation
  and not the answer.
- Every legal claim traces to a deterministic source that can be run, tested and
  reproduced without a model.
- The formula field carries the load, which is what makes it worth keeping even
  where it is imperfect — see ADR-011.

## References

- `force-app/main/default/classes/PruefeEichfristen.cls`
- `force-app/main/default/classes/EichrechtService.cls`
- README "The decision that shapes everything"
