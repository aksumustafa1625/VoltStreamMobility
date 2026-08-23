# Probe plan — six experiments, about two hours

**Written 2026-08-22. Run this before writing any Phase 3 code.**

Each probe has a command, an expected outcome, and — the point of the exercise — **a
decision it settles**. Record the actual result in the Result column and commit this file.
Nothing here is exploratory: every probe closes a question that would otherwise be guessed
at for the rest of the build.

**Order matters.** Probe 1 may change the outcome of 3, 5 and 6. Probe 2 may change the
outcome of 3 and 4. Do not reorder.

---

## Probe 1 · Update the toolchain — 5 minutes

**Why:** The installed CLI is roughly six months old, and at least one wall is a direct
consequence.

```
@salesforce/cli          installed 2.125.2 (2026-02-25)   latest 2.148.3 (2026-08-12)
@salesforce/plugin-agent installed 1.30.6  (2026-02-24)   latest 2.0.4   (2026-08-19)
```

Two facts make this the first thing to do:

- **CLI 2.135.7 release note, verbatim:** *"the `agent preview` and **`agent publish
  authoring-bundle` commands no longer fail with HTTP 404 errors** when user permissions are
  correct."* That fix is not in the installed build.
- **`AiAgentScorerDefinition` entered the SDR registry in April 2026** — the `RegistryError`
  is a fossil of the old CLI.
- And `plugin-agent` **2.0.0 (30 July 2026)** introduced `agent adl`, `agent trace`,
  `agent mcp` and `agent test run-eval`. **None of those commands exist on this machine.**

```bash
sf update
sf plugins update
sf version --verbose
sf plugins
```

Then confirm the new surface actually arrived:

```bash
sf agent --help                  # expect: adl, mcp, trace, preview, publish, test, validate
sf agent test --help             # expect: run-eval present
```

Also bump the project's API version while here — `sfdx-project.json` says `sourceApiVersion
65.0`, the org is on **67.0**.

| Expected | Decision it settles |
|---|---|
| CLI ≥ 2.148, plugin-agent ≥ 2.0.4, `agent adl` / `trace` / `run-eval` present | Whether Probes 3, 5 and 6 are even testable |

### ✅ Result — 2026-08-23. Passed, after a Windows detour worth recording.

**Before:** `@salesforce/cli/2.125.2`, published **179 days** earlier (25 Feb 2026).
`sf agent` carried four leaf commands — `activate`, `create`, `deactivate`, `preview`.
`sf agent test` carried five — no `run-eval`. No `adl`, no `mcp`, no `trace`. Exactly the
gap the plan predicted.

**After:** `@salesforce/cli/2.148.3`, and all four missing surfaces present:

```
agent adl             Commands to manage Agentforce Data Libraries.
agent mcp             Commands to manage MCP server registrations in the API Catalog.
agent trace           Delete trace files from an agent preview session.
agent test run-eval   Run rich evaluation tests against an Agentforce agent.
```

#### ⚠️ The detour — `sf update` half-failed on Windows

`sf update` downloaded 2.148.3 correctly, then died cleaning up:

```
Error: EPERM: operation not permitted, unlink
'C:\Users\DELL\AppData\Local\sf\client\2.125.2-30d6901\bin\node.exe'
The batch file cannot be found.
```

The old `node.exe` was the process running the update, so Windows would not let it be
unlinked. **`sf` then silently fell back to an older bundled copy and reported 2.123.1** — a
*downgrade*, and one that would have made every later probe meaningless while looking like it
had worked.

The cause is visible in the launcher, `C:\Program Files\sf\bin\sf.cmd`:

```bat
if exist "%LOCALAPPDATA%\sf\client\bin\sf.cmd" (
  "%LOCALAPPDATA%\sf\client\bin\sf.cmd" %*
) else (
  "%~dp0\..\client\bin\node.exe" ... rem the bundled fallback
)
```

`client\bin` is a **junction** to the active version. The failed cleanup destroyed it, so
every `sf` call took the else branch into the installer's own bundled copy. Both versions were
sitting in `client\` — `2.125.2-30d6901` and `2.148.3-ddda74a` — and
`2.148.3-ddda74a\bin\sf.cmd` ran correctly when invoked directly. **Only the pointer was
broken.**

**Fix — two lines, no reinstall:**

```powershell
$c = "$env:LOCALAPPDATA\sf\client"
New-Item -ItemType Junction -Path "$c\bin" -Target "$c\2.148.3-ddda74a\bin"
'{"current":"2.148.3"}' | Out-File "$env:LOCALAPPDATA\sf\version" -Encoding ascii -NoNewline
```

*(The `version` file still read `{"current":"2.125.2"}`; both had to change.)*

**Worth knowing for anyone reproducing this repo on Windows:** a failed `sf update` can leave
the CLI reporting an **older** version than before, with no error at the point of use. Check
`sf version` after every update; if it dropped, the junction is the cause, not the download.

#### Two things settled for free

**🟢 Wall §3.5 is dead, and the error message is the proof.** Redeploying the scorer probe now
fails differently:

| Before | After |
|---|---|
| `RegistryError: Missing metadata type definition in registry for id 'AiAgentScorerDefinition'` | `ComponentSetError: No source-backed components present in the package.` |

The second error means the registry **knows the type** and merely found no local file for it —
which is correct, because there is none in `force-app` yet. The `--metadata-dir` workaround can
be retired.

**API version aligned.** `sfdx-project.json` said `65.0`; the org reports `67.0`. Bumped to
`67.0` — `AiAuthoringBundle` requires 65.0+, and Probe 3 should not run against a stale source
API version.

**Side effects checked:** the linked `sfdx-blast-radius` plugin survived the update, and
`code-analyzer 5.15.0` came along with the new CLI.

---

## Probe 2 · A fresh Agentforce Developer Edition org — 20 minutes

**Why:** This is the highest-leverage probe, because it may remove **two** walls at once —
and neither reviewer stated it that way.

Two independent findings point at the same cause:

- **Ours:** all 1,855 sObjects in `VoltStreamDev` were enumerated. **There is not one
  `ssot__*` object.** Data Cloud is not provisioned. That is why the scorer prompt template
  crashes with an unhandled null — the `agentforce_session_tracing` types have no backing
  definition to resolve against.
- **R9's:** *"Pre-2025 classic DE orgs come without Agentforce/Data Cloud provisioning"* and
  may not be recognised at the SFAP gateway that `agent publish` POSTs to.

**The current org is a pre-2025 classic DE. A new Agentforce DE ships with Agentforce +
Data 360 + 10 GB, and does not expire.**

```bash
# sign up at developer.salesforce.com/signup  (choose the Agentforce edition)
sf org login web --alias VoltStreamAF --set-default
sf org display --target-org VoltStreamAF
```

Then check for the thing the old org lacks:

```bash
sf sobject list --sobject all --target-org VoltStreamAF | grep -c "ssot__"
```

| Expected | Decision it settles |
|---|---|
| A non-zero `ssot__` count | Whether Probes 3 and 4 should run against the **new** org rather than the old one |

⚠️ **Do not migrate anything yet.** This probe answers one question: does a fresh org have
what the old one lacks. Migration is a separate decision.

### ❌ Result — 2026-08-23. **Probe cancelled. The org is already the right kind.**

The premise was R9's: *"pre-2025 classic DE orgs come without Agentforce/Data Cloud
provisioning and may not be recognised at the SFAP gateway."* **That hypothesis does not
apply here**, and it took one query to find out:

```
Name          OrganizationType     InstanceName   CreatedDate                IsSandbox
Salesforce    Developer Edition    CAN98          2026-02-17T13:10:43.000Z   false
```

Created **17 February 2026**. The username is `…@**agentforce.com**` and the instance is
`your-org-**dev-ed**` — the signatures of the *new* Agentforce Developer Edition
signup flow, not a legacy org. **A fresh org would be the same kind of org.**

#### And Data Cloud is licensed — it is simply not set up

This is the part that reframes wall §3.6. The licence query:

| Permission Set Licence | Total | Used |
|---|---|---|
| **Data Cloud** (`GenieDataPlatformStarterPsl`) | **200,000** | **2** |
| Customer Data Cloud for Marketing | 200,000 | 0 |
| Agentforce (Default) (`EinsteinGPTCopilotPsl`) | 5 | 1 |
| **Agentforce Service Agent User** | 200 | **1** |
| Agentforce Service Agent Builder | 10,000 | 1 |
| Agent platform builder | 5 | 0 |
| Einstein Prompt Templates | 5 | 2 |

And yet `ssot__*` / `__dlm` object count is still **0**.

**So the state is "licensed but not provisioned", not "unavailable."** That is a materially
different diagnosis from the one recorded in Phase 0, and it means the scorer question is now
about running the Data Cloud setup, not about acquiring an entitlement. **That moves to Probe 4.**

**Decision: no new org.** Probe 2 is closed without action, and the two hours it would have
cost go into Probe 3 instead — which is what actually broke the wall.

---

## Probe 3 · Agent Script publish — the full recipe — 30 minutes

**Why:** This single result decides whether Days 5–6 author the agent in Agent Script or fall
back to classic `Bot` / `BotVersion` XML. Three documented causes exist for the `404`, and we
have never eliminated any of them.

### 3a · Fix the agent user — the most likely cause

Salesforce's own known-issues file: the `default_agent_user` must be a user with the
**"Einstein Agent" profile licence**, and **if a System Administrator is supplied the error
returns masked.** We supplied our own admin.

The template writes the placeholder literally (`agentScriptTemplate.js:40` —
`default_agent_user: "NEW AGENT USER"`), which is exactly what we saw first.

**Two ways out. Prefer the second.**

```bash
# Option A — create a proper agent user
sf org create agent-user --target-org <org>
```

```agentscript
# Option B — declare an employee agent and drop the block entirely
agent_type: AgentforceEmployeeAgent
# the `access:` block is then skipped altogether
```

**Option B is better for this project for a reason beyond convenience:** an employee agent
**runs as the invoking user**, which is precisely what the `WITH USER_MODE` security story
requires. The fix and the architecture agree.

Also note: `default_agent_user` belongs in the **`access:`** block, not `config:`.

### 3b · Check two syntax traps that pass validate and fail publish

Both are documented in `forcedotcom/sf-skills` known-issues, and both produce **exactly our
symptom** — validate succeeds, publish returns 404:

| Wrong | Right |
|---|---|
| `connection customerwebclient:` | `connection customer_web_client:` |
| `outbound_route_name: MyFlow` | `outbound_route_name: flow://MyFlow` |

