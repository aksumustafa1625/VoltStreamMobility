# Phase 0 — platform verification

**Org:** `VoltStreamDev` (`00Dxx0000000000XXX`), Developer Edition, API 67.0
**Date:** 2026-08-22 · **CLI:** `@salesforce/cli 2.125.2`
**Method:** a deliberately worthless probe agent walked end to end, so that any failure is
the platform and never the domain code. Raw command output is reproduced below.

Eight rounds of design review argued about what this org can do. This file replaces the
argument with measurements.

---

## Headline

| Question | Answer |
|---|---|
| Do agent tests run in a Developer Edition? | ✅ **Yes.** `runId 4KBgL0000002gzFWAQ`, status `COMPLETED`, full metric values returned. |
| Does `sf agent publish authoring-bundle` work (Agent Script)? | ❌ **No — `ERROR_HTTP_404`**, reproducing HanseWatt's edition wall. |
| Does the classic `sf agent create` path work? | ✅ **Yes.** Bot, BotVersion and Planner created in ~30 s. |
| Does `AiEvaluationDefinition` deploy to a DE org? | ✅ **Yes.** |
| Which expectation names does this org actually accept? | **`topic_assertion` / `actions_assertion` / `output_validation`** — *not* the documented `topic_sequence_match` / `action_sequence_match` / `bot_response_rating`. |
| Was any credit limit hit? | **No** — here, and never across two projects and months of credit-heavy work in Developer Edition orgs. |

---

## 1. Metadata types unlocked by the Setup toggle

Before enabling Agentforce, `Bot`, `BotVersion` and `AiAuthoringBundle` returned
`INVALID_TYPE: Cannot use ... in this organization`. After:

```
Bot                        Warning: No metadata found for type: Bot
BotVersion                 Warning: No metadata found for type: BotVersion
AiAuthoringBundle          Warning: No metadata found for type: AiAuthoringBundle
GenAiPlannerBundle         Warning: No metadata found for type: GenAiPlannerBundle
GenAiPlugin                Warning: No metadata found for type: GenAiPlugin
GenAiFunction              Warning: No metadata found for type: GenAiFunction
AiEvaluationDefinition     Warning: No metadata found for type: AiEvaluationDefinition
AiAgentScorerDefinition    Warning: No metadata found for type: AiAgentScorerDefinition
AiTestingDefinition        Warning: No metadata found for type: AiTestingDefinition
GenAiPromptTemplate        Warning: No metadata found for type: GenAiPromptTemplate
```

"No metadata found" means the type is recognised and empty. All ten are available.

Testing Center is live at `/lightning/setup/TestingCenter/home` and shows **0 Items** —
the same state HanseWatt recorded a year of work earlier without ever filling it.

---

## 2. The Agent Script path — reproduces HanseWatt's wall

`sf agent generate agent-spec` (9 s, one LLM call) and
`sf agent generate authoring-bundle` (1 s, local) both succeeded.
`sf agent validate authoring-bundle` returned `{"success": true}`.

Publish failed in two distinct steps, and the order matters:

```
# with the generated placeholder still in place
$ sf agent publish authoring-bundle --api-name VS_Phase0_Probe
Failed to publish agent with the following errors:
To commit this agent, fix these validation issues: We couldn't find the default
agent user NEW AGENT USER. Specify a valid agent user.

# after setting default_agent_user to a real username
$ sf agent publish authoring-bundle --api-name VS_Phase0_Probe
Failed to publish agent with the following errors:
ERROR_HTTP_404
```

The first error is semantic and server-side, so the command **does** reach Salesforce and
**does** validate. The 404 arrives only at the commit step. That is the same wall
`hansewatt-pruefstand/docs/EDITION_LIMITS.md` #2 records, now reproduced independently in a
second org — which upgrades it from one project's anecdote to a reproducible edition
boundary.

**Consequence:** Agent Script is authorable and validatable here, but not publishable. The
`.agent` file is design source; the deployed agent comes from the classic path.

### The real grammar, as the CLI itself generates it

