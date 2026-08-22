# Agentforce + German market research — findings

Research date: **2026-08-22**. Parallel research agents covering Agentforce’s metadata,
testing and grounding model, the public GitHub corpus, the German market, and E.ON as a
target employer. Everything below is sourced; items marked ⚠️ could not be verified and
must be checked before use.

The E.ON study (§11) is complete: business, products, partner ecosystem, the Salesforce
footprint, and the operational bottlenecks.

This file exists so a later session does not have to re-run the research.

---

## 1. Org state — VoltStreamDev (`00Dxx0000000000XXX`)

Verified by direct query on 2026-08-22.

| | |
|---|---|
| User | `your-admin@example.com` |
| Edition / instance / API | Developer Edition / CAN98 / **67.0** (repo is on 65.0) |
| Currency / locale / TZ | **USD / en_US / America/Los_Angeles** |
| Installed packages | `devedapp` 0.9 · **`dlrs` 2.25** (dead weight) · **`SBQQ` 260.2** |

### Data — all of it is stock Salesforce demo data

```
Product2         17   GenWatt diesel/gasoline/propane generators, Installation, SLA
PricebookEntry   34   (17 in each of two pricebooks)
Account          14   United Oil, Burlington Textiles, Grand Hotels, Univ. of Arizona
Opportunity      44   generator deals, 20 Closed Won, Reseller__c null on the big ones
Reseller__c       6
SBQQ__Quote__c    1   Q-00000, Draft, net 0
```

**`Standard Price Book` has `IsActive = false`** — CPQ pricing needs it active.

All CPQ config objects are empty: `SBQQ__ProductOption__c`, `SBQQ__ProductFeature__c`,
`SBQQ__DiscountSchedule__c`, `SBQQ__ProductRule__c`, `SBQQ__PriceRule__c`,
`SBQQ__ConfigurationAttribute__c`, `SBQQ__BlockPrice__c`, `SBQQ__Subscription__c`.

### Agentforce — licensed, provisioned, but switched OFF

Zero agents: `AIApplication`, `GenAiPlannerDefinition`, `GenAiPluginDefinition`,
`GenAiFunctionDefinition`, `GenAiPromptTemplate`, `McpServerDefinition` all return
**0 records**.

Licenses present: Agentforce (Default) 5/1 · Agent platform builder 5/0 ·
Agentforce Service Agent Builder 10000/1 · Service Agent User 200/0 ·
Einstein Prompt Templates 5/1 · **Data Cloud 200000/2** · CPQ 4/1 · CPQ AA 4/0.

**Hard blocker:** `Bot`, `BotVersion` and `AiAuthoringBundle` metadata types all
return `INVALID_TYPE: Cannot use ... in this organization`. Agentforce must be
enabled in Setup first. `GenAiPlannerBundle`, `GenAiPlugin`, `GenAiFunction`,
`AiEvaluationDefinition`, `AiAgentScorerDefinition`, `GenAiPromptTemplate` are all
recognized (return "no metadata found"), so they unlock with that toggle.

MCP platform entities **do** exist in the org: `McpServerDefinition`,
`McpServerToolDefinition`, `McpServerToolApiDefinition`, `McpServerPromptDefinition`,
`McpServerResourceDefinition`, `McpServerAccess`.

> ### ⚠️ Corrected 2026-08-22 — this paragraph described a CLI we do not have
>
> The claim was that `sf` CLI **2.125.2** ships `agent adl *`, `agent mcp *`, `agent trace *`,
> `agent test run-eval` and a programmatic `agent preview`. **Checked against the installed
> binary: it ships none of them.**
>
> `sf agent --help` on 2.125.2 / `plugin-agent` 1.30.6 lists exactly `generate`, `preview`,
> `publish`, `test`, `validate`, plus `activate` / `create` / `deactivate`. `sf agent test` has
> `create|list|results|resume|run` — **no `run-eval`**. `sf agent preview` is a **single
> interactive command** — no `start|send|end|sessions`. And `agent adl`, `agent trace` and
> `agent mcp` return *"is not a sf command."*
>
> **All of it arrived in `@salesforce/plugin-agent` 2.0.0 on 30 July 2026 — twenty-three days ago.**
>
> | | Installed | Latest | Published |
> |---|---|---|---|
> | `@salesforce/cli` | **2.125.2** *(2026-02-25)* | 2.148.3 | 2026-08-12 |
> | `@salesforce/plugin-agent` | **1.30.6** *(2026-02-24)* | **2.0.4** | **2026-08-19** |
>
> **This explains the prior-art census, and it is good news.** `sf agent adl` returns 39 public
> files; `agent test run-eval` 21 files across 9 repos; `AiTestingDefinition` 4 files across 3
> repos, two of which are Salesforce's own tooling. Those numbers are near-zero **because the
> commands did not exist a month ago.** This is not a mature field with a crowded scoreboard —
> it is a surface that opened three weeks ago and nobody has built on it. The window is real and
> it is narrow.
>
> **Prerequisite, to be stated rather than assumed:**
> ```bash
> sf plugins install @salesforce/plugin-agent@latest   # or: sf update
> ```
>
> **A default-behaviour trap that will bite silently.** In the installed 1.30.6, `sf agent
> preview` **simulates actions by default** and `--use-live-actions` is opt-in. In 2.x with
> `--authoring-bundle`, **neither mode is default and you must choose explicitly.** A script
> written against v1 semantics changes meaning after the upgrade without erroring.
>
> **And two things that already work, unupgraded, that had been missed:**
> - **`sf agent preview --apex-debug`** — Apex debug logging *during* an agent conversation. You
>   can watch an `@InvocableMethod` execute inside the reasoning loop.
> - **`sf agent preview --output-dir`** — writes conversation transcripts to local files. The v1
>   precursor to `agent trace`, and enough for a rudimentary local assertion harness today.
>
> **One command resolves the largest open unknown.** After upgrading:
> `sf agent adl list --target-org VoltStreamDev` answers whether Data Library provisioning works
> in a free Developer Edition org — which is what the corpus-mutation design depends on.

### Blocking prerequisites, in order

1. Rebuild the product catalog + demo data (everything else sits on it)
2. Setup → Einstein Setup → enable Agentforce (unlocks `Bot` / `AiAuthoringBundle`)
3. Assign self: Agentforce (Default), Agent platform builder, Einstein Prompt Templates
4. Uninstall DLRS
5. Bump `sourceApiVersion` 65.0 → 67.0
6. **Verify agent tests actually run in a Developer Edition org** — see §3

---

## 2. Agentforce architecture — what is real as of Aug 2026

### The platform reset (this is the timing advantage)

- **13 July 2026** — Agent Script + the new Agentforce Builder became the **default**.
  Agents are authored as `.agent` files under `aiAuthoringBundles/`
  (`AiAuthoringBundle` metadata type). `GenAiPlannerBundle` is demoted to generated
  runtime output.
- **April 2026** — "Topics" were officially renamed **"subagents"**.
- `genAiPlanner` was deprecated at API v64.0.

Consequence: essentially the entire public corpus of Agentforce demos is on the
legacy XML model. Anyone learning from a 2025 community repo learns the deprecated
shape. Build on Agent Script.

### Metadata map

| Type | Role |
|---|---|
| `AiAuthoringBundle` / `*.agent` | Agent Script source — the new authoring surface |
| `GenAiPlannerBundle` | Generated runtime; carries `ruleExpressions` (see below) |
| `GenAiPlugin` | Subagent (topic). `scope`, `canEscalate`, `genAiPluginInstructions` |
| `GenAiFunction` | Action. `invocationTarget`, `invocationTargetType`, `isConfirmationRequired` |
| `AiEvaluationDefinition` | Legacy (G1) test suite — API v63.0+ |
| `AiTestingDefinition` | **Undocumented** (G2/NGT) test suite — has `factuality` |
| `AiAgentScorerDefinition` | Custom LLM-as-judge scorer, declarative + prompt template |
| `EinsteinGptSettings` | Trust Layer / model-provider settings as code |

`GenAiFunction.invocationTargetType` enum: `api`, `apex`, `auraEnabled`,
`createCatalogItemRequest`, `executeIntegrationProcedure`, `externalService`, `flow`,
`generatePromptResponse`, **`mcpTool`**, `namedQuery`, `quickAction`, `retriever`,
`runExpressionSet`, `slack`, `standardInvocableAction`, `stub`.