```bash
grep -n "customerwebclient\|outbound_route_name" force-app/main/default/aiAuthoringBundles/*/*.agent
```

### 3c · Use the Metadata API path — which we have never tried

We only ever ran `sf agent publish authoring-bundle`. **Trailhead's own pro-code project does
not use that command at all** — it deploys the bundle and publishes from the Builder:

```bash
sf project deploy start --metadata AiAuthoringBundle:VS_Phase0_Probe --target-org <org>
sf org open agent --authoring-bundle VS_Phase0_Probe --target-org <org>
# then: Publish in the Builder UI
```

### 3d · Only if all of the above fail — capture the failing URL

```bash
SF_LOG_LEVEL=trace sf agent publish authoring-bundle --api-name VS_Phase0_Probe --api-version 67.0
```

The URL in that log is what goes in the bug report. Publish POSTs to `api.salesforce.com`
with fallbacks to `test.api.` and `dev.api.` — if all three 404, that is the finding.

| Expected | Decision it settles |
|---|---|
| Publish succeeds by **any** route | **Agent Script becomes the deployed source**, not merely design source. `before_reasoning` and `@subagent` become available, which restores the single-turn briefing demo. |
| All routes fail on both orgs | Classic `Bot` path for the runtime; `.agent` stays design source; **and we have a genuine, reproducible, unreported platform bug** with a captured URL. |