Worth recording because the sister design document guessed at this and guessed wrong. Six
top-level blocks, 4-space indent, `#` comments:

```
system:            # instructions + messages.welcome / messages.error
config:            # developer_name, default_agent_user, agent_label, description
variables:         # `linked string` (bound via source:) | `mutable string`
language:          # default_locale, additional_locales, all_additional_locales (Python-cased False)
start_agent <name>:
topic <name>:
```

```
start_agent topic_selector:
    reasoning:
        instructions: ->
            | Select the tool that best matches the user's message...
        actions:
            go_to_escalation: @utils.transition to @topic.escalation

topic escalation:
    reasoning:
        actions:
            escalate_to_human: @utils.escalate
                description: "Call this tool to escalate to a human agent."
```

Three things are absent, and their absence is the finding:

- **No gating construct.** No `available when`, no `available_when`, nothing equivalent.
  Scope is expressed only by topic membership plus prose.
- **No confirmation construct.** Human-in-the-loop cannot be expressed in Agent Script.
- **No `entry:` / `say:`.** The greeting is `system.messages.welcome`.

Note also: the CLI emits **`topic <name>:`** and **`@topic.<name>`**. HanseWatt's July 2026
file used `subagent` / `@subagent.`. Both forms exist in the wild; this CLI generates
`topic`.

---

## 3. The classic path works

```
$ sf agent create --spec specs/phase0-probe.yaml --api-name VS_Phase0_Probe_Classic
"agentId": { "botId": "0XxgL000002V07R",
             "botVersionId": "0X9gL0000045KtR",
             "plannerId": "16jgL000002KylF" },
"isSuccess": true
```

30 seconds. One LLM call — the command generated topic instructions and five sample
utterances on its own.

**And it wired standard actions unasked:** `AdminCopilot__ShowOrgPreferences`,
`AdminCopilot__SetupGeneralKnowledgeGrounding`, `AdminCopilot__CapabilitySummarization`,
`EmployeeCopilot__AnswerQuestionsWithKnowledge`. HanseWatt's finding that standard actions
are back doors shows up in the first thirty seconds of a fresh agent.

---

## 4. The evaluation runs — and returns real metric values

```
$ sf agent test run --api-name VS_Phase0_Probe_Tests --wait 10
runId     4KBgL0000002gzFWAQ        (the 4KB prefix = Testing Center runner)
status    COMPLETED
startTime 2026-08-22T20:02:10Z
endTime   2026-08-22T20:04:32Z      → 2 m 22 s for two cases
```

Both cases executed and every expectation returned a populated `result`, `score`,
`actualValue`, `expectedValue` and — for the LLM-judged ones — `metricExplainability`.

**This settles the load-bearing unknown. Agent testing is not sandbox-only.**

### Which expectation names this org accepts

`sf agent test create` generated, and the org accepted:

```xml
<expectation><name>topic_assertion</name>   <expectedValue>...</expectedValue></expectation>
<expectation><name>actions_assertion</name> <expectedValue>['...']</expectedValue></expectation>
<expectation><name>output_validation</name> <expectedValue>...</expectedValue></expectation>
<expectation><name>coherence</name></expectation>
<expectation><name>output_latency_milliseconds</name></expectation>
```

The documented names (`topic_sequence_match`, `action_sequence_match`,
`bot_response_rating`) were **not** what the CLI emitted. Write specs against the names
above, not against the reference page.

`expectedActions: []` round-tripped correctly to `<expectedValue>[]</expectedValue>` — CLI
bug #3314 (silently empty expectations) did **not** reproduce here.

---

## 5. Three findings that change the design

### 5.1 `topic_assertion` is unusable for custom topics — the returned value is mangled

```
Case 1  expectedValue  "p_16jgL000002KylF_Eichfrist_Monitoring"
        actualValue    "p"                        ← truncated at the first underscore
        result         FAILURE

Case 2  expectedValue  "Off_Topic"
        actualValue    "Off_Topic"                ← intact, underscore and all
        result         PASS
```