The `mcpTool` value proves Agentforce can act as an **MCP client** — a thing the
public docs left ambiguous.

### Underused guardrails worth building on

- **`GenAiPlannerBundle.ruleExpressions` / `ruleExpressionAssignments`** — conditional
  security rules in Salesforce Expression Language (`expressionType: sel`) that lock or
  unlock subagents and actions. The only non-prose declarative guardrail in the whole
  metadata model, and badly documented.
- **`GenAiFunction.isConfirmationRequired`** — the only human-in-the-loop field that
  exists. Agent Script equivalent: `require_user_confirmation`. Agent Script also has
  `filter_from_agent` to keep a value out of the model's context.
- **`GenAiPlugin.canEscalate`** — settable only via Developer Console / Workbench /
  metadata, **not** exposed in Agentforce Builder's UI.
- **`EinsteinGptSettings.disableAIProviderRegionFallback=true`** — prevents inference
  failing over outside the model endpoint region. EU data residency expressed as code.

### FLS/CRUD — the honest answer

Agentforce enforces nothing. Every agent runs as a **running user**; actions inherit
whatever the Apex, Flow or Prompt Template grants. Apex declared `without sharing`, or
Apex that omits `WITH USER_MODE` / `Security.stripInaccessible`, bypasses FLS entirely
for anyone who can talk to the agent.

**This makes the existing VoltStream Selector rule (`WITH USER_MODE`, `LIMIT 50000`)
the actual enforcement point** — and therefore a provable claim, not a stylistic one.

⚠️ No official Salesforce doc on agent running-user security could be fetched;
synthesized from the metadata reference plus secondary sources.

---

## 3. Testing and evaluation — three generations

| Gen | Metadata | Runner | Truth metric |
|---|---|---|---|
| **G1** | `AiEvaluationDefinition` | `--test-runner testing-center` (default) | **none** |
| **G2 (NGT)** | `AiTestingDefinition` — *no public reference page* | `--test-runner agentforce-studio` | **`factuality`** (LLM 0–100) |
| **G3 (Beta)** | spec file only | `sf agent test run-eval` | `hallucination_detection`, `answer_faithfulness`, `citation_recall` |

Run-ID prefixes disambiguate: `4KB` = Testing Center, `3A2` = Agentforce Studio.

### G1 expectations (the documented set)

`topic_sequence_match` · `action_sequence_match` · `bot_response_rating` (LLM semantic,
not string match) · `coherence` · `completeness` · `conciseness` ·
`output_latency_milliseconds` · `string_comparison` · `numeric_comparison` (last two
need API v64.0+ and a `parameter[]` block).

Instruction adherence is auto-computed, scored `HIGH`/`LOW`/`UNCERTAIN`, and is **not**
settable as an expectation name.

**G1 has no groundedness, factuality, safety, toxicity or PII-leak assertion.** Its
quality metrics measure *form*, not *truth* — a fluent hallucination passes all of them.

### G2 scorer catalog (from `forcedotcom/agents/src/ngtScorerCatalog.ts`, Apache-2.0)

```
topic_sequence_match        needsExpected: true   PASS_FAIL
action_sequence_match       needsExpected: true   PASS_FAIL
agent_handoff_match         needsExpected: true   PASS_FAIL     <- multi-agent routing
bot_response_rating         needsExpected: true   LLM_PASS_FAIL
response_match              needsExpected: true   LLM_PASS_FAIL
coherence                   needsExpected: false  LLM_0_100
conciseness                 needsExpected: false  LLM_0_100
factuality                  needsExpected: false  LLM_0_100     <- the truth metric
completeness                needsExpected: false  LLM_0_100
task_resolution             needsExpected: false  LLM_0_5       (needs conversationHistory)
output_latency_milliseconds needsExpected: false  NUMERIC
```

### The custom-scorer path

`AiAgentScorerDefinition` (folder `aiAgentScorerDefinitions/`) is a declarative
LLM-as-judge backed by a `GenAiPromptTemplate` — **no Apex, no Flow**.
`inputScope` ∈ `Moment` | `Interaction` | `Session`. Deploy the prompt template and the
scorer together.

### Asserting on the grounding payload itself

`string_comparison` accepts JSONPath into the runtime data, so you can assert on what
the retriever actually returned rather than on the prose:

```
$.generatedData.invokedActions[*][?(@.function.name == 'X')].function.output.result
```

⚠️ **Each parameter value is capped at 100 characters** — long JSONPath will not fit.
Use `sf agent test run --verbose` to discover the real JSON shape.

### Limits and landmines

- ⚠️ **"Agent testing is available only in sandboxes"** — stated twice in official docs.
  This org is a Developer Edition. **Unverified whether tests run here. Verify before
  building the plan on it.**
- Testing consumes Einstein Requests + Data Cloud credits, and **can modify data**.
- Salesforce states results are **not reproducible run-to-run**.
- Testing Center is **single-turn only** in the UI (the Metadata API does accept
  `conversationHistory`).
- `--batch-size` for `run-eval` maxes at **5**.
- Concurrent `IN_PROGRESS` runs: 10. Test cases per definition: 1,000.
- `AiEvaluationDefinition` supports Metadata API + source tracking but **not** unlocked
  packaging and **not** change sets.