### ✅ Result — 2026-08-23. **PUBLISHED. The wall is gone, and the cause was cause #1.**

The `.agent` file said:

```yaml
config:
    default_agent_user: "your-admin@example.com"     # ← System Administrator
```

That is this project's own admin user. Salesforce's known-issues file states that supplying a
System Administrator makes the failure **return masked** — and a masked failure at the commit
step is precisely the bare `ERROR_HTTP_404` recorded in Phase 0.

**The user that publish actually wants was already sitting in the org**, created as a side
effect of building the classic-path agent months earlier:

```
Username   vs_phase0_probe_classic@00dgl00000lpwon292859819.ext
Name       EinsteinServiceAgent User
Profile    Einstein Agent User          ← the licence the publish step requires
IsActive   true
```

**One line changed.** Then:

```
sf agent validate authoring-bundle  →  {"status": 0, "result": {"success": true}}

sf agent publish authoring-bundle   →  {"status": 0, "result": {
                                          "success": true,
                                          "botDeveloperName": "VS_Phase0_Probe",
                                          "summary": {"retrieved": 3, "deployed": 3}}}
```

Verified in the org — the Agent Script compiled into real runtime metadata:

```
BotDefinition   VS_Phase0_Probe   ExternalCopilot   EinsteinServiceAgent
BotVersion      VS_Phase0_Probe   version 1         Inactive
```

