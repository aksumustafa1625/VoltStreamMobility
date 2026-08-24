# Architecture Decision Records

Eighteen records covering four phases: a channel-partner CRM, a document
manager, a Task roll-up, and a German charging-law compliance engine with an
Agentforce agent over it.

Each states the constraint, the decision, what else was on the table, and what
the choice costs. They are written from the code and the commit history — every
claim points at a file you can open.

## Phases 1–3 — the platform foundation

| # | Decision | The constraint behind it |
|---|---|---|
| [001](ADR-001-kevin-ohara-four-layer-triggers.md) | Kevin O'Hara framework, four layers not three | Three automated objects, one writing to another |
| [002](ADR-002-selector-pattern-single-soql-boundary.md) | All SOQL lives in a Selector | The same query in three files drifts apart |
| [003](ADR-003-normalization-at-the-boundary.md) | Normalisation at the trigger boundary | `IN` against an External ID is case-sensitive |
| [004](ADR-004-attribution-never-blocks-a-save.md) | No-match is silent; the lookup is read-only | Attribution is reporting, not validation |
| [005](ADR-005-requery-only-when-the-email-changed.md) | Re-query only when the matching field changed | A 200-record load should not pay for an untouched field |
| [006](ADR-006-testdatafactory-single-constructor.md) | One fixture factory; a test class per production class | A new required field should break one file, not thirty |
| [007](ADR-007-rollup-is-the-one-without-sharing-exception.md) | The Task roll-up is the one `without sharing` exception | A count that depends on the saver is not a fact |

## Phase 4 — the compliance engine and the agent

| # | Decision | The constraint behind it |
|---|---|---|
| [008](ADR-008-live-public-data-over-fixtures.md) | The fleet is imported live, not seeded | A fixture author supplies what the engine reads |
| [009](ADR-009-the-engine-decides-the-agent-explains.md) | **The engine decides, the agent explains** | It answered the same question twice, wrongly, in fluent German |
| [010](ADR-010-transcript-gate-binary-citation-check.md) | **Every `§` uttered must appear in what an action returned** | A citation is the part a reader checks least |
| [011](ADR-011-the-formula-field-stays-even-where-it-is-wrong.md) | The formula field stays, even where it is wrong | Status legible without executing anything is the thesis |
| [012](ADR-012-reference-date-is-a-parameter.md) | The reference date is a parameter, never `TODAY()` | A clock cannot be asserted against, or reproduced |
| [013](ADR-013-law-is-versioned-metadata-verbatim-or-empty.md) | The law is versioned metadata, verbatim or empty | A paraphrase defeats grounding more quietly than an invention |
| [014](ADR-014-metadata-cannot-be-dmld-and-that-is-the-feature.md) | Custom metadata cannot be DML'd — the feature | Legal text should not be typed into production |
| [015](ADR-015-the-gates-granularity-is-stated.md) | The gate's granularity is stated, not implied | A check described as tighter than it is, is worse than none |
| [016](ADR-016-split-ci-deterministic-always-agent-on-demand.md) | Deterministic checks always; the agent gate on demand | 150 generations an hour, and no agent in a scratch org |
| [017](ADR-017-ascii-identifiers-german-strings.md) | ASCII identifiers, German strings, enforced by a script | A bulk replace once reached into a field API name |
| [018](ADR-018-api-key-in-encrypted-credential-store.md) | The import key lives in an External Credential | A config record is protected like data, not like a secret |

## The three worth reading first

**[ADR-009](ADR-009-the-engine-decides-the-agent-explains.md)** — the failure
that shaped the design was observed, not anticipated. The agent answered the same
question twice and gave two different wrong answers, both lifted from its own
instructions, because a misconfigured action never ran. It sounded correct in
German both times.

**[ADR-011](ADR-011-the-formula-field-stays-even-where-it-is-wrong.md)** — the
project ships a field it knows is wrong in one case, keeps it because a status
visible in a list view is the whole point, and asserts the divergence in a test
so it cannot be silently "fixed".

**[ADR-015](ADR-015-the-gates-granularity-is-stated.md)** — the citation gate
catches an invented paragraph and does not catch a wrong `Absatz` inside a
correct one. Saying so is the decision.

## Format

Status · Date · Author · Context · Decision · Alternatives Considered ·
Consequences · References.

The same structure is used across the sibling
[urla-shoes](https://github.com/aksumustafa1625/urla-shoes) and
[urlashoes-sandbox](https://github.com/aksumustafa1625/urlashoes-sandbox)
projects.