- **Windows bug** [`forcedotcom/cli#3503`](https://github.com/forcedotcom/cli/issues/3503)
  on `sf agent test create`. Workaround: `--preview` then deploy manually.
- Bug [`forcedotcom/cli#3314`](https://github.com/forcedotcom/cli/issues/3314):
  `sf agent generate test-spec` emitted empty `expectedActions`, making tests pass
  vacuously.
- Agent versions increment on publish and tests bind to `subjectVersion` — CI needs a
  patch step (see `Think2Corp/AgentforceCICD/scripts/patchTestVersions.sh`).
- The CLI's JSON output emits control characters; scrub with `tr -d '\000-\037'` before
  `jq`.

---

## 4. Grounding

Seven mechanisms; **only two need Data Cloud**:

1. Agentforce Data Library (Knowledge / Files / Web) — **Data Cloud**
2. Data Cloud Retriever (vector / keyword / hybrid) — **Data Cloud**
3. Prompt template merge fields (record + related list)
4. Prompt template data providers (Flow / Apex)
5. Apex `@InvocableMethod` agent action
6. Named Query action (SOQL exposed as REST)
7. Apex REST / `@AuraEnabled` actions

Recommended index config (from the official grounding guide): Hybrid Search,
**Section Aware Chunking**, **Max Tokens 1,200**, Overlap 0, Title Prepending on,
**Salesforce Embedding V2 Small**.

File limits: text/HTML **4 MB**, PDF **100 MB**. **PDFs with embedded content are
unsupported and images are never chunked** — scanned PDFs and tables-as-images are
invisible to retrieval.

Data Library pipeline: `DATA_STREAM → DATA_LAKE_OBJECT → DATA_MODEL_OBJECT →
SEARCH_INDEX → RETRIEVER`. **The agent silently returns nothing until Search Index
Status = `Ready`** — the most common "my agent doesn't answer" cause.

Data Libraries are **not source-tracked metadata** — CLI-only (`sf agent adl *`). Real
CI/CD gap.

### Citations — three tiers

1. Platform-generated (enable on retriever / `knowledge` block)
2. `AiCopilot.GenAiCitationInput` — supply sources, let the reasoner place them
3. `AiCopilot.GenAiCitationOutput` — force exact citations regardless of reasoning

⚠️ **Hard gate: platform citations only work for agents created after 2025-05-26.**
(New agent here, so fine.)

⚠️ **Winter '26:** links not on the Trusted URL list are replaced with `URL_Redacted`.

### Anti-hallucination levers that actually exist

- Narrow subagent scope; **max ~15 actions per subagent**; the 360Learning production
  experience says **3–4 instructions per topic** before reliability degrades.
- Action `description` strings are load-bearing — the reasoner selects actions by
  description, so a vague one is itself a hallucination vector. Same for
  `@InvocableVariable` descriptions.
- Handle the empty-result case **inside the action output**, not in a top-level
  instruction.
- Agent Script supports `if/else`, typed mutable variables and deterministic branches —
  route must-be-exact answers through code, not generation.
- ⚠️ **There is no exposed confidence score, no similarity threshold, and no
  "refuse below X" knob.** Confirmed gap.

---

## 5. Trust, guardrails, EU AI Act

### Einstein Trust Layer

Automatic: secure data retrieval, prompt defense (injection resistance), zero data
retention, toxicity scoring (8 categories, 0–1, persisted even when nothing is blocked).
Configurable: data masking (Name, Email, Phone, Credit Card, US SSN on by default;
Company Name off).

⚠️ **Two independent sources say masking is currently DISABLED for Agentforce
use cases** (rationale: it "hinders contextual accuracy" for planner/action workflows).
Verify in-org before making any masking claim.

⚠️ Masking is validation-dependent — a malformed SSN or invalid card number passes
through unmasked.

### ForcedLeak (CVSS 9.4) — the counter-evidence

Web-to-Lead Description accepts 42,000 characters from an unauthenticated submitter →
employee asks the agent about the lead → agent executes the injected instructions →
exfiltrates via crafted image requests. An allowlisted CSP domain had **expired and was
purchasable for $5**. Reported 2025-07-28, fixed 2025-09-08 via Trusted URL enforcement,
disclosed 2025-09-25. **The fix was allowlist hygiene, not injection immunity.**

### EU AI Act — corrected timeline

The **AI Omnibus entered into force 27 July 2026** and delayed only the high-risk tiers.

| Obligation | Date | Status |
|---|---|---|
| Prohibited practices + **Art. 4 AI literacy** | 2 Feb 2025 | in force |
| GPAI, governance, penalties | 2 Aug 2025 | in force |
| **General applicability + Art. 50 transparency** | **2 Aug 2026** | **in force** |
| Annex III high-risk | **2 Dec 2027** (was 2 Aug 2026) | pending |
| Annex I product-embedded high-risk | **2 Aug 2028** (was 2 Aug 2027) | pending |

⚠️ `artificialintelligenceact.eu`, the most-cited tracker, **has not been updated since
Aug 2024** and still shows the original timeline.

**Classification for this agent:** minimal / limited risk. Partner scoring is **not**
Annex III(5)(b) — that covers creditworthiness of **natural persons**, and a GmbH is a
legal entity. Nuance worth raising: a German **Einzelunternehmer or GbR partner IS a
natural person**, so scoring could drift into scope for that segment. Art. 6(3)
derogation exists but **profiling is always high-risk regardless**.

Deployer (Art. 26), not provider. **Art. 25(1)** would flip you to provider if you brand
the agent as a product sold to resellers, substantially modify it, or repurpose it (e.g.
to rank employees).

Logging: **Art. 26(6)** requires deployer logs "for at least six months".
Penalties: Art. 5 → €35m / 7%; **Art. 26 + Art. 50 → €15m / 3%**.

There is **no AI-disclosure toggle in Agentforce**. The deployable lever is the first
message: `BotVersion.entryDialog` → `BotDialog` → `BotStep(type=Message)` →
`BotMessage.message`, e.g. *"Sie chatten mit einem KI-Assistenten."*

**The trap:** the Trust Layer does **not** satisfy Art. 50. Trust Layer governs data
handling; Art. 50 governs what the user is told. Orthogonal.

**The German bridge worth leading with in interview:** **BetrVG §87(1)(6)** — works
council co-determination for technical systems capable of monitoring employee behaviour.
An AI agent in a CRM plainly qualifies, and **AI Act Art. 26(7)** reinforces it. A
Betriebsvereinbarung plus a DSGVO Art. 35 DPIA is standard German practice.

### Observability (all require Data Cloud)

- `ssot__TelemetryTraceSpan__dlm` — SOQL-queryable spans; `ssot__OperationName__c`,
  `ssot__StatusCode__c` (`OK`/`ERROR`), `ssot__DurationNumber__c`. Span names seen:
  `run.interaction`, `run.llmstep`, `run.action`, `run.invokeActions.FLOW`.
  Also `ssot__AiAgentSession__dlm`, `ssot__AiAgentInteraction__dlm`,
  `ssot__AiAgentInteractionStep__dlm`. Enable: Setup → Agent Platform Tracing.
- Trust Layer audit: `GenAIGatewayRequest__dlm`, `GenAIGatewayResponse__dlm`,
  `GenAIGeneration__dlm`, `GenAIContentQuality__dlm` (`isToxicityDetected__c`),
  `GenAIContentCategory__dlm` (`category__c`, `value__c` 0–1),
  `GenAIFeedback__dlm` (thumbs up/down). Queried via Data Cloud SQL. ⚠️ Retention
  unverified — a widely repeated "30 days" has no primary source.
- The **Tooling API exposes only design-time objects** — the runtime surface lives in
  Data Cloud DMOs. Easy to miss.

Agentforce compliance credentials, all Agentforce-specific and dated:
**C5 (BSI) attestation** for "Einstein Platform & Agentforce" 2026-07-28 ·
**EU Cloud Code of Conduct — Agentforce** 2026-03-26 (`2026LVL02SCOPE5431`) ·
**ISO/IEC 42001:2023** 2025-09-30 → 2028-09-29.
⚠️ **TISAX does NOT cover Agentforce or Data Cloud** — do not overstate given the
automotive angle.

---

## 6. Market gap — measured, not guessed

GitHub code-search census (floors, not a full census — GitHub's index is partial):

| Artifact | Files | Repos |
|---|---|---|
| `genAiFunction` | 634 | many |
| `genAiPlugin` | 330 | ~80 |
| `aiAuthoringBundles/*.agent` | 523 | **22**, Salesforce-dominated |
| **`AiEvaluationDefinition`** | **24** | **15** — nine of them by Salesforce employees |
| **`aiRetriever`** | **0** | **0** |
| **SBQQ + Agentforce** | **0** | **0** |
| **"AI Act" + Agentforce** | **0** | **0** |
| `mcpServerDefinitions` | 6 | **2** |
| Agentforce as MCP **client** | — | **0** |

Only **5 repos on Earth** run `sf agent test run` in CI. Two are conference demos by the
same author, one committed `node_modules`, one is broken.

**Salesforce's own flagship sample `trailheadapps/coral-cloud` ships two
`aiEvaluationDefinitions` and never runs them** — `sf agent test` appears nowhere in
either CI workflow. `agent-script-recipes` has `bin/validate-agent-scripts.sh` and it is
wired into no workflow.

Salesforce's own Help Agent scored **80–90% in testing and 50–60% live**.

### The gap, stated plainly

A public repo that **(a)** authors an agent as `.agent` source rather than retrieving it,
**(b)** backs it with tested `@InvocableMethod` Apex under Selector/Helper separation,
**(c)** commits an `AiEvaluationDefinition` / test spec, and **(d)** runs
`sf agent test run` in GitHub Actions — **does not exist**, outside
`Think2Corp/AgentforceCICD` (★4, a joke agent, no Apex).

All four are already VoltStream's existing engineering discipline. They have simply not
been carried into Agentforce.

### Also worth knowing

- **Zero public German-language Agentforce demos.** German is **Beta** for Agentforce
  Service Agent — QA is yours. ~50% token-cost premium on non-English. Topic
  classification measurably degrades (documented example: Italian "modifica" misrouting
  as "modify car"). Unsupported languages **fall back silently** rather than erroring.
  You cannot define language-specific policies in prompt templates.
- **Headless Agent API is NOT a gap** — 65+ repos, including Cognizant, Accenture and
  AWS Labs. Gotcha if used: it does not work with agent type "Agentforce (Default)"; you
  need a custom agent and an External Client App with `sfap_api` + `chatbot_api` scopes.
- The user's own [`aksumustafa1625/agent-blast-radius`](https://github.com/aksumustafa1625/agent-blast-radius)
  already ships 4 `aiAuthoringBundles`, 35 `genAiPlannerBundles` paths, 7 bots and
  5 `genAiPlugins` with a `blast-radius.yml` CI — top decile by agent-metadata volume.
  It does **static** access-surface analysis (the "Escalation Gap"); it has **no**
  `aiEvaluationDefinition` and no runtime eval. The two halves are complementary.

---

## 7. German market reality

### ⚠️ There are no Salesforce roles in EV charging

Direct searches for Salesforce platform roles at VW, Porsche, Bosch, EnBW, **E.ON**,
Elli, Ionity, ChargePoint DE, and for `Salesforce Ladeinfrastruktur OR Elektromobilität`,
returned **zero**.

What *is* demanded — **diconium Group** (Stuttgart, VW Group majority-owned), Senior
Salesforce Architect, verbatim nice-to-have:

> *"4+ years of **automotive sales & marketing project experience (OEM, dealer networks)**"*

**Reframe the channel model as OEM / dealer-network partner management.** Keep EV
charging as the product domain — it is visual and credible — but the framing that
matches demand is dealer-network channel management, not "EV charging operator CRM".

Also hiring in adjacent space: DEKRA, AutoScout24, GEMMACON, Scheidt & Bachmann,
Vaillant, Fluence (a *Salesforce AI Use Case Developer* role), Advantest, Voith, Vodafone.

### Agentforce demand: ~4–5% of postings, concentrated at consultancies

- **Capgemini Sogeti**: *"KI-gestützter Automatisierung, **Agentforce** und intelligenter Assistenzlösungen"*
- **mindsquare AG**: names **"Salesforce Agentforce Specialist"** as a desired certification
- **OMMAX**: job title *"(Senior) Salesforce Solution Architect – **Data 360** / Agentforce"*
- **Voith Group**: *"Data Cloud, Agentforce, Marketing Cloud … integration with ERP"*

**Prompt Builder and Einstein Copilot appear in zero postings.**
**Platform Developer II appears in zero postings** — what is asked for is the
**Architect** track (diconium: *"Mindestens 4 relevante Salesforce-Zertifizierungen im
Bereich Application Architect und/oder System Architect"*, CTA path a plus).

**DevOps is cheap differentiation** — only diconium named any tool
(*"Git/GitHub/**Copado**"*). Gearset, DevOps Center and SFDX: zero hits. No posting named
a test-coverage percentage.

### German language is the real gate

Cremanski (**C1**, and *"| Deutschsprachig"* in the job title) · diconium (**C1+**) ·
Vodafone (*"fließend"*) · nexum (**C1**) · Salesfive · Teleperformance (**C1**).
Split is by role type — client-facing consultancy requires German; in-house
product/AI roles often accept English.

### Compliance is interview ammunition, not a headline

TISAX + Salesforce: **zero postings**. `Salesforce Datenschutz Betriebsrat`: *"Es wurden
keine Jobs gefunden"*. EU AI Act + Salesforce: **zero**. Build the depth so you can talk
about it; do not make it the project's front page.

### CPQ vs Revenue Cloud

Salesforce CPQ hit **end of sale 27 March 2025**; EOL projected ~2029–30. Greenfield
German demand is **Revenue Cloud Advanced** — e.g. Cremanski's *Senior Revenue Cloud
Consultant* asks for *"4+ Jahre Erfahrung mit Salesforce CPQ, Billing oder Revenue Cloud
Advanced"* and explicitly includes migrating CPQ onto the RCA data model.

**Frame the CPQ work as "CPQ data model, with a migration path to Revenue Cloud
Advanced" — never as greenfield CPQ.**

Note also: the CPQ API is **Apex-only** (no REST, no SOAP), so no standard Agentforce
action can reach CPQ — custom `@InvocableMethod` from day one. The one public
production write-up (360Learning) reported >50% failure from *"Unable to lock rows"* via
Flow, configuration attributes silently not applying, and the CPQ API being unable to set
quote line quantity. They moved from Flow to Apex.

### Salary markers

mindsquare Technical Architect **€65,000–100,000**. Indeed "Salesforce Entwickler"
average **€74,114** (range €56,320–97,528, 32 reports, 14 Aug 2026); Köln €83,424,
Frankfurt €82,462; Accenture €115,000. gehalt.de "Salesforce Consultant" median
**€71,315**, 9+ years **€80,614**. ⚠️ No freelance day rates retrieved.

---

## 8. EV charging domain — verified German data

Bundesnetzagentur, 1 July 2026: **155,264 Normalladepunkte + 54,341 Schnellladepunkte
= 209,605 total, 9.04 GW**.

### Real list prices (German B2B shops, Aug 2026)

| Product | Power | Price |
|---|---|---|
| Easee Charge Max, Typ 2, MID | 22 kW | €699.95 brutto |
| **Alfen Eve Single Pro-line**, Typ 2, MID | 22 kW | **€710 netto** / €844.90 brutto |
| Easee Charge Max, **Eichrecht** | 22 kW | **€999.95** |
| Easee Charge Pro, Eichrecht | 22 kW | €1,298.94 |
| Alfen Eve Single Plus, Typ 2 cable, MID | 22 kW | €1,249.50 |
| **Compleo DUO SAM**, Eichrecht | 2× 22 kW | **€5,309 netto** / €6,317.71 brutto |
| Alfen Eve Double PG-Line DE, Eichrecht | 2× 22 kW | €5,938.10 |
| Compleo DUO fleet SAM, coiled cable | 2× 22 kW | €7,210.21 |
| eCharge cPP2 4T44 (4 points) | 22 kW | €11,899.95 |
| Compleo DUO ims, Eichrecht, DPZ | 2× 22 kW | €11,945.22 |
| Technagon TEP4 HAK, Eichrecht | 2× 22 kW | €12,558.07 |
| ⚠️ Compleo CITO 500 2in1 PT SAM | 50 kW DC + 22 kW AC | €25,999 netto *(single source)* |
| **Alpitronic HYC200**, Eichrecht, barrierefrei | 200 kW | **from €67,814.32** |
| Alpitronic HYC400 (≤4 points, ISO 15118 Plug&Charge) | ≤400 kW | Preis auf Anfrage |

Accessories / services / subscriptions:

| Item | Price |
|---|---|
| RFID card (own brand) | €3.95 |
| Typ 2 cable 11 kW (HARTING) | €159.95 |
| Kortmann concrete foundation (Alfen) | €214.20 |
| Compleo DUO SMC base + granulate | €327.25 |
| MENNEKES Standsäule (V2A) | €599.95 |
| MENNEKES Fertigfundament | €712.81 |
| KEBA KeContact R10 cable management | €999.95 |
| Alpitronic HYC50 foundation | €1,010.31 |
| Alpitronic HYC150–400 foundation | €1,248.31 |
| **Alfen "Smart Charging Network" licence** | €119 perpetual |
| **LADE Portal backend** | **€5.00 / charge point / month** |
| ↳ AI energy assistant "Lana" | +€5.00/CP/month |
| ↳ Credit-card payment / eRoaming / hotel PMS | €0.03/kWh + €199 setup each |
| Compliance-tracking SaaS (LadeCheck) | €29 / €79 / €199 per month |
| **Installation — low / medium / high** | **€500–800 / €800–1,500 / €1,500–3,000+** |
| Grid reinforcement (22 kW cases) | ~€500 |

Structural validation: **Elli (VW Group Charging)** sells exactly this shape to business
customers — Flexpole fast chargers, commercial wallboxes, location analysis, planning +
installation, hardware migration, maintenance, Site Management Console, fleet software.

### Regulation — corrected facts

| Item | Correct value |
|---|---|
| **NAV §19(2) approval threshold** | **12 kVA** summed per installation — *not* 11 kW, and not per device |
| **§14a EnWG threshold** | Statute has **no kW figure**. 4.2 kW comes from **BNetzA Festlegung BK6-22-300** (in force 1 Jan 2024; DSO may dim but never below 4.2 kW) |
| **Eichfrist** | **8 years for both AC and DC** (Staatsbetrieb für Mess- und Eichwesen Sachsen). Ends early on repair/modification |
| **MessEG §32 six-week Anzeigepflicht** | **Repealed 1 Jan 2025** (Viertes Bürokratieentlastungsgesetz). Most sources still cite it — do not model it |
| **Wallboxes in Marktstammdatenregister** | **Not required.** Official MaStR FAQ. Only if PV/storage is in scope |
| **Eichrecht scope** | Only *im geschäftlichen Verkehr*; billing must be **per kWh**; DE-M marking; fines to €50,000 (MessEG §60). Duty falls on the **Betreiber, not the installer** |
| **KfW 440 / 441 / 442** | **All closed.** Open: federal multi-unit-residential programme since 15 Apr 2026 (≤€2,000/space, closes 10 Nov 2026); NRW ≤€50,000 for ≥10 spaces; e-truck ≤€500/kW |
| **GEIG** | Non-residential new build >6 spaces → conduit every 3rd + ≥1 point (§7); renovation >10 → every 5th + ≥1 (§9); **existing non-residential >20 spaces → ≥1 point by 1 Jan 2025** (§10) |
| **AFIR (EU) 2023/1804** | Applies from 13 Apr 2024. TEN-T core by 31 Dec 2025: pools every 60 km, ≥400 kW with ≥1 point ≥150 kW; by 31 Dec 2027: ≥600 kW with ≥2 points ≥150 kW. ⚠️ The commonly cited ≥50 kW card-reader threshold and 1 Jan 2027 retrofit date are **unverified** |
| **THG-Quote** | Only *publicly accessible* points; certified with the Umweltbundesamt; **volume-based per kWh**. Since 2026 the **EVSE-ID is mandatory** in the filing and only one provider per point |
| **OCPP** | 1.6J still widely deployed; **2.0.1** (IEC 63584) replacing it; 2.1 (2025) adds ISO 15118-20 bidirectional/V2X. **1.6 and 2.0.1 are not compatible.** OCPI 2.3.0 current; 2.1.1 no longer supported |

### Partner onboarding — the corrected model

**"Elektrofachbetrieb" has no statutory definition. Do not use it as a field.** The
correct term is **`eingetragenes Installationsunternehmen`**.

**NAV §13(2):** work behind the house fuse may only be done by a company entered in a
DSO's **Installateurverzeichnis**. Details from the BDEW/ZVEH *Grundsätze* (Jan 2024):

- Registration is **company-level and held by ONE DSO** (§2.1.3, home Niederlassung).
  **§2.2.6: one entry suffices nationwide** → model as one registration + home-DSO
  lookup, *not* N:N per grid operator.
- Qualification attaches to a named **Verantwortliche Elektrofachkraft (VEFK)** per
  DIN VDE 1000-10, permanently employed (§2.2.2).
- **§2.2.5:** when the last VEFK leaves the entry *ruht* and is deleted if unreplaced
  within **3 months** → status field + countdown.
- **§5.1: max 5 years** (not 3), **no automatic renewal**. **§5.2: notify the firm
  3 months before expiry** — the renewal-reminder pattern, straight from the source.
- **§5.3:** renewal needs **two** Fortbildungsmaßnahmen with Fortbildungsnachweis.
- **§2.3.1:** deletion from the Handwerksrolle triggers deletion here.

Qualification is a **branch, not a stack**: either the **Sicherheitsschein** (from the
Meisterprüfung) **or** the **TREI Sachkundenachweis**. Requiring both is a common
modelling error.

**AVV (DSGVO Art. 28) is usually the WRONG instrument.** In a supplier→reseller
relationship the reseller is normally an *eigenständiger Verantwortlicher*; signing an
AVV misdescribes the relationship and implies a non-existent Weisungsrecht. The EDPB's
travel-agency example (Guidelines 07/2020, Rn. 68) is nearly this fact pattern.

Model it as a picklist instead:
`Datenschutz-Rolle:` Eigenständig Verantwortlicher / Gemeinsam Verantwortlicher (Art. 26)
/ Auftragsverarbeiter (Art. 28) — driving which document type is required.

**Freistellungsbescheinigung nach §48b EStG — the highest-value document, and it was
missing from the original plan.** Without it the *Leistungsempfänger* must withhold
**15% Bauabzugsteuer** (§48 EStG). Wallbox and PV installation are *Bauleistungen*
(*"Herstellung, Instandsetzung, Instandhaltung, Änderung oder Beseitigung von
Bauwerken"*). Bagatellgrenze: none below **€5,000/year**. Validity in practice **1–3
years**. The supplier must verify currency via the BZSt online check. Expired = the
supplier owes the 15%. **Real expiry + real money = the flagship renewal-reminder use
case.**

Recommended checklist typing:

- **Type A — legal prerequisite, blocks partner activation:** Handwerksrolle
  (conditional; Elektrotechniker is Anlage A Nr. 25, Meisterpflicht; exceptions §7(2),
  §7b Altgesellenregelung, §§3/5 Hilfsbetriebe) → **Installateurverzeichnis** (the gate)
  → named VEFK + Sicherheitsschein *or* TREI → Gewerbeanmeldung (§14 GewO, **no expiry**)
  → BG membership (§192 SGB VII, notify within 1 week)
- **Type B — blocks invoicing, not activation:** Freistellungsbescheinigung §48b EStG
- **Type C — due diligence, warn only:** Handelsregisterauszug (**conditional** — GbR and
  Kleingewerbe have none; HRA = e.K./OHG/KG, HRB = GmbH/UG/AG; **free since 1 Aug 2022**)
  · Betriebshaftpflicht (**not legally required**; market convention €3m min / €5m
  recommended; add a separate *Tätigkeits-/Bearbeitungsschäden* checkbox — often excluded
  and it is the cover that actually pays) · Unbedenklichkeitsbescheinigungen (~3-month
  currency, commercial custom not statute) · GZR-Auszug §149 GewO (covers legal entities;
  a Führungszeugnis does not and is the wrong tool for B2B vetting)
- **Type D — per-deal, belongs on Opportunity/Installation not Reseller:** NAV §19
  notification (always) · NAV §19 Zustimmung (>12 kVA) · §14a EnWG (>4.2 kW) · MaStR
  (only if PV/storage) · Eichrecht (only if billing third parties)

**VDE-AR-N 4100/4105 and DIN VDE 0100-600/0105-100 are standards, not certificates a
company holds.** Model a *Fortbildungsnachweis* field, not a "VDE certificate" field.

---

## 9. CPQ catalog design

⚠️ Field API names below are from model knowledge — Salesforce docs returned 403/404
during research. **Verify against the 260.2 org before building.**

```
VS-CHARGE-BUNDLE   (SBQQ__ConfigurationType__c = 'Allowed',
                    SBQQ__ConfigurationEvent__c = 'Always',
                    SBQQ__OptionSelectionMethod__c = 'Click')
├── Feature "Ladehardware"      Min 1 Max 1   <- drives everything
├── Feature "Montage & Sockel"  Min 0 Max 2
├── Feature "Installation"      Min 1 Max 1   <- Gering / Mittel / Hoch
├── Feature "Backend-Abo"       Min 1 Max 1   <- subscription, MRR
├── Feature "Zubehör"           Min 0 Max 10
└── Feature "Service & Wartung" Min 0 Max 1   <- SLA tier, subscription
```

Configuration attributes (`SBQQ__ConfigurationAttribute__c`, "Apply Immediately"):

| Attribute | Values | Drives |
|---|---|---|
| Ladeart | AC / DC | filters hardware options |
| Abrechnung erforderlich? | Nein / MID / **Eichrecht** | forces conforming SKUs + billing module |
| Öffentlich zugänglich? | Ja / Nein | AFIR payment terminal, BNetzA registration, unlocks THG-Quote |
| Anzahl Ladepunkte | 1–100 | subscription quantity + load management |
| Summen-Bemessungsleistung (kVA) | number | **>12 → NAV §19 Zustimmung** |
| Netzbetreiber | lookup | Installateurverzeichnis validation |
| Montageart | Wand / Standfuß | shows/hides Sockel feature |

**Product rules encoding real German regulation — this is the differentiator:**

| Type | Condition | Message |
|---|---|---|
| Validation | Öffentlich = Ja AND hardware not Eichrecht-conform | *"Öffentlich zugängliche Ladepunkte müssen eichrechtskonform sein (MessEG/MessEV)."* |
| Validation | Öffentlich = Ja AND no payment terminal AND DC ≥50 kW | *"AFIR verlangt Kartenzahlung an öffentlichen Schnellladepunkten."* |
| Alert | Summen-Bemessungsleistung > 12 | *"Zustimmung des Netzbetreibers nach NAV §19 Abs. 2 erforderlich — Bearbeitungsfrist bis zu 2 Monate."* |
| Alert | Ladeleistung > 4.2 kW | *"Steuerbare Verbrauchseinrichtung nach §14a EnWG — Steuerbox einplanen."* |
| Selection | Ladeart = DC | auto-add DC foundation + cable management |
| Selection | Abrechnung = Eichrecht | auto-add backend billing module |
| **Validation** | **Reseller lacks a valid Installateurverzeichnis entry** | *"Partner ist nicht im Installateurverzeichnis eingetragen (NAV §13) — Installation kann nicht beauftragt werden."* |

That last rule wires CPQ directly into the existing `Reseller__c` model from Phase 1.

Discount schedule (`SBQQ__DiscountSchedule__c` + `SBQQ__DiscountTier__c`,
`SBQQ__AggregationScope__c = 'Group'`): Bronze 1–9 = 0% · Silber 10–24 = 8% ·
Gold 25–99 = 15% · Platin 100+ = 22%. Use `Slab` vs `Range` deliberately.

Block pricing for installation (non-linear): 1–5 points €800 · 6–20 €2,400 ·
21–50 €7,500.

Subscriptions: `SBQQ__SubscriptionPricing__c = 'Fixed Price'`,
`SBQQ__SubscriptionTerm__c = 12`, `SBQQ__SubscriptionType__c = 'Renewable'`,
`SBQQ__BillingFrequency__c = 'Monthly'`. Backend €5.00/CP/month (`Per Unit`, quantity
from the Anzahl-Ladepunkte attribute); SLA tiers €29 / €79 / €199 per month, or
`Percent Of Total` at ~8% of hardware.

Price rules for what discounts cannot express: Eichrecht surcharge, remote-region
installation uplift, and partner-tier `SBQQ__AdditionalDiscount__c` sourced from
`Reseller__c.Tier__c`.

---

---

## 11. E.ON — company study

Completed 2026-08-22 for the business/product/partner half. The Salesforce-and-pain-points
half was still running when research was closed; re-run it before relying on any claim
about whether E.ON uses Salesforce.

`eon.com` and `eon.de` sit behind Cloudflare/Akamai and return 403 to plain fetching — the
researcher got through with a full browser header set and parsed E.ON's AEM `eon-ui-*`
component attributes, where the specs and prices actually live.

### Group structure

Three reporting segments (FY2025): Energy Networks (adj. EBITDA €7.7bn), Energy Retail
(€1.7bn), Energy Infrastructure Solutions (~€590m).

**EV charging sits in Energy Retail, not in Energy Infrastructure Solutions.** EIS is
district heating, industrial decarbonisation, data-centre energy and battery storage.

| Entity | Role |
|---|---|
| **E.ON Drive Germany GmbH** (München) | Contracting entity for *all* German e-mobility offers. The B2B / behind-the-meter business. |
| **E.ON Drive Infrastructure GmbH (EDRI)** (Essen, HRB 29338) | The public-network CPO. Owned by E.ON SE + E.ON Solutions GmbH. |
| Westenergie, Avacon, Bayernwerk, E.DIS, Hansewerk, Lechwerke, Süwag | The DSOs (Energy Networks). They do **not** sell charging hardware. |
| **E.ON One** | Digitalisation subsidiary bundling **gridX** (XENON platform, gridBox) and **envelio**. |

The E.ON Drive Germany / EDRI split — behind-the-meter B2B versus public CPO — is the
cleanest structural fact in the group and worth mirroring.

### The finding that matters most

**E.ON has no public, named, certified installer partner programme for EV charging.** For
e-mobility E.ON writes in the first person — *"unsere qualifizierten Installateure kümmern
sich um die komplette Installation und Inbetriebnahme"* — i.e. installers are
subcontractors delivering an E.ON-branded turnkey service, not a branded partner tier.

The tiered, certified partner motion exists **only for E.ON Home** (HEMS / PV / heat pump),
launched 2026-02-24:

| Tier | Points | Cashback | Benefits |
|---|---|---|---|
| **Partner** | 0–29 | to €580 | after-sales support, training, Partner-Portal, guided first install |
| **Fach Partner** | 30–249 | to €4,980 | + Partner-Tag, marketing material, **named E.ON contact** |
| **Gold Partner** | 250+ | over €5,000 | + employee incentives, co-branded flyers, **Tiny House showroom**, events |

Points economics: 1 point per installed E.ON Home Box (**€20**), 5 points per concluded
**E.ON Home Comfort** service contract (**€100**), capped at **€120 per customer**, settled
annually. The arithmetic is internally consistent (29 × €20 = €580, 249 × €20 = €4,980).

Onboarding is a five-step channel-partner lifecycle: talks and demo → **Rahmenvertrag and
Partner-ID issued** → Welcome Package with a free Home Box → training plus a live
first-installation appointment → independent installations. Leads are distributed from
E.ON's public **Wärmepumpen-Finder** to regional installers. Viessmann Climate Solutions
partners joined on the same rate card from May 2026, driven by **§14a EnWG** and **§9 EEG**
remote-control obligations.

**This is the template, and the gap is that E.ON has not applied it to EV charging.** A
channel CRM that runs an E.ON-Home-style tiered, points-based partner programme *for the
charging channel* — carrying the compliance gates the heat-pump programme does not
(Installateurverzeichnis, §48b Freistellungsbescheinigung) — is a proposal about their
business, not a generic demo.

Three other partner channels exist and none is a certification programme: **Vertriebspartner**
(self-employed agents under §84 HGB, commission-based), **Handwerkskammer Rahmenverträge**
(Bavaria and Hesse, TAN-gated member purchasing), and **EDRI Standortpartner** — a
capex-free site-host model where EDRI finances, installs and operates HPC and the landowner
takes a revenue share.

### E.ON Drive Booster — the grid-bottleneck product

Battery-buffered plug-and-play DC charger, originally a VW co-development (Sept 2021):

- **2× CCS, up to 150 kW each, 250 kW max total**
- **193.5 kWh battery on Volkswagen's MEB platform**; second-life EV cells planned
- **No civil works and no dedicated grid connection** — runs off a plain **16, 32 or 64 A
  CEE socket**, or on battery alone where no socket exists
- **4 m² footprint** (2×2 m); load-bearing ground is enough; relocatable
- 43-inch advertising screen + 10-inch touch panel; connected to E.ON Drive Backend
- Vertical landing pages for Tankstellen/Raststätten, Logistik-Ladeparks, Stadtwerke/Kommunen
- **Price not published.** Purchase, **Mietkauf** or leasing via a partner leasing company,
  offered from roughly 10 AC charge points incl. installation, or 1 DC station

It exists because grid connection is the bottleneck. That is the single best argument for
why a *Netzanschluss* workflow belongs in the CRM.

### Real E.ON published prices (net, B2B)

| Product | Rating | Price |
|---|---|---|
| Alfen Eve Single Pro-line | 3.7–22 kW, 1 CP | **ab €1,090.76** |
| Alfen Eve Double Pro-line | 3.7–22 kW, 2 CP | **ab €2,799.00** |
| Compleo eBox Professional | 3.7–22 kW | auf Anfrage |
| Alpitronic Hypercharger **50** | 50 kW, 2× CCS uncooled | **ab €19,990** |
| Alpitronic Hypercharger **75 / 150** | 75 / 150 kW | auf Anfrage |
| Alpitronic Hypercharger **200** | 200 kW, 2× CCS 400 A | **ab €53,990** |
| Alpitronic Hypercharger **400** | 400 kW | **ab €79,990** |

All Eichrecht-compliant. Card terminal optional on 50/150/200, **included** on 400, **not
available** on 75. Kempower covers depot/fleet/truck: 4–6 buses or trucks from 2–6
satellites + 1–3 power units; a modular variant reaches **600 kW across 6–8 charge points**.

### Betriebsführungspakete — the commercial hinge

Three operations tiers, and the revenue split is the whole design:

| | Connect | Flex | Comfort |
|---|---|---|---|
| Maintenance & inspection | — | ✓ | ✓ |
| Billing of sessions | — | ✓ | ✓ |
| Electricity supplier | free choice | free choice | **E.ON supplies Ökostrom** |
| **Revenue share to customer** | — | **90%** | **10%** |
| Static load management | orderable | ✓ | ✓ |

Flex = the customer keeps the revenue. Comfort = E.ON supplies the power and keeps it. That
is a clean CPQ modelling case: one attribute flips both the price model and the
revenue-share direction.

### ElectricFleet — three modules

**Charge@Home** (employee owns the hardware, so no asset or liability sits with the
employer; company-branded webshop; binding installation packages from an online
configurator; freely chosen **Arbeitgeber-Zuzahlung**; E.ON handles legally compliant
**Rückvergütung** of home electricity costs), **Charge@Work** (AC and DC, 11–300 kW),
**Charge@Public** (230,000 public points across 7 countries).

### Public charging tariffs

E.ON Drive Business, incl. VAT, €0.00 monthly base fee: own network **€0.54/kWh AC**,
**€0.61/kWh DC**; roaming Germany and Europe **€0.59 AC / €0.79 DC**, with blocking fees
after 180 min (AC) and 45 min (DC).

EDRI ad-hoc: AC <45 kW **from €0.58/kWh**; FC <100 kW and HPC 100–400 kW **from €0.69/kWh**.
**Plug & Charge via ISO 15118 on all Alpitronic DC chargers**; Autocharge explicitly not
supported. EDRI runs **9,000+ public points across 11 European markets**, and its truck/MCS
network is live in DE, SE and DK at **400 kW**, fleet price **€0.399/kWh excl. VAT**, with a
**TruckReservation** slot-booking platform.

⚠️ E.ON's own pages quote **four mutually inconsistent roaming-reach figures** (230,000 CPs
/ 8 countries, 13 countries, "bald 200.000", 850,000 CPs / 14 countries). Different page
vintages. Treat none as canonical.

### Technology partners

**Virta** (Finland) supplies the cloud backend for E.ON Drive's **Dynamic Charge**,
announced **2026-02-03** — it shifts sessions into cheap spot-price windows using parking
duration, energy demand and location, claims up to **25% lower charging costs**, and works
independently of the energy supplier. Hardware OEMs: **Alfen, Compleo, Alpitronic,
Kempower** (the consumer shop adds Easee, go-e, KEBA, MENNEKES, Phoenix Contact, ABL). E.ON
runs its own **Drive TestingLab**, used consistently as a differentiator.

### Could not verify

Drive Booster price · Hypercharger 75/150 prices · Compleo eBox price · consumer "Light"
and "More" tariff prices · Betriebsführungspaket and Montagepaket prices · EDRI's 11th
country · EDRI's German charge-point count · the exact legal-entity ownership chain
(northdata paywall) · the E.ON Home Partner-Portal URL · whether the Home partner programme
continues past end-2026.

### E.ON and Salesforce — the earlier "zero roles" finding is REFUTED

The German market scan concluded there were no Salesforce roles at any charging or
utility company, E.ON included. That was wrong, and the reason is worth recording:
**E.ON runs two career portals.** `jobs.eon.com` is a JavaScript SPA whose search results
never render. The real, machine-readable board is **`careers.eon.com`** (SAP
SuccessFactors), with entity path segments `/deutschland/`, `/EONGrid/`, `/westnetz/`,
`/hansewerk/`, `/e-dis/`.

`careers.eon.com/search/?q=Salesforce` returned **4 of 428 open jobs** on 2026-08-22:

| Title | Location | Entity | Posted |
|---|---|---|---|
| **Senior Salesforce System Engineer (m/w/d)** — Job-ID 244556 | München / Essen | E.ON Energie Deutschland GmbH | 12 Aug 2026 |
| **Salesforce System Engineer – AI based (m/w/d)** — Job-ID 245393 | München / Essen | E.ON Energie Deutschland GmbH | 13 Aug 2026 |
| Campaign Data & Automation Manager (m/w/d) | München | E.ON Energie Deutschland GmbH | 17 Aug 2026 |
| Senior Campaign Manager (m/ž) | České Budějovice | E.ON | 30 Jul 2026 |

From Job-ID 244556 (contact `samy.el-bouz@eon.com`):

> *"Unsere Abteilung CRM treibt die kontinuierliche Weiterentwicklung unserer
> Implementierung von **Salesforce als zentralem CRM System** voran"*
> *"Die End-to-End Weiterentwicklung unserer **Salesforce Energy & Utilities Cloud**
> liegt in Deiner Hand"*
> *"Routiniert bewegst Du Dich in **Apex, Lightning Web Components, SOQL und Salesforce
> APIs** und setzt Tools wie GitLab, Salesforce CLI, VS Code sowie Jira und Confluence
> sicher ein"*

Read the "AI based" variant carefully: its AI scope is **AI-assisted software
development**, not agentic CRM — *"AI gestützte Softwarentwicklung anwenden und ins Team
skalieren"*. It also names **MuleSoft** as the integration platform (separately staffed:
`?q=MuleSoft` → 3 hits including a Lead MuleSoft System Engineer).

**`?q=Agentforce` returns 0 results. There is no Agentforce anywhere at E.ON.**

### Systems by division — it is four CRMs, not one

| Division | Customer-facing system |
|---|---|
| **E.ON Energie Deutschland GmbH** (München, retail sales, ~2,200 staff) | **Salesforce Energy & Utilities Cloud** + Marketing Cloud + MuleSoft + Snowflake + COMET/Datacloud |
| **E.ON Grid Solutions GmbH** (Essen) | **Microsoft Dynamics 365 CE** + Azure + Power Platform, serving the *Meter-to-Cash-Geschäft* for DSOs |
| **Westnetz** (DSO) | **SAP S/4 Utilities**, SAP MCM, IM4G — including *Verarbeitung der Netzanschlussprozesse* |
| **E.ON Next** (UK) | **Kraken** (Octopus Energy Group) |
| **E.ON Drive Germany / Drive Austria** (e-mobility) | generic *"CRM-Systeme"* — **platform never named in any posting** |

SAP is the group backbone: `?q=SAP` → **76 of 428** open roles. E.ON's IT arm is
**E.ON Digital Technology GmbH**.

### The bottlenecks, with numbers

**Netzanschluss is the binding constraint.** § 19 Abs. 2 NAV makes charging equipment
notifiable and requires the operator's *Zustimmung* above **12 kVA Summen-Bemessungsleistung**,
with a duty to answer *"innerhalb von zwei Monaten"*. HPC goes to medium voltage under
**VDE-AR-N 4110**, chaining Netzanschlussbegehren → Netzverträglichkeitsprüfung →
Anlagenzertifikat → Konformitätserklärung → Inbetriebsetzung.

Reality, per dena (July 2025): *"vom ersten Planungsschritt bis zur Inbetriebnahme eines
Ladepunktes **zwei bis drei Jahre** vergehen können, in Einzelfällen **bis zu 10 Jahre**"* —
first VNB response up to 1 year, connection availability up to 2.5 years, transformers up
to 12 months. Prof. Markus Lienkamp: *"**Der Netzanschluss ist heute der längste Pfad der
Elektrifizierung**"*.

**The root cause is administrative, not physical.** Agora Verkehrswende names *"händische
Bearbeitung von Anfragen bei Netzbetreibern"*, missing grid-utilisation data, and
*"umfangreiche Abstimmungen zwischen Netzbetreibern und CPO"*. **Germany has 860+ DSOs,
each with its own TAB.** BDEW issued a **Musterwortlaut TAB Mittelspannung** in February
2026 proposing a mandatory **10-working-day** response, and **Masterplan Ladeinfrastruktur
2030 Maßnahme 22** requires that *"Netzanschlussbegehren in der Mittelspannung sollen
künftig digital gestellt werden können"* with online status tracking. Building to that
target is forward-looking, not speculative.

Grid connection is **20–25% of HPC capex**. Baukostenzuschüsse under § 11 NAV apply above
30 kW; a 70×150 kW truck depot needs 5 MW (BKZ ~€425k), a motorway MCS site 28 MW
(BKZ ~€1.8m).

**§ 14a EnWG — confirmed, and it does NOT cover public charging.** The statute contains no
numeric threshold; the 4.2 kW comes from **BNetzA Festlegung BK6-22-300** (decided
27.11.2023, applying 01.01.2024). BNetzA states plainly: *"**Öffentlich zugängliche
Ladepunkte** i. S. d. § 2 Nr. 5 Ladesäulenverordnung **sind nicht von den Regelungen**
erfasst"*. The quid pro quo for dimming is an **Anschlusspflicht** — operators may no
longer refuse or delay connection citing congestion. Where it bites is **non-public depot
charging**. ⚠️ BK6-22-300's decision text could not be retrieved; the tenor wording comes
from BNetzA's explainer.

**Standortakquise.** ~40% private / 60% public land (Bundeskartellamt, Oct 2024).
Concessions run 5–10 years. **§ 7c EnWG bars DSOs from operating charging** — which is
exactly why E.ON's grid arm and its CPO arm must be separate entities. Vergaberecht is the
schedule-killer: **Munich's 2,700-charger procurement was ordered restarted in Nov 2023**
for tendering the wrong instrument; the replacement launched Jan 2025, ~5 years from start
to first spade. NRW gives *"mindestens 12 Monate"* concept-to-tender, with **8–12 distinct
counterparties per site** of whom only the landowner is a customer. Useful CRM geography:
**94% of CPOs consider competitors only within 5 km, 88% within 1 km.**

**Eichrecht is a per-device, per-Land evidence problem.** Eichfrist is **8 years from
Inverkehrbringen, not installation** — a charger warehoused two years arrives with two
years burned — running to calendar-year end. Nacheichung must be applied for **≥10 weeks
before expiry** (§ 38). A **firmware update is prima facie an Eingriff under § 37 Abs. 2
Nr. 2** requiring separate approval, and the Eichfrist is unaffected by it. Enforcement is
**Länder** competence with independent queues, and § 55 lets one authority ban a device
*model* — making a single SKU defect a fleet-wide revenue event. Fines to €50,000.

**THG-Quote — the 2026 EVSE-ID change is confirmed at primary source** (UBA Bekanntmachung,
10 June 2026, BAnz AT 30.06.2026 B9): *"für jeden Ladepunkt zwingend die gesamte Electric
Vehicle Supply Equipment ID (EVSEID) anzugeben"*. Deadline **28 February** of the following
year, an Ausschlussfrist. **§ 8 Abs. 5: incomplete filings are rejected, not queried.** From
17.04.2026 filing is chargeable at **€94.60–€6,500**, and the fee *"hängt maßgeblich von der
Qualität der im Antrag übermittelten Daten und Nachweise ab"* — data hygiene now has a
quotable price.

**The sharpest single fact in the whole study:** § 6 Abs. 4 of the 38. BImSchV requires the
operator to declare to the UBA that for every charge point in the filing *"die Messgeräte …
geeicht sind und **die Eichfrist nach § 37 MessEG nicht abgelaufen ist**"*. **An expired
Eichfrist on one charger converts a metrology lapse into a false declaration to a federal
authority.**

**Funding is now reverse auctions.** KfW 440/441/442 all closed. Open: Mehrparteienhäuser
(€500m, closes 10.11.2026) and e-Lkw (€1bn/4yrs, PtJ). All three e-Lkw calls were heavily
oversubscribed — **Aufruf B was ranked purely by €/kW and the cut fell at ~230 €/kW**;
Aufruf C was ~6× oversubscribed. A technically flawless bid at 300 €/kW simply loses. The
classic disqualifier is **vorzeitiger Maßnahmenbeginn**: any binding contract before the
Zuwendungsbescheid voids the grant, and *grid-connection contracts are the classic
accidental trigger, since utilities want them signed early.*

### E.ON's own charging position

**EDRI** — CEO **Timo Sillober** since 16.10.2025 (ex-EnBW), **8,000+ points in 10+
countries**. Deutschlandnetz: **3 Regionallose = 139 sites** plus 30+ Autobahn sites →
**170+ sites / 1,350+ fast points**, second-largest regional operator. Lkw-Deutschlandnetz
(July 2026): Los 5 with mblty (Tank & Rast) — 24 sites, 195 points, 101 MCS-capable.

Site acquisition is the core growth motion and it is landowner-partnership-shaped:
Unibail-Rodamco-Westfield (308 DC points), Retail Match/ILG (350 points at Netto/Aldi
Süd/OBI/Toom), MediaMarktSaturn (80 stores, ~300 HPC), **BImA — 7,000 Ladepunkte on federal
property by Q2 2027**, MAN (170 sites / ~400 truck points). Vendor stack: **Ampeco** CPMS
across 11 countries, Alpitronic, Siemens, Alfen, **Virta** (equity stake 2018, *not* a JV),
**gridX** (80%).

Market frame: **204,078 public points / 8.9 GW (July 2026)**, >80% operated by BDEW-member
utilities, and **only 12% average simultaneous occupancy** — the constraint is not charger
count, it is which sites and when they energise.

### The gap, stated precisely

**No system of record spans a charging site's lifecycle, and the compliance clocks that
hang off it live nowhere.** Four facts define it:

1. **E.ON runs Salesforce E&U Cloud as central CRM — but only in retail energy sales.**
   The CPO business never names a platform. Its **Werkstudent Netzanschlussanfragen**
   posting does the work by hand — *"die Einholung und Aufbereitung aller relevanten
   Informationen"*, *"Die technischen Antragsunterlagen fertigst du sorgfältig an"* — with
   **no system named**. The *Planer für Ladeinfrastruktur* works in **AutoCAD, Alpi Caneco,
   GIS and Office**. This is a student-and-CAD process sitting adjacent to, not inside, the
   Salesforce org.
2. **Salesforce's own E&U data model does not cover it.** E&U Customer 360 has Account,
   Billing Account, Contract, Energy Service Agreement, Location, Product, Service Point —
   and nothing for a grid-connection request, a charge point as a regulated metering asset,
   a site-acquisition pipeline, an Eichfrist, or a THG filing. Not a configuration E.ON
   skipped; it does not ship.
3. **E.ON sits on both sides of the queue and cannot see across it.** Largest DSO group
   (Westnetz, HanseWerk, E.DIS, Avacon, Bayernwerk) *and* a top-two CPO — but **§ 7c EnWG**
   forbids the DSO from operating charging, and the two sides run different stacks.
4. **They are automating the adjacent problem on the wrong platform.** The **Werkstudent
   Partner Business Development, KI & Sales Operations** posting (Job-ID 245933) — in
   **E.ON Energie Deutschland GmbH, the same entity that runs Salesforce** — reads: *"Du
   gestaltest aktiv den Aufbau und die Weiterentwicklung unseres
   **Installateur-Partnernetzwerks**"* and *"Du identifizierst innovative KI-Technologien und
   setzt **Research-Agenten, Automatisierungen sowie digitale Workflows** gezielt ein"* —
   with tools listed as **Power BI, Power Apps, Microsoft Copilot**.

   A channel-partner network with AI agents is being built on Power Platform, inside the
   division whose central CRM is Salesforce. **That is exactly what VoltStream is**, and it
   is a directly demonstrable "you already own the better platform for this" argument.

### The agents that follow from this

Not a chatbot — agents that act on deadlines:

- **Netzanschluss agent** — resolve the responsible VNB out of 860+, retrieve *that*
  operator's TAB, assemble the Netzanschlussbegehren pack, run the **§ 19 Abs. 2 NAV
  two-month clock** with escalation.
- **Compliance-clock agent** — per-device Eichfrist from Inverkehrbringen, raising
  Nacheichung applications at the **10-week** boundary against the correct Land authority,
  flagging every firmware push as a § 37 Abs. 2 Nr. 2 Eingriff.
- **THG filing agent** — validate EVSEID completeness *before* submission, enforce the
  one-claimant rule, and **block the § 6 Abs. 4 declaration if any charge point in the
  filing has a lapsed Eichfrist**.
- **Förderung agent** — compute €/kW bid position against known clearing levels, track
  De-minimis headroom across linked undertakings, and **flag when the Netzanschluss team is
  about to sign a Baukostenzuschuss that would trigger *vorzeitiger Maßnahmenbeginn* and
  void the grant.** A genuine cross-team conflict only a shared CRM record can catch.

### Could not verify (Part A/B/C)

E.ON GPT's content and model partner (eon.com unfetchable) · any Salesforce case study or
press release naming E.ON · tender documents (TED needs POST) · LinkedIn skill data ·
whether E.ON's Salesforce org serves B2C only or also B2B/e-mobility — **no posting states
the segment** · which platform E.ON Drive's "CRM-Systeme" are · BK6-22-300's decision text ·
the 0.45 Gleichzeitigkeitsfaktor / 1.89 kW depot figures (single trade source) · KfW 440's
closure on a live KfW page · THG-Quote prices from any authoritative source.

**Two claims to NOT repeat:** there is no evidence EDRI is a JV and no Copenhagen
Infrastructure Partners stake; and there is no direct E.ON–Vinci partnership (the only link
is Voltix as an HDV-E consortium member).

## 10. Open decisions

1. **Project shape** — does VoltStream stay a hardware supplier, or become a charging
   network operator? Research suggests a third option: keep the supplier model but
   reframe the channel as **OEM / dealer-network partner management**, which is the
   phrasing that demonstrably appears in German job postings.
2. **Demo data** — delete the stock `United Oil` / `Grand Hotels` / GenWatt dataset
   (44 opportunities, 20 Closed Won) and rebuild a coherent German world, or layer on
   top of it?
3. **E.ON** — the company study did not complete. Whether E.ON runs Salesforce at all is
   unresolved, and the German market scan found **zero** Salesforce platform roles at any
   charging or utility company including E.ON. Re-run before committing to an E.ON-shaped
   narrative.

**Nothing in the org has been changed.** No data deleted, Agentforce not enabled.