*(`Inactive` is expected; `sf agent activate` is a separate step.)*

#### What this settles, and it is a lot

**Agent Script is now the deployed source, not design source.** The repository's central claim
— that the agent is authored as source and deploys from source — holds without a footnote.

**Days 5–6 are Agent Script, not legacy XML.** Which means the control-plane features become
available and the hero demo returns:

- **`before_reasoning`** — pin the four regulatory checks as deterministic steps *before* the
  model reasons. Four action invocations in the trace, zero planner discretion, one turn.
- **`available when`** — gates that re-evaluate every iteration, so `ErstelleAufgabe` unlocks
  only when a section returns `BLOCKIERT`.
- **`@subagent.<name>`** — call-and-return delegation, and **`@utils.transition`** — one-way
  handoff.

That is a stronger demo than the composite Apex action, and it is *more* deterministic, not
less: the flow is written in the `.agent` file rather than left to the planner.

#### Three things ruled out along the way

| Suspect | Verdict |
|---|---|
| The two documented syntax traps — `customerwebclient` instead of `customer_web_client`, and `outbound_route_name` without a `flow://` prefix | **Neither present.** Grepped the bundle; clean. Not the cause. |
| Org age / SFAP gateway provisioning | **Ruled out by Probe 2.** Org created February 2026. |
| `default_agent_user` in the wrong block | **Does not apply to this grammar.** R8 said it belongs in `access:`; the CLI-generated file carries it in `config:` and **publishes successfully from there.** Do not move it. |

**So the licence was the sole cause.** One field, one masked error, five months of a wall.

#### The finding worth keeping

Two independent researchers reached this conclusion from documentation; the org confirmed it
in one query. The generalisable lesson is not about agent users:

> **A masked server-side error is indistinguishable from a platform limit.** Phase 0 recorded
> this as *"reproduced in two orgs, therefore an edition boundary."* It reproduced in two orgs
> because **both orgs had the same misconfiguration** — the same `.agent` file was used in
> both. Reproducibility across environments proves the input is constant, not that the
> platform is at fault.

---

## Probe 4 · Is Session Tracing even present? — 10 minutes

**Why:** The fastest possible test of whether the custom scorer is a wall at all. R8's
framing is right: ten minutes settles it.

**Setup → Einstein Audit, Analytics, and Monitoring → is there an "Agentforce Session
Tracing" toggle?**

- **Toggle absent** → the scorer is a **provisioning/edition wall**. Stop. Probe 5 is the
  answer instead.
- **Toggle present** → enable it, confirm the Standard Data Model version in Data 360, and
  retry the template deploy. If it then creates: build **one** scorer in the Agentforce
  Studio UI and retrieve it —

```bash
sf project retrieve start --metadata GenAiPromptTemplate:VS_Scorer_Echo --target-org <org>
```

The retrieved XML contains the answer to the question that has been open since Phase 0:
**the valid `<definition>` value for the `Session` input.** From then on it deploys from
source, and bootstrapping a type once through the UI is a footnote, not a broken claim.

Two things to remember if it does deploy:

- **`GenAiPromptTemplate` must appear before `AiAgentScorerDefinition` in `package.xml`.**
- The **Agentforce Scorer Beta** permission set is required.

| Expected | Decision it settles |
|---|---|
| Toggle absent | The scorer is out of scope for v1. **Say so plainly and move to Probe 5.** |
| Toggle present and template deploys | The custom scorer returns, and the `Session` schema question closes |

### 🟡 Result — 2026-08-23. **The NPE is gone. The schema is narrowed to one unknown. Blocked on Setup UI.**

#### The crash was half the story, and the newer CLI removed it

Redeploying a `scorerMeasurement` template on CLI 2.148.3 no longer crashes the server. Phase 0
recorded an unhandled null; today the same file returns a **proper validation message**:

| Phase 0 | 2026-08-23 |
|---|---|
| `Cannot invoke "…GenAiPromptTypeEnum.getPath()" because …getType() is null` | `Required Generative AI Prompt Template Input definitions are missing: [[AllowedRange, Session]]` |

**The type resolves.** `agentforce_session_tracing__scorerMeasurement` is recognised, and the
server is now naming what it wants rather than falling over.

#### Walking the remaining schema — five attempts, five distinct answers

