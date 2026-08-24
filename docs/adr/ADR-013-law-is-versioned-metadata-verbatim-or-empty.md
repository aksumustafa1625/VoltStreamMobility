# ADR-013: The law is versioned metadata, quoted verbatim or left empty

## Status

**Accepted**

## Date

2026-08-19

## Author

Mustafa Aksu

## Context

The agent narrates from statutory wording. Where that wording lives determines
whether the narration can be trusted.

A string in an Apex class is invisible to review, changes without a diff anyone
reads as a legal change, and cannot carry the dates that say when a provision
was in force.

The second problem is subtler. If the field holding the wording may contain a
*paraphrase*, then the agent is narrating from someone's summary while appearing
to quote the law — which defeats the grounding design more quietly than an
invented citation would.

## Decision

Model the corpus as **Custom Metadata**: `Rechtsnorm__mdt`, sixteen provisions,
each with **verbatim wording** and **valid-from / valid-to dates**.

And a rule with no exceptions: **`Wortlaut__c` holds official text or it holds
nothing.** Two records are deliberately text-free because the original was not
read, and they say so. An empty field is an honest gap; a paraphrase is a
plausible-looking fabrication.

## Alternatives Considered

- **Statutory text in Apex constants.** Rejected: not reviewable as law, no
  validity dates, no diff that reads as a legal change.
- **A custom object holding provisions.** Rejected for the reason in ADR-014 —
  it would make the corpus editable in production.
- **Paraphrase where the original was unavailable.** Rejected explicitly. It is
  the failure mode the whole grounding design exists to prevent, arriving through
  the front door.
- **Fetch the text from an official source at runtime.** Rejected: it makes a
  legal answer depend on an external endpoint's availability, and versions the
  corpus outside the repository.

## Consequences

- Every legal change appears in a diff and is reviewed like code.
- Validity dates let the engine answer "was this lawful *then*", which pairs with
  the parameterised reference date in ADR-012.
- Two provisions narrate less than the others, visibly, and that is the correct
  outcome for text that was not read.
- The corpus must be maintained as law changes. Custom metadata makes that a
  reviewed change rather than a quiet one.

## References

- `force-app/main/default/customMetadata/Rechtsnorm.*`
- `force-app/main/default/objects/Rechtsnorm__mdt/`
