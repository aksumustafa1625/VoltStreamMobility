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
| Was any credit limit hit? | **No.** Six LLM-backed calls, no quota error. |

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
| `sf agent test run`, 2 cases | **2 m 22 s** end to end |
| — of which agent execution | **~10 s** (cases finished 20:02:19–22) |
| — of which LLM judging | **~2 m 10 s** |
| `output_latency_milliseconds`, case 1 | **4696 ms** |
| Credit errors or quota failures | **none** |

Agent turns are fast; the judged metrics are what costs wall-clock. That ratio argues for
few judged metrics and many deterministic assertions, independently of cost.

---

## 7. What is still unverified

- **What the custom scorer's prompt template actually receives.** Not tested yet, and it
  decides whether a groundedness scorer can be a groundedness scorer at all. Next probe.
- **Credit consumption per run.** No error occurred, but the Digital Wallet is not available
  in this edition, so consumption remains unmeasured rather than measured-as-zero.
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