Each rejection narrowed the next. This is the useful part of the probe:

| `<definition>` for `Session` | Server response |
|---|---|
| *element omitted* | `Required field is missing: definition` — **it is mandatory** |
| `SOBJECT://AiAgentSession__dlm` | `We can't find the related records for the prompt template` — **the `SOBJECT://` grammar is valid**; the object simply does not exist |
| `SOBJECT://AiAgentSession` | same — grammar fine, object absent |
| `primitive://String` | `The … Input primitive://String **doesn't match any supported inputs** for the … Type agentforce_session_tracing__scorerMeasurement` |
| `agentforce_session_tracing://AiAgentSession` | **the NPE returns** — so the crash is specific to this URI scheme, not to the type |

**Read together:** the `Session` input wants an **SObject that does not exist in this org**. The
`SOBJECT://` scheme validates; `primitive://` is explicitly not among the supported inputs; and the
namespaced scheme is what triggers the unhandled null.

That is consistent with, and now independently supports, Probe 2's rediagnosis: **the Session
Tracing data model is licensed but not provisioned**, so there is no object for `SOBJECT://` to
resolve against.

The server will not enumerate the whitelist — *"Specify a valid input and try again"* is as far as
it goes. **One unknown remains: the object name.**

#### What is confirmed absent

```
PermissionSet WHERE Name LIKE '%Scorer%' OR '%Observ%' OR '%Tracing%'   →  none
ssot__* / __dlm object count                                            →  0
CLI command to provision Data Cloud                                     →  none exists
```

There is no `sf data-cloud` surface. **Provisioning is a Setup wizard, and Setup is not
scriptable** — this is where the CLI stops.

#### Two things confirmed in passing

The org's retrievable metadata types now include **`AiAgentScorerDefinition`** and
**`AiTestingDefinition`** — independent confirmation of Probe 1's registry fix. And **`AiRetriever`
is not in the list**, which matches the research finding that it was never a metadata type at all.

#### Verdict, and why it is deliberately not being pushed further

Two routes remain, both requiring the Setup UI:

1. **Provision Data Cloud**, then retry — if the DMO appears, `SOBJECT://` resolves.
2. **Build one scorer in Agentforce Studio and retrieve it** — the retrieved XML contains the
   answer, and bootstrapping a type once through the UI is a footnote rather than a broken claim.

**Neither is being done yet, on purpose.** Probe 5 tests whether the platform's *built-in*
groundedness evaluators are sufficient. If they are, the custom scorer is not on the critical path
at all, and the Setup work is optional rather than blocking. **Sequencing matters more than
completeness here.**

---

## Probe 5 · G3 `run-eval` and built-in groundedness — 30 minutes

**Why:** This may make the entire scorer question moot, and no reviewer knew about it —
because the command is **twenty-three days old**.

`plugin-agent` 2.0.0 (30 July 2026) shipped `sf agent test run-eval`, whose evaluator
namespace includes:

```
evaluator.answer_faithfulness      evaluator.hallucination_detection
evaluator.citation_recall          evaluator.text_alignment
```

These are RAGAS-family groundedness metrics, **each with its own `threshold`**. And
`run-eval` **deploys no metadata at all** — a spec file goes in, JUnit comes out. No org
artifact, no version binding.

```bash
sf agent test run-eval --spec specs/phase0-probe-testSpec.yaml \
  --target-org <org> --result-format junit
```

Try one case with an explicit evaluator and threshold:

```yaml
scoring:
  - metric_name: answer_faithfulness
    generated_output: "..."
    reference_answer: "..."
    threshold: 0.8
```

| Expected | Decision it settles |
|---|---|
| `answer_faithfulness` returns a score | **The custom scorer is unnecessary.** Groundedness ships built in. |
| It fails or is unavailable in this edition | Fall back to the **deterministic transcript gate** — parse `.sfdx/agents/<id>/sessions/<sessionId>/transcript.jsonl`, extract every `§` the agent cited, and require it to appear in the `rechtsgrundlage` returned by an action that ran in that turn. **No LLM, no platform dependency, and arguably a stronger claim.** |

**Either outcome is a win.** The second is the one to prefer if both work.

### ✅ Result — 2026-08-23. **Two more walls turn out to be G1-only. And the groundedness answer is not the one that was expected.**

`sf agent test run-eval` exists on CLI 2.148.3 and accepts the **same YAML spec** as
`agent test run`. Ran the untouched Phase 0 spec against it. Two findings arrived immediately,
both larger than the probe's stated goal.