The agent routed correctly — `generatedData.topic` also reads `"p"` — but the runner reports
the org-prefixed developer name as a single character. A standard topic name survives; a
custom one does not.

So `topic_assertion` **always fails for custom topics**, regardless of routing. Any CI gate
built on it would be permanently red for reasons that have nothing to do with the agent.
Until this is understood, route assertions must go through `actions_assertion` instead,
which returned its value intact.

### 5.2 The built-in quality metrics punish correct guardrail behaviour

Case 2 asked for a pancake recipe. The agent correctly declined and offered to help with
support topics instead. `coherence` scored it **0 / FAILURE**:

> *"The answer is completely incoherent and does not address the request for a pancake
> recipe. It seems to be a generic customer support response, which is unrelated to the
> task."*

The judge marked a working guardrail as incoherent **because it refused**. This is the
same failure mode a reviewer predicted for `factuality` — a zero-reference LLM judge scores
against its own expectations, and a refusal always looks like a non-answer.

`output_validation` failed the same case with a defensible reading (*"the bot does not
refuse the request; instead, it offers unrelated assistance"*), but its `score` was 1 while
its `result` was FAILURE — score and verdict do not agree.

**Consequence:** `coherence` / `completeness` / `conciseness` must be kept out of any gate
that includes refusal cases. Measuring them at all is only useful as a published finding.

### 5.3 The standard Knowledge action steals the turn

Case 1 expected `AdminCopilot__SetupGeneralKnowledgeGrounding`. What actually fired:

```
"invokedActions": [[{"function":{"name":"EmployeeCopilot__AnswerQuestionsWithKnowledge"}}]]
```

The standard Knowledge action won action selection and then could not answer, so the agent
apologised and referred the user to support. This is HanseWatt's `EDITION_LIMITS.md` #1
reproduced live: the standard action *"fails at runtime while still greedily winning action
selection and stealing questions from custom actions."*

**Consequence:** standard actions must be removed from a topic, not out-competed by a better
custom description.

---

## 6. Measured numbers

| Measurement | Value |
|---|---|
| `sf agent generate agent-spec` | **9 s** (one LLM call) |
| `sf agent generate authoring-bundle` | **1 s** (local) |
| `sf agent validate authoring-bundle` | **~2 s**, `{"success": true}` |
| `sf agent create` | **30 s** (one LLM call) |
| `sf agent test run`, 2 cases — **first run** | **2 m 22 s** (cold start) |
| `sf agent test run`, 2 cases — **runs 2–5** | **13.7 / 14.6 / 15.7 / 20.7 s** |
| `output_latency_milliseconds`, case 1 | **4696 ms** |
| Credit errors or quota failures | **none** |

The first figure was a cold-start artifact and the earlier reading of it — "LLM judging takes
two minutes" — was wrong. Steady state is **~15 s for two cases**. A twenty-case suite should
therefore land around two to three minutes, which is CI-viable without special handling.

---

## 7. What is still unverified

- **What the custom scorer's prompt template actually receives.** Not tested yet, and it
  decides whether a groundedness scorer can be a groundedness scorer at all. Next probe.
- **Credit consumption per run** is unmeasured and, on the evidence, does not need to be. The Digital Wallet is not available in this edition, so no balance can be read — but the operator has run credit-heavy work across two projects and several months in Developer Edition orgs, including a full day of live agent conversation, and has never hit a quota failure. Nothing in this probe did either. **Credits are therefore not treated as a design constraint.** The sibling project’s entire mock-first architecture was built around a fear that its own record shows never materialised.
- **Whether `topic_assertion`'s truncation is a display artifact or an evaluation-time
  defect.** The value is wrong in both `generatedData.topic` and `actualValue`, which
  suggests the latter.
- **`--test-runner agentforce-studio` (G2 / `AiTestingDefinition`).** Not yet attempted.
- **`isConfirmationRequired` under test** — whether Testing Center auto-confirms,
  auto-declines, or stalls.
- **Run-to-run variance.** One run only. Five are needed before any threshold is set.

---

## 8. Artifacts

```
force-app/main/default/classes/VSPhase0ProbeAction.cls          the worthless action
force-app/main/default/classes/VSPhase0ProbeActionTest.cls      2/2 passing
force-app/main/default/aiAuthoringBundles/VS_Phase0_Probe/      Agent Script, validates, will not publish
force-app/main/default/aiEvaluationDefinitions/                 the eval that ran
specs/phase0-probe.yaml                                         generated agent spec
specs/phase0-probe-testSpec.yaml                                the two-case test spec
```

Org-side: agent `VS_Phase0_Probe_Classic` (`0XxgL000002V07R`), eval
`VS_Phase0_Probe_Tests`, run `4KBgL0000002gzFWAQ`. All disposable — delete once the real
build starts.

---

## 9. Run-to-run variance — five runs of the same two cases

One run tells you nothing about a threshold. The identical suite was run five times
(`docs/platform-probes/variance-runs.jsonl` holds the raw rows).

### The deterministic assertions are genuinely deterministic

| Assertion | Run 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| `topic_assertion` case 1 | FAIL(0) | FAIL(0) | FAIL(0) | FAIL(0) | FAIL(0) |
| `topic_assertion` case 2 | PASS(1) | PASS(1) | PASS(1) | PASS(1) | PASS(1) |
| `actions_assertion` case 1 | FAIL(0) | FAIL(0) | FAIL(0) | FAIL(0) | FAIL(0) |
| `actions_assertion` case 2 | PASS(1) | PASS(1) | PASS(1) | PASS(1) | PASS(1) |

Five for five, identical. Routing and action selection did not wobble once, and
`generatedData.topic` returned the same mangled `"p"` every time — so §5.1 is a defect,
not a flake.

**This is the number the whole gate design rests on: `actions_assertion` can be gated
all-green.** No pass-rate, no repeats, no power calculation needed for that tier.

### The LLM-judged metrics do wobble

| Metric | Run 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| `output_validation` case 1 | FAIL(1) | FAIL(1) | FAIL(1) | FAIL(**0**) | FAIL(1) |
| `output_validation` case 2 | FAIL(0) | FAIL(1) | FAIL(1) | **PASS(5)** | FAIL(1) |
| `coherence` case 1 | PASS(4) | PASS(4) | PASS(4) | PASS(4) | PASS(4) |
| `coherence` case 2 | FAIL(0) | FAIL(0) | FAIL(0) | FAIL(**1**) | FAIL(0) |

**One verdict flip in five on `output_validation` case 2** — same agent, same version, same
utterance, same org, minutes apart. A 1-in-5 flip on a two-case suite is the empirical
input any acceptance threshold has to be built from, and it is measured rather than assumed.

Note that all the movement is in run 4. That is consistent with judge variance clustering
per run rather than per case, which matters: repeating a single failed case may not
reproduce the condition that produced it.

### Latency

`output_latency_milliseconds`, case 1, across runs: **4696 · 2778 · 2881 · 4352 · 2845 ms**.
Median ≈ 2.9 s, spread ≈ 1.7×. Nobody publishes these.

---

## 10. The custom scorer — what it actually receives

This was the outstanding "load-bearing unknown": a groundedness scorer is only a
groundedness scorer if its prompt template can see the action outputs and retrieved
material. The documentation does not say. The platform does, through its error messages.

### `AiAgentScorerDefinition` is not in the CLI's registry

```
$ sf project deploy start --metadata "AiAgentScorerDefinition:VS_Scorer_Echo_Probe"
Error (RegistryError): Missing metadata type definition in registry for id
'AiAgentScorerDefinition'.
```

The server knows the type — `sf org list metadata -m AiAgentScorerDefinition` returns
"no metadata found", not `INVALID_TYPE`. The **CLI** does not. Deploying it therefore
requires the metadata-format path (`--metadata-dir` with a hand-written `package.xml`),
which bypasses the source registry and reaches the server's own parser.

### Walking the schema by reading rejections

Each failure named the next constraint:

| Attempt | Server response |
|---|---|
| `<masterLabel>` present | `Element masterLabel invalid at this location in type AiAgentScorerDefinition` |
| `dataType Number` + `isFallback` | `The Number data type doesn't support fallback or system fallback values.` |
| Flex-typed prompt template | **`Allowed types: agentforce_session_tracing__scorerMultilabel, agentforce_session_tracing__scorerOpenEnded, agentforce_session_tracing__scorerMeasurement. Found: 'einstein_gpt__flex'.`** |
| `scorerMeasurement` with no inputs | **`Required Prompt Template Input definitions are missing: [[AllowedRange, Session]]`** |

**Those last two answer the question.**

1. A custom scorer cannot be backed by a Flex template. It must use one of three purpose-built
   types, all namespaced **`agentforce_session_tracing__`**.
2. A `scorerMeasurement` template has two **required** inputs: `AllowedRange` and **`Session`**.

So the scorer is handed a **Session**, not a bare utterance-and-response pair — and the type
namespace says that Session is the tracing session. That is consistent with the separately
documented note that observability supports Session scope at run time, and it means a
groundedness scorer is at least *architecturally* possible: the material is in scope.

**What is still not established** is which fields of that Session the template can dereference —
specifically whether action outputs and retrieved chunks are reachable. That needs the echo
template to actually run, which is blocked by the next finding.

### Scorer-typed prompt templates cannot be created via the Metadata API here

Every candidate `<definition>` for the `Session` input was rejected, and the last rejection
was not a validation message but an unhandled server-side null:

```
Failure to create template: Cannot invoke
"einstein.gpt.shared.provider.definition.GenAiPromptTypeEnum.getPath()"
because the return value of
"einstein.gpt.shared.provider.definition.GenAiPromptDefType.getType()" is null
```

A plain Flex template deploys cleanly (`VS_Scorer_Echo`, still in source). A
`agentforce_session_tracing__scorerMeasurement` template does not — the platform crashes
rather than naming the valid input definitions.

This is the same class of limitation the sibling project recorded for `GenAiFunction`:
**creatable in the UI, not through source**. The consequence for a source-first repository is
real and should be stated rather than glossed: the scorer would have to be built in Agentforce
Studio and only *retrieved* into git, which weakens "authored as source" for that one artifact.

### One more schema fact worth keeping

A `GenAiPromptTemplate` deploys only if `versionIdentifier` and `activeVersionIdentifier`
are **omitted** on first create — the platform mints them. Setting `1` or a UUID is rejected:

```
The prompt template version identifier is "1" invalid.
The prompt template version identifier is "fd7b6a32-...-e6f966f111b1" invalid.
```

The minted form is a base64 digest plus an ordinal:

```
KzZqWgd5jMzXkpnhkT4MIUQfuFYllHgFALWfY/Vih28=_1
```

To activate a template you retrieve it, read that value, and redeploy with
`<activeVersionIdentifier>` set to it. Two deploys, always.

---

## 11. What this changes in the plan

| Was going to | Now |
|---|---|
| Build the whole evaluation layer around a scratch org, because tests were assumed sandbox-only | Run them here. The workaround is deleted. |
| Author the agent in Agent Script and publish it | Author and validate in Agent Script; **publish through the classic path**, because the Agent Script commit endpoint 404s. |
| Gate on `topic_sequence_match` | Use `actions_assertion`. `topic_assertion` is unusable for custom topics, and five runs prove that is a defect rather than noise. |
| Gate a mixed suite at a 90% pass rate | Two tiers: **`actions_assertion` all-green** (5/5 deterministic, measured) and **LLM-judged reported as a score**, never gated. The 1-in-5 flip is the reason. |
| Keep `coherence` / `completeness` / `conciseness` as quality signal | Drop them from any suite containing refusals. They score a correct refusal as incoherent. |
| Ship a custom groundedness scorer as source | Possible in principle — the scorer does receive the Session — but not creatable through the Metadata API here. Either build it in the UI and retrieve, or make the headline verifier deterministic and credit-free instead. |
| Out-compete standard actions with better descriptions | Remove them from the topic. The Knowledge action won selection on every one of five runs. |