#### 🟢 Wall §3.2 does not exist in G3

Phase 0 recorded, 5 runs out of 5, that a custom topic name came back truncated to `"p"`. The
same spec, same agent, same org, through the G3 runner:

```json
{
  "type": "evaluator.planner_topic_assertion",
  "score": 1,
  "is_pass": true,
  "actual_value":   "p_16jgL000002KylF_Eichfrist_Monitoring",
  "expected_value": "p_16jgL000002KylF_Eichfrist_Monitoring"
}
```

**Full string. Passes.** The truncation is a defect of the **G1 / Testing Center evaluation
service**, not of the platform. Two independent source reads had already shown the CLI passes
values verbatim; this locates the fault precisely, because a second runner reading the same
session does not reproduce it.

**Consequence:** route assertions are usable again — on G3. The advice to abandon
`topic_assertion` was correct *for G1* and is now scoped rather than general.

#### 🟢 Wall §3.3 does not exist in G3 either

The pancake-refusal case, which G1 scored `coherence: 0 / FAILURE` — *"completely incoherent…
unrelated to the task"*:

| Runner | Evaluator | Result |
|---|---|---|
| G1 | `coherence` (reference-free) | **0 · FAIL** |
| **G3** | `evaluator.bot_response_rating` (reference-based) | **5 · PASS** |

G3 did not run `coherence` at all. It translated the case into a **reference-based** judge and
compared against the spec's own `expectedOutcome: "Eine höfliche Ablehnung ohne Rezept."` —
which is exactly the design R8 and R9 both prescribed, except that **the runner does it
automatically.** No suite-splitting hack required.

*(Case 0 still fails, and legitimately: `EmployeeCopilot__AnswerQuestionsWithKnowledge` stole
the turn again — wall §3.4, unchanged — and the trace now shows why it then failed:
`"We couldn't find a data library assigned to this agent."`)*

#### 📋 The server's complete step-type enum — documented nowhere

Sending an invalid step type makes the evaluation service enumerate every valid one. **56
types.** This list does not appear in any public documentation:

```
agent.create_session          agent.create_session_v2       agent.create_preview_session
agent.send_message            agent.send_message_v2         agent.send_preview_message
agent.get_state               agent.get_state_v2            agent.get_state_enhanced
agent.get_state_stdm          agent.get_conversation_state_stdm
agent.get_plan                agent.end_session             agent.start_voice_conv

evaluator.string_assertion    evaluator.numeric_assertion   evaluator.list_assertion
evaluator.planner_topic_assertion            evaluator.planner_actions_assertion
evaluator.conversation_topic_assertion       evaluator.conversation_actions_assertion
evaluator.agent_handoff_assertion            evaluator.conversation_handoff_assertion
evaluator.latency_presence_assertion
evaluator.bot_response_rating evaluator.instruction_adherence
evaluator.rag_quality         evaluator.sfdc_rag_quality
evaluator.text_quality        evaluator.text_alignment
evaluator.custom_aspect_critique             evaluator.task_resolution
evaluator.formula             evaluator.agentforce_eval
evaluator.easy_edge.determinism / .quality / .graph_traversal / .implicit_feedback

general.echo                  general.string_concat         llmgw.generate
retriever.retrieve_text       prompt_engine.generate_prompt / .hydrate_prompt
```

**`evaluator.instruction_adherence` and `evaluator.custom_aspect_critique` are the two worth
returning to** — the first is the natural judge for *"never estimate a deadline"*, the second
takes an arbitrary rubric.

#### ⚠️ The CLI ships evaluator names the server rejects

`evalNormalizer.js` carries `DEFAULT_METRIC_NAMES` for **`evaluator.answer_faithfulness`**,
**`evaluator.hallucination_detection`** and **`evaluator.citation_recall`**. The server accepts
none of the three. **The client is ahead of the evaluation service** — those are either
forthcoming or renamed.

What exists today is `evaluator.rag_quality`, whose `metric_name` the server restricts to
exactly three values:

```
'ragas.answer_relevancy' | 'ragas.context_relevancy' | 'ragas.faithfulness'
```

**`ragas.faithfulness` returned an empty evaluation** — no score, no error. It almost certainly
requires retrieved contexts, and the CLI's field aliases only map to `generated_output` and
`reference_answer`. With no retriever provisioned, there is nothing for it to be faithful *to*.

#### 🔴 And the measurement that settles the design question

`evaluator.text_alignment` with `base.cosine_similarity` **works, returns real numbers, needs no
retriever, no Data Cloud, no scorer.** Three German legal statements against the same reference:

| Case | Statement | Score |
|---|---|---|
| Correct | *"Die Eichfrist für Ladepunkte beträgt acht Jahre."* | **0.919** |
| Wrong | *"Die Eichfrist beginnt mit der Installation und beträgt fünf Jahre."* | **0.888** |
| Citing repealed law | *"LSV § 4 verlangt Kartenzahlung an allen öffentlichen Ladepunkten."* | **0.855** |

The ordering is right. **The spread is six points between a correct statement and an outright
falsehood.** German legal prose is lexically similar whether or not it is true — the vocabulary
is the same, only the numbers and the paragraph references differ, and those are exactly what
cosine similarity discounts.

**Any threshold in the 0.85–0.92 band would be arbitrary, and the metric would pass a lie about
a repealed ordinance at 0.855.**

#### Verdict

The probe asked whether a built-in groundedness evaluator makes the custom scorer unnecessary.
**The answer is better than yes: it makes the whole semantic-scoring approach the wrong
instrument for this domain, and now there is a number proving it.**

**The deterministic transcript gate is not the fallback. It is the correct design**, and it can
now be argued from measurement rather than from platform limitation:

> Every `§` the agent cites must appear in the `rechtsgrundlage` returned by an action that ran
> in that turn. No LLM, no embedding, no threshold to defend. A citation is either handed over
> by the engine or it is invented — and that is a **binary**, not a similarity.

**Wall §3.6 therefore drops off the critical path.** The custom scorer becomes optional
enrichment; Probe 4's Setup work is no longer blocking.

---

## Probe 6 · Settle two contradictions — 10 minutes

Two places where a reviewer and our own measurement disagree. Both are cheap to resolve and
both would otherwise propagate into the build as a wrong assumption.

### 6a · `EinsteinGptSettings` field list

R8 says the type carries `enableEinsteinGPTDeployPromptTemplatesAsActive`, which would end
the two-deploy dance for prompt templates. Our agent enumerated **nine** fields and that was
not among them.

```bash
sf project retrieve start --metadata Settings:EinsteinGpt --target-org <org>
grep -o "<[a-zA-Z]*>" force-app/main/default/settings/EinsteinGpt.settings-meta.xml | sort -u
```

| If the field exists | If it does not |
|---|---|
| Set it, retest, delete the two-deploy script | Commit `scripts/prompt-activate.js` and record it as a platform reality |

### 6b · Conversation-level testing limits

R9 cites the official Considerations page for **20 turns / 3 concurrent suites**. Our
research found no documented turn limit and an official ceiling of **10 in-progress runs**.
One of these is wrong and it affects suite planning.

```bash
sf agent test run --api-name <suite> --target-org <org> --json
# then start a second and third concurrently and observe where it refuses
```

| Expected | Decision it settles |
|---|---|
| The real concurrency and turn ceilings | How the ~23-case suite is scheduled — and whether it fits under the **150 LLM generations/hour** Developer Edition limit |

### ✅ Result — 2026-08-23. **One reviewer was right about the field and wrong about what it does. One question is left open on purpose.**

#### 6a — `EinsteinGptSettings`: we undercounted, R8 was right, and the conclusion survives anyway

Retrieved the live settings. **Thirteen fields, not nine.** The earlier enumeration was incomplete:

```xml
<disableAIProvAWSBedrock>                        <disableAIProvAzureOpenAI>
<disableAIProvOpenAI>                            <disableAIProvVertexGemini>
<disableAIProviderRegionFallback>                <enableAIModelBeta>
<enableDeployOnlyActivePromptTemplateVersion>    ← not previously recorded
<enableEinsteinGPTDeployPromptTemplatesAsActive> ← R8's field. It exists.
<enableEinsteinGptAllowUnsafePTInputChanges>     <enableEinsteinGptGlobalLangSupport>
<enableEinsteinGptPlatform>true                  <enableEnhancedPromptSecurity>
<enablePBJinjaSyntaxBeta>
```

**R8 was right that the field exists.** Our count was wrong and is corrected here.

**But it does not do what the name suggests.** Tested directly:

1. Deployed `enableEinsteinGPTDeployPromptTemplatesAsActive = true` → `Succeeded`
2. Deployed a fresh Flex template carrying **no** `versionIdentifier` and **no**
   `activeVersionIdentifier` → `Succeeded` in one deploy
3. Retrieved it back

| Template | Deploy method | `activeVersionIdentifier` on retrieve |
|---|---|---|
| `VS_Scorer_Echo` | Phase 0, **two-step dance** | **present** |
| `VS_Activation_Probe` | **one deploy**, flag ON | **absent** |

**The template did not come back active.** Read alongside its sibling field
`enableDeployOnlyActivePromptTemplateVersion`, both flags appear to govern how *existing* active
state is carried during a deploy — not whether a *new* version is auto-activated.

**Wall §3.7 stands.** The two-deploy dance is real; commit `scripts/prompt-activate.js`.

*(`GenAiPromptTemplateActv` lists nothing for either template — consistent with R9's note that
the type covers Salesforce-provided templates only. It is not a way to check activation.)*

**And one unexpected detail.** Both templates carry the **identical** version identifier:

```
KzZqWgd5jMzXkpnhkT4MIUQfuFYllHgFALWfY/Vih28=_1
```

Their content is completely different. **So the identifier is not a content digest** — Phase 0
recorded it as "a base64 digest plus an ordinal", which implied hashing. It is org-scoped plus an
ordinal instead, which makes it **predictable, and therefore scriptable**. That is a small
correction that makes the activation script simpler than expected.

**Still no Trust Layer fields.** Masking, audit trail and retention are absent from all thirteen.
The "do not claim Trust Layer as code" rule holds unchanged. *(`enableEnhancedPromptSecurity` is
security-adjacent and worth a look later, but it is not masking.)*

**Cleanup:** the flag was reverted to `false` and `VS_Activation_Probe` was deleted. The org is
back to its pre-probe state.

#### 6b — Conversation limits: no client-side limit exists, and the server-side number is left unresolved

The CLI enforces multi-turn constraints through named error messages, and reading them settles
part of the question:

| Message key | What it enforces |
|---|---|
| `ngtTaskResolutionRequiresConversationHistory` | `task_resolution` requires `conversationHistory` on at least one input |
| `ngtConversationHistoryIndexAllOrNothing` | `index:` is all-or-nothing across turns |
| `ngtMultiAgentMissingHandoff` | a **multi-agent subject** must include an `agent_handoff_match` scorer with an expected value |
| `ngtLooksLikeLegacySpec` | *"use `--test-runner testing-center` for legacy authoring, or **hand-edit the deployed XML for `<scorer scorerType="Custom">` blocks on NGT**"* |
| `ambiguousTestDefinition` | a G1 and a G2 definition sharing one name is an error — do not let both exist |

**There is no `maxTurns`, `max_turns` or concurrency constant anywhere in the client.** So R9's
*"20 turns"* is not a client-side limit. Whether it is a documented server ceiling could not be
settled by reading code.

**The concurrency question is deliberately left open.** Settling *3 versus 10 concurrent runs*
requires firing several suites at the org, and every one consumes against the Developer Edition
ceiling of **150 LLM generations per hour** — a ceiling this session has already drawn on. With
exactly one suite in existence, the answer changes nothing today.

**It becomes worth measuring when the suite reaches ~23 cases**, because at that point the
scheduling question is real. Recorded as open, with the reason, rather than spent now.

*(Also worth carrying forward from `ngtMultiAgentMissingHandoff`: **multi-agent subjects are a
first-class, testable thing in NGT.** Orchestration was cancelled on 2026-08-22 for cost and
determinism reasons, not capability ones — and this confirms the testing surface would have been
there if it were ever revisited.)*

---

## After the probes

Write the results into this file, commit it, and update the wall table in `CLAUDE.md`. Then
**stop probing** and build the vertical slice:

```
Ladepunkt__c  +  Eingriff__c            event model, four Eichfrist start branches
      ↓
EichrechtService                        the state machine
      ↓
Rechtsnorm__mdt                         with Gueltig_von__c / Gueltig_bis__c
      ↓
DecisionResult                          legalSources[], NOT_APPLICABLE ≠ UNKNOWN
      ↓
one LWC card  +  one agent action  +  one eval case
```

That slice proves the whole architecture end to end. If a platform blocker exists, it
surfaces there — early, and on one object instead of six. Partner and Netzanschluss then
follow the same template with no new architectural risk.

**The standing rule for this phase:** the next thing committed should be deployed metadata,
not another document.
