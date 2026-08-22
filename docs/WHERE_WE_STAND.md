# VoltStream Agentforce — Where We Stand, and What We Could Not Do

**Second submission for critique.** 2026-08-22
**Author:** Mustafa Aksu, with Claude Opus 4.7
**Audience:** the eight reviewers who read `AGENT_DESIGN_FOR_REVIEW.md`, in the same threads.

---

## 0. Read this first

You reviewed a design document. I built a decision ledger from your eight reviews, then went
and **measured** the things all of us were guessing about, then went and **read the statutes**
instead of trusting summaries.

A lot changed. Some of your recommendations turned out to be impossible. Some of my
"verified" claims turned out to be wrong. Two of my proudest ideas turned out to be
structurally incapable of showing anything. And the platform said no to several things in
ways that no documentation predicts.

**This document is not asking you to review a design again. It is asking you to look at a
list of walls and tell me which ones are not really walls.**

That is the specific ask. Section 3 is the heart of this document: **everything we concluded
we cannot do.** Some of those conclusions are certainly correct. Some are probably me
lacking imagination, or lacking a technique you know. Historically, when I have brought you
a "this is impossible," several of you have handed back a way around it — and the way around
was better than the original plan.

**I want this project to be something a Salesforce engineer has not seen.** Not
"well-executed." Not "thorough." Something where the reaction is *"I did not know you could
do that."* Tell me where that is still available, and tell me where I am polishing something
that will never produce that reaction.

At the end there is one more question, and it is the one I care about most:
**what would make this dramatically stronger that is not on any of these lists?**

---

# PART 1 — The story so far

## 1.1 What the project is

**VoltStream Mobility** is a fictional German B2B EV-charging supplier. It sells charging
hardware through a **channel** — electrical contractors, energy utilities, automotive dealer
groups, facility managers — who install and operate it for end customers.

The Salesforce org is real (Developer Edition, `VoltStreamDev`). Phase 1 and Phase 2 are built
and deployed: a `Reseller__c` object with a four-layer Apex trigger family, `ResellerSelector`,
`StringUtils`, `TestDataFactory`, and a `documentManager` LWC with a `Document__c` object,
Chatter integration and inline-SVG folder icons. 108 tests green, 100% coverage on custom code.

**Phase 3 is the Agentforce agent.** That is what you reviewed and what this document is about.

The portfolio target is **senior Salesforce roles in the German e-mobility market**. The
project has to survive being read by someone who knows both Salesforce and German energy law.

## 1.2 The problem the agent solves

A German charging project sits under **at least five independent legal regimes**, each with
its own clock, its own authority, and its own consequence for missing it:

| Regime | Authority | What it costs to miss |
|---|---|---|
| **Eichrecht** (metrology) | Landeseichbehörde | The charge point may not legally bill per kWh |
| **Netzanschluss** (grid connection) | Netzbetreiber (DSO) | The installation may not be commissioned |
| **§ 14a EnWG** (controllable loads) | Netzbetreiber / BNetzA | Wrong tariff, wrong hardware ordered |
| **THG-Quote** (emissions credit) | Umweltbundesamt | An entire year of revenue, unrecoverable |
| **Partner compliance** (Installateurverzeichnis, § 48b EStG, VEFK) | DSO / Finanzamt / employer | Installation ban, or 15% withholding on every invoice |

These regimes **do not know about each other**. Nobody in the org holds all five. The
information lives in five different places and the deadlines interact — a fact that is benign
under one regime can be disqualifying under another.

**The thesis:** an agent that holds all five simultaneously catches, in one turn, what a human
catches in three weeks of cross-departmental email — or does not catch at all.

## 1.3 What has happened since your reviews

In order:

1. **`DECISION_LOG.md`** — every proposal from all eight of you, with a status. 168 accepted,
   29 rejected, 18 conflicts between reviewers, all resolved. ~1,000 lines.
2. **`PHASE0_VERIFICATION.md`** — I stopped guessing and ran a throwaway agent through the
   full lifecycle in this org, five times, recording everything.
3. **`DOMAIN_VERIFICATION.md`** — I stopped trusting summaries and read the statutes. Two
   rounds. Nine open questions closed, four claims corrected, one finding nobody was
   looking for.
4. **Three decisions** that only I could make: project identity, a personal claim in the
   document, and AI attribution.

Sections 2, 3 and 4 below are the results.

---

# PART 2 — What was decided

## 2.1 The identity decision — engine first, agent as interface

Four of you arrived at the same place from four different directions:

> **R4:** *"Your design is a beautiful regulation engine wrapped in a fragile Agentforce
> deployment. Lead with the engine — if the agent wrapper collapses, you still have the engine."*

**Decision: the README leads with the rules engine. Agentforce is presented as its interface.**

**Nothing is cut.** Both get built in full. What changed is the order and the shop window.

Two things made this decision, and one of them is new:

- The risk argument that originally motivated it **no longer applies.** Phase 0 measured the
  agent working in this edition. Tests run. Credits do not run out. So this is not
  risk-avoidance.
- The domain work opened a fifth route to the same conclusion. **The strongest thing we
  found is an engine insight, not an agent insight** — see §4.3. An agent does not discover
  that a checkbox has five consequences in two directions. It makes it *askable*.

The corollary, which matters for how you should read the rest of this document: **per-record
legal status is a formula field, visible in a list view without running anything.**
Cross-record aggregation is Apex. That split is a direct answer to R4's observation that a
hiring manager spends three minutes and will not run your CI.

## 2.2 The agent shape — decomposed by verb, not by regime

My original design had **five subagents, one per legal regime.** R8 killed it (§3.15) and
proposed the axis that replaced it:

> *"The planner discriminates on **what the user wants done**, not on **which law applies.**"*

| Subagent | Actions | Note |
|---|---|---|
| **`Briefing`** | `StandortBriefing` | **One composite read action.** Runs every check deterministically and returns a *sectioned* result — each section with its own `status` / `rechtsgrundlage` / `konsequenz`. |
| **`Fristen`** | `NaechsteFristen(regime?, tage)` | All clocks in all regimes, one service. **Regime is a parameter, not a subagent.** |
| **`Pruefung`** | `PruefeAntragsart`, `PruefeTHGAbgabe`, `PruefeVorzeitigenBeginn` | Cited binary decisions |
| **`Aktion`** | `ErstelleAufgabe`, `EntwerfeEskalation` | Every write behind `require_user_confirmation` |

Three to four subagents, **≤3 actions each**, and **every action description starts with a
different verb** — because overlapping verbs are what actually makes routing tests flap.

The deeper point, which I did not see until R8 said it:

> *"Most of your regime-specific instructions become unnecessary. If Apex already returns
> `konsequenz = 'Rechnungssperre (15 % Bauabzugsteuer)'`, the model does not need an
> instruction telling it to distinguish an installation ban from an invoice block — **it needs
> to render the field.** Less instruction, more structured output."*

## 2.3 The gate design — two tiers, and why

From R7's self-refutation (§3.16) and my own five-run variance measurement (§3.2):

| Claim | Where it is tested | Gate |
|---|---|---|
| **The decision** — *"an expired Eichfrist means BLOCKIERT with a § 6 Abs. 4 citation"* | **Apex unit test** — deterministic, instant, free, ~40 boundary cases | **100%, zero tolerance** |
| **The routing** — *"does this utterance reach that action?"* | `actions_assertion` — the single probabilistic hop | ≤2/40 |
| **LLM-judged quality** | reported as a score against a measured baseline | **never gated** |

The interview sentence this produces:

> *"The agent cannot get the compliance decision wrong, because the agent does not make the
> compliance decision. It selects which deterministic check runs. So I test the selection
> probabilistically and the correctness deterministically, and I gate them differently."*

## 2.4 The grounding decision — citation by key, not by similarity

R8's best single idea across all eight reviews:

> *"Do not retrieve the law by vector similarity and hope the right passage comes back. Put
> the statute text in **Custom Metadata**, keyed by paragraph, generated from the official XML,
> and have Apex return the citation **by key** alongside the decision. Then the citation is
> **as deterministic as the decision** — and testable."*

**Decision: `Rechtsnorm__mdt`, generated from gesetze-im-internet's XML, cited by key.**
Data Library is deferred to v1.1 and only for a handful of DSO technical connection documents,
where similarity search is actually the right tool.

## 2.5 The current build order

| Day | Work |
|---|---|
| 1 | ✅ **Done.** Phase 0 probes, five runs, variance measured |
| 1 | ✅ **Done.** Domain verification, two rounds, against primary sources |
| 2 | Objects + `DateUtils` (table-driven tests) + selectors |
| 3 | `EichrechtService` + `THGService` + entity resolution · invocables · `with sharing` |
| 4 | The LWC compliance dashboard — the engine, visible without running anything |
| 5–6 | The agent: 3–4 subagents, `Rechtsnorm__mdt` grounding, permission set |
| 7 | ~23 eval cases incl. a mutation case · CI green · `sf agent preview` transcript committed |

---

# PART 3 — ⛔ THE WALL

## **Everything we concluded we cannot do**

**This is the section I want you to attack.**

Every item below is something I currently believe is impossible, blocked, or structurally
incapable of delivering what I wanted from it. Each one is marked with how confident I am
and how I know.

**If any of these is not actually a wall, that is worth more to me than a new feature idea.**

---

## 3A · Platform walls — measured in this org, not read in a doc

### 3.1 ⛔ Agent Script cannot be published in this edition

`AiAuthoringBundle` — the new `.agent` DSL — **authors and validates but does not publish.**

```
$ sf agent generate agent-spec          → 9 s, success
$ sf agent generate authoring-bundle    → 1 s, success
$ sf agent validate authoring-bundle    → {"success": true}
$ sf agent publish authoring-bundle
  → "We couldn't find the default agent user NEW AGENT USER."      (semantic, server-side)
$ # after setting default_agent_user to a real username
$ sf agent publish authoring-bundle
  → ERROR_HTTP_404
```

The first error proves the command **reaches Salesforce and is validated server-side.** The
404 arrives only at the **commit** step. A sibling project recorded the identical wall in a
different org, so this is a **reproducible edition boundary**, not a local misconfiguration.

**Current workaround:** the `.agent` file is design source, committed. The deployed agent
comes from the classic `Bot` / `BotVersion` / `GenAiPlannerBundle` path.

**Confidence it is a real wall: high.** Reproduced in two orgs.
**What I would love to be wrong about:** whether some org setting, permission, or
`--api-version` flag flips it. Or whether there is a documented Agent Script publish path that
does not go through `sf agent publish`.

### 3.2 ⛔ `topic_assertion` is unusable for custom topics — the value comes back mangled

```
Case 1  expectedValue  "p_16jgL000002KylF_Eichfrist_Monitoring"
        actualValue    "p"                     ← truncated at the first underscore
        result         FAILURE
Case 2  expectedValue  "Off_Topic"
        actualValue    "Off_Topic"             ← intact, underscore and all
        result         PASS
```

The agent **routed correctly.** `generatedData.topic` also reads `"p"`. A **standard** topic
name survives intact; an **org-prefixed custom** one is reported as a single character.

I ran this **five times.** 5/5 identical. This is a **defect, not a flake.**

**Consequence:** any CI gate built on `topic_assertion` is permanently red for reasons that
have nothing to do with the agent. Route assertions must go through `actions_assertion`,
which returns its value intact.

**Confidence: high** for the observation. **Low** for the cause — I do not know whether the
truncation happens at display time or at evaluation time. The value is wrong in *both*
`generatedData.topic` and `actualValue`, which suggests evaluation time.

**What I want:** is there a naming scheme, an escape, or a metadata setting that avoids the
underscore-truncation? Is this known? Should I be filing it?

### 3.3 ⛔ The built-in quality metrics score a *correct guardrail* as a failure

Case 2 asked the agent for a pancake recipe. The agent **correctly declined** and offered
support topics instead. `coherence` scored it **0 / FAILURE**:

> *"The answer is completely incoherent and does not address the request for a pancake recipe.
> It seems to be a generic customer support response, which is unrelated to the task."*

The judge penalised a **working guardrail** because it refused.

Worse, `output_validation` on the same case returned `score: 1` with `result: FAILURE` —
**the score and the verdict disagree with each other.**

**Consequence:** `coherence` / `completeness` / `conciseness` must be excluded from any suite
containing refusal cases — which is every suite worth having, since refusal is the behaviour
I most want to guarantee.

**Confidence: high.** Reproduced 5/5.
**What I want:** is there a way to give these judges the guardrail context so they grade the
refusal as correct? A reference answer? A rubric parameter? If not, this is a genuine and
publishable finding about the platform — but I would rather have the capability.

### 3.4 ⛔ The standard Knowledge action steals the turn and cannot be out-competed

Case 1 expected `AdminCopilot__SetupGeneralKnowledgeGrounding`. What actually fired:

```json
"invokedActions": [[{"function":{"name":"EmployeeCopilot__AnswerQuestionsWithKnowledge"}}]]
```

The standard Knowledge action **won action selection on all five runs**, then could not
answer, so the agent apologised and referred the user to support.

**Consequence:** standard actions must be **removed** from a topic, not out-competed with a
better custom description. My original design assumed description quality would win selection.
It does not.

**Confidence: high.** 5/5, and independently recorded by a sibling project.

### 3.5 ⛔ `AiAgentScorerDefinition` is missing from the CLI's metadata registry

```
$ sf project deploy start --metadata "AiAgentScorerDefinition:VS_Scorer_Echo_Probe"
Error (RegistryError): Missing metadata type definition in registry for id
'AiAgentScorerDefinition'.
```

The **server** knows the type — `sf org list metadata -m AiAgentScorerDefinition` returns
"no metadata found", not `INVALID_TYPE`. The **CLI** does not.

**Workaround found:** deploy through the metadata-format path (`--metadata-dir` with a
hand-written `package.xml`), which bypasses the source registry and reaches the server's own
parser. That works.

**Confidence: high**, and I have a workaround. Including it because it may indicate the whole
scorer surface is not source-deployable yet — see the next item.

### 3.6 ⛔⛔ A scorer-typed prompt template **cannot be created through the Metadata API here** — server-side crash

This is the one that hurt most, because it blocks the artifact I most wanted.

I walked the schema by reading the server's rejections. Each failure named the next constraint:

| Attempt | Server response |
|---|---|
| `<masterLabel>` present | `Element masterLabel invalid at this location` |
| `dataType Number` + `isFallback` | `The Number data type doesn't support fallback values.` |
| Flex-typed prompt template | **`Allowed types: agentforce_session_tracing__scorerMultilabel, scorerOpenEnded, scorerMeasurement. Found: 'einstein_gpt__flex'.`** |
| `scorerMeasurement` with no inputs | **`Required Prompt Template Input definitions are missing: [[AllowedRange, Session]]`** |

**Those last two answered R8's "real load-bearing unknown" (§3.17): the scorer is handed a
`Session`, not a bare utterance-and-response pair.** So a groundedness scorer is
*architecturally* possible — the material is in scope.

Then every candidate `<definition>` for the `Session` input was rejected, and the final
rejection was not a validation message but an **unhandled server-side null**:

```
Failure to create template: Cannot invoke
"einstein.gpt.shared.provider.definition.GenAiPromptTypeEnum.getPath()"
because the return value of
"einstein.gpt.shared.provider.definition.GenAiPromptDefType.getType()" is null
```

A plain Flex template deploys cleanly. A `agentforce_session_tracing__scorerMeasurement`
template **crashes the platform** rather than naming the valid input definitions.

**Consequence, stated bluntly because it should not be glossed:** the custom scorer would have
to be built **in Agentforce Studio's UI** and only *retrieved* into git. For a repository
whose whole claim is "authored as source, deployable from source," that is a real weakening —
of exactly one artifact, but a headline one.

**And it means I still do not know which fields of that `Session` are dereferenceable.**
Whether action outputs and retrieved chunks are reachable is *undetermined*, which means
*"I can prove the agent did not make it up"* is currently **unsupported**.

**Confidence it is a wall: medium-high.** It is a server crash, not a documented limit.
**This is the single item where I most want you to tell me I am wrong.** Is there a known
`<definition>` value for a scorer `Session` input? Has anyone deployed
`agentforce_session_tracing__*` from source? Is there a different route — Tooling API,
Connect API, `sf agent` subcommand — that creates it?

### 3.7 ⚠️ `GenAiPromptTemplate` versioning requires two deploys, always

Version identifiers must be **omitted** on first create. Setting `1` or a UUID is rejected:

```
The prompt template version identifier is "1" invalid.
The prompt template version identifier is "fd7b6a32-...-e6f966f111b1" invalid.
```

The platform mints a base64 digest plus an ordinal: `KzZqWgd5jMzXkpnhkT4MIUQfuFYllHgFALWfY/Vih28=_1`

To activate a template you deploy it, retrieve it, read that value, and redeploy with
`<activeVersionIdentifier>` set. **Two deploys, every time.** Awkward in CI but not a wall.

### 3.8 ⛔ `multiSubagentOrchestration` does not exist — one turn routes to one subagent

The reasoning engine routes a turn to **one** subagent and can chain actions **within** it.
Orchestrating five subagents from a single utterance is a capability Salesforce has **parked
in `future_recipes/`**.

**This killed my hero demo.** See §3.15.

**Confidence: high** — it is Salesforce's own repository structure saying so.
**What I want:** has anyone made a composite orchestration work by other means — a planner
instruction, an action that itself calls other actions, an Apex fan-out? My current answer is
"one composite Apex action," which works but is arguably not agentic.

### 3.9 ⛔ The Digital Wallet is not available in Developer Edition

Credit balance cannot be read, so per-run credit consumption **cannot be measured** in this org.

**However** — and this matters, because a sibling project built an entire mock-first
architecture around fearing this — **no credit failure has ever occurred.** Across two
projects, several months, a full day of live agent conversation, and everything in Phase 0:
zero quota errors. **Credits are therefore not treated as a design constraint.**

**What I want:** is there any way to read consumption in DE? A Setup page, an object, an API?
Publishing a real per-run credit cost would be genuinely novel — R8 pointed out that nobody
has published this arithmetic.

### 3.10 ⚠️ `AgentforceDataLibrary` has no metadata type — CLI-only

It cannot be deployed as source. Combined with 3.6, two of the most interesting artifacts in
the design resist a source-first repository.

---

## 3B · Design capabilities that turned out to be impossible

### 3.11 ⛔ Formula fields cannot aggregate "ANY child record"

R6 found this and it was a genuine design error:

> *"`formula: false if ANY related Ladepunkt has expired Eichfrist` is not an ordinary
> cross-object formula capability. A formula field cannot arbitrarily aggregate over child
> records. Your design treats relational aggregation as something Formula can do directly."*

Two designed fields died:
- `THG_Meldung__c.Eichfrist_Erklaerung_moeglich__c`
- `Foerderantrag__c.Vorzeitiger_Massnahmenbeginn_Risiko__c`

Roll-up summary works only on **master-detail** and only **COUNT/SUM/MIN/MAX** — and
`THG_Meldung__c ↔ Ladepunkt__c` is a **junction**, so roll-up does not reach it either.

**Both became Apex service methods.**

**Partial escape I have since designed:** put a **formula checkbox on the child** that
references only its own fields (e.g. `Eingriff__c.Sperrt_Betrieb__c = Typ__c = 'Software-Update'
&& ISBLANK(Behoerdliche_Freigabe_am__c)`), then a **roll-up COUNT with that as criteria** on
the parent. That recovers a lot of it declaratively.

**What I want:** is that pattern sound? Are there limits on roll-up criteria referencing
formula fields that I will hit? Is DLRS worth it here, or is Apex cleaner for a portfolio piece?

### 3.12 ⛔ The Eichfrist formula cannot express the law

`Eichfrist_Ende__c = DATE(YEAR(Inverkehrbringen__c) + 8, 12, 31)` was in the design.

It is wrong twice over:
- It cannot express **§ 37 Abs. 2 Nr. 2** — an intervention that can affect metrological
  properties **ends the period early**, and that fact lives on child records.
- It cannot express **§ 34 Abs. 1 MessEV** — after a re-calibration the period restarts from
  the **day of that calibration**, not from Inverkehrbringen. See §4.2.

**Current answer:** a roll-up of the latest qualifying `Eingriff__c` plus a formula. It works,
but it took the child-formula-checkbox trick to get there.

### 3.13 ⛔ Custom Metadata records cannot be inserted with ordinary DML

R7's second self-correction. CMDT records go through `Metadata.Operations.enqueueDeployment`,
which is **asynchronous** — so a seed script **cannot write an anchor and read it back in the
same transaction.**

**Consequence:** my deterministic time anchor for tests had to become a **List Custom Setting.**

**Confidence: high.** Documented behaviour.
**Relevant to the reviewers because:** `Rechtsnorm__mdt` (§2.4) *is* Custom Metadata. It is
fine — it is deployed, not seeded at runtime — but it means the statute corpus is a build-time
artifact, and regenerating it is a deploy, not a script.

### 3.14 ⛔ `String.escapeHtml4()` corrupts German text

R4 recommended running all string fields through `String.escapeSingleQuotes()` **and**
`String.escapeHtml4()`.

Both are the wrong tool. `escapeSingleQuotes()` is for **SOQL injection**, not JSON. And
`escapeHtml4()` turns `ü` into `&uuml;` — **it destroys the output** in a German-language
agent.

The **risk** R4 identified is real (a malformed JSON payload → a silent planner failure).
The fix is not. Apex `@InvocableVariable` serialisation already escapes correctly. I will
verify with a test case returning German text containing quotes, backslashes and umlauts.

---

## 3C · Capabilities that were structurally incapable of delivering what I wanted

**These are the painful ones. They were not blocked by the platform. They were blocked by
my own design, and I did not notice.**

### 3.15 ⛔⛔ The hero demo could not happen — and my own evidence said so

My §12 was the centrepiece: a single German utterance — *"Was steht dem im Weg?"* — touching
Eichrecht, Netzanschluss, partner compliance, Förderung and CPQ.

> **R8:** *"That requires one utterance to reach **five subagents.** The reasoning engine
> routes a turn to **one**. Orchestrating five from a single utterance is exactly the
> `multiSubagentOrchestration` capability that **your own §16.20 notes Salesforce has parked
> in `future_recipes/`.**"*

**My own evidence base refuted my own hero demo, and seven reviewers did not catch it.**

And there was a second, subtler problem in the same place: **my action taxonomy overlapped
across subagents.** `ListeAblaufendeFristen`, `PruefeFristen`, `PruefeEichfristen` and
`BerechneNacheichungsfenster` all answer *"what is expiring?"*

> *"A user asking *'Was läuft in den nächsten 90 Tagen ab?'* has **three plausible homes.**
> Your `topic_sequence_match` tests will flap, and you will blame LLM non-determinism —
> **when it is your taxonomy.**"*

**Current answer:** one composite Apex action, `StandortBriefing`, that runs every check
deterministically and returns a sectioned result. The demo survives as a *single turn*.

**But I am not fully happy.** A composite Apex action that does everything is arguably not an
agent demo — it is an Apex demo with a chat box. **Is there a way to get genuine
multi-subagent behaviour that I am not seeing?** Chained actions within one subagent?
A planner instruction that forces a sequence? Something in Agent Script's `@utils.transition`?

### 3.16 ⛔ A statistical gate on repeated runs is arithmetically impossible

R7 recommended *"run safety-critical cases N=5, require 5/5."* On the second pass R7 **did the
arithmetic and refuted their own advice:**

| true *p* (per run) | one case clean (p⁵) | **eight cases clean** | red-build rate |
|---|---|---|---|
| 0.99 | 0.951 | **0.669** | **33%** |
| 0.98 | 0.904 | **0.450** | **55%** |
| 0.95 | 0.774 | **0.130** | **87%** |

> *"To keep red builds under 5% across eight cases you need **p ≈ 0.9987 per run.** **No LLM
> planner in a Beta language will give you that.** A gate that is red a third of the time is
> not a gate — you start ignoring it in week two, and an ignored gate is worse than no gate
> because it is not honest."*

**The right move is architectural, not statistical: take the safety property out of the LLM
entirely.** That produced the two-tier design in §2.3.

**My own measurement supports this.** Five runs of the same two-case suite:

- Deterministic assertions: **5/5 identical.** Routing and action selection never wobbled.
- LLM-judged: **one verdict flip in five** on the same utterance, same agent version, minutes
  apart. And all the movement clustered in **run 4** — so judge variance is **per-run, not
  per-case**, which means re-running a single failed case may not reproduce the condition.

### 3.17 ⛔⛔ My #1 "wow" was structurally always green

The metric eight reviewers ranked first was the **Escalation Gap** — showing what the agent
can see that the user cannot.

> **R8:** *"Strongest candidate — **but only if there is a gap to find.** In your design
> **every selector is `WITH USER_MODE`** and the agent runs as the user, so **the gap is
> structurally zero** and your headline metric is **a badge that is always green.**"*

**The thing all eight of you ranked #1 had nothing to show.**

**Current answer:** deliberately plant a `without sharing` action on a branch and show the
build **turn red.** *"The tool has to be shown catching something."*

**What I want:** is a planted violation convincing, or does it read as theatre? Is there a
naturally-occurring gap in a realistic channel-partner sharing model that would be more
honest? Community/Experience Cloud users? A partner who should see their own resellers'
records but not another partner's?

### 3.18 ⛔ `factuality` is anti-correlated with this project's thesis

Six reviewers said *"go straight to G2, `factuality` is there."* R8 showed why that is
**actively harmful here:**

> *"`factuality` is `needsExpected: false, LLM_0_100` — **your own catalogue says so.** A
> **zero-reference** factuality judge scores an answer against **its own priors.** In German
> metrology and energy law the judge's priors are **wrong in exactly the places you are proud
> of**: it 'knows' **11 kW**, not 12 kVA je elektrischer Anlage; it 'knows' the Eichfrist
> starts at **installation**; it 'knows' § 14a applies to **wallboxes generally**."*
>
> *"**The correct answer is penalised; the fluent, conventionally wrong one is rewarded.**"*

**And the domain work has now made this worse — or better, depending on how you look at it.**
Since your reviews I established that the **Ladesäulenverordnung was repealed on 1 January
2026** (§4.4). Any judge trained before then will "know" a repealed provision.

**Current answer:** run `factuality` **once, as an experiment I write up** — expect it to
punish correct answers. That finding is worth more than the metric.

**What I want:** is that framing strong, or is it excuse-making? Is there a way to give
`factuality` a reference so it becomes usable? And is *"I measured a platform metric being
anti-correlated with correctness in a regulated domain"* a genuinely interesting publication,
or does it read as blaming the tools?

---

## 3D · Things cut by decision — revisit any of these

These were not impossible. They were **cut**, mostly for scope. If any of you thinks a cut
was wrong, say so.

| Cut | Reason | Who pushed back |
|---|---|---|
| **All CPQ** | End-of-sale March 2025; no CPQ-enabled org available | R5 had put it at the centre |
| **MCP server** | Three reviewers called it a gimmick | R3 wanted it, tied to the target company |
| **MCP client** | R4's use case (German holiday API for the § 19 two-month clock) is **solved by the standard `BusinessHours` object** | R4 |
| **Agent-to-agent** | Scope | — |
| **Adversarial refutation loop** | Scope, and cost | — |
| **`werktageAddieren` holiday engine** | *"Best cut argument in the review"* — 16 Bundesländer, and the deadline is calendar months anyway | R7 argued for the cut |
| **`Foerderantrag__c`** | Deferred to v2 | — |
| **Data Library retriever** | Replaced by `Rechtsnorm__mdt` citation-by-key (§2.4) | Deferred, not killed |
| **Five subagents → 3–4** | §3.15 | R4 wanted five |
| **`Compliance_Frist__c` object** | Duplicated derived state; became a `FristenService` DTO | R2, R3, R4 wanted to keep it |
| **Explicit target-company framing** | Removed from code *and* README | R3 wanted it in the narrative |

The last one deserves a note, because R7 raised something none of you else saw: the most
insightful thing I could say about the target company's real operational situation is
**something you cannot say to them in an application.** It is accurate, it is the reason the
project is well-aimed, and writing it down would read as presumptuous. So the project has to
**demonstrate** the insight rather than state it.

---

## 3E · Still genuinely unknown

| Unknown | Why it is still unknown | Blocks |
|---|---|---|
| **What fields of the scorer's `Session` are dereferenceable** | Server NPE, §3.6 | The groundedness claim |
| **Whether `topic_assertion` truncation is display or evaluation-time** | Wrong in both fields, suggesting evaluation | A cleaner route assertion |
| **G2 `AiTestingDefinition` / `--test-runner agentforce-studio`** | Not attempted yet | `factuality`, multi-turn |
| **`isConfirmationRequired` under test** — auto-confirm, auto-decline, or stall? | Not attempted | Whether write actions can be tested at all in CI |
| **Data Library Max Tokens: 1,200 or 4,096?** | R4 says 4,096; my research found 1,200 from Salesforce's grounding guide with an embedding-sequence-length rationale | Only if Data Library returns |
| **Conversation-level testing (Beta): 20 turns, 3 concurrent suites, no custom scorers** | Discovered late, not tried | Multi-turn eval |
| **AGME decision GM-P 6.8** (12.11.2025, eight DC test points) — in force? | Changes cost, not logic | Nothing |
| **MID Annex Va transposition into German law** | Adopted at EU level, not transposed | Nothing yet — but would move several rules |

---

# PART 4 — What the domain work found

I stopped trusting summaries and read the statutes. Two rounds. **This is where the project's
actual differentiation now lives**, so it is worth your attention even though it is not
Salesforce.

## 4.1 Nine questions closed

| Question | Answer |
|---|---|
| Does the **Stichprobenverfahren** let a fleet extend calibration by sampling? | **No.** § 35 MessEV scopes it to electricity/gas/water/heat meters in a *Los*. Charge points are not in that list — and eight industry bodies **petitioned the ministry on 24 April 2026 to create it.** You do not ask for what you have. |
| Does a firmware push end the Eichfrist? | **Three paths, not one.** § 37 Abs. 2 Nr. 2 (intervention → ends early) · Abs. 5 (authorised repair → exempt) · **Abs. 6 (software update → period untouched, but the device may not legally operate until the authority approves).** |
| Is the § 38 ten-week rule a deadline? | **No, a grace period.** Three states: GESCHÜTZT / ERMESSEN / ABGELAUFEN. Missing it is not a breach — it forfeits automatic protection and leaves operation at the authority's discretion. *kann*, not *muss*. |
| Do AC and DC differ? | **No.** Both eight years. |
| Does § 14a exclude public charging? | **Yes — in the statute's own words:** *"nicht öffentlich-zugängliche Ladepunkte für Elektromobile."* And 4.2 kW appears **nowhere in the statute** — it is BK6-22-300 only, and it is a **dimming floor, not a shutdown.** |
| Does NAV § 19's two-month period ripen into approval? | **No. There is no Genehmigungsfiktion.** |
| When does the Eichfrist start? | **Two branches.** Inverkehrbringen for the first period; **Tag der Eichung** after a re-calibration. |
| Is a cable swap an intervention or a repair? | **Both, in effect.** Abs. 5 preserves the period — but only if all four conditions hold, and Nr. 2 requires applying for re-calibration *unverzüglich*. |
| Who must retrofit card readers under AFIR? | **Narrower than I had it.** Existing ≥50 kW points only **on the TEN-T network** or at secure truck parking, by 1 Jan 2027. Below 50 kW a **dynamic per-transaction QR code** suffices. |

## 4.2 The correction that matters most for the model

The Eichfrist has **two start branches**, so a single date field computes the wrong expiry for
every re-calibrated device — and re-calibration is not rare. The industry counts **more than
45,000 per year against an assumed 6,000**, driven by cable replacement, maintenance, and
**cable theft at up to 100 cases a day.**

**The Eichfrist is not an eight-year timer. It is a continuously firing event stream.** A model
that only counts to eight misses nine tenths of what happens.

## 4.3 The finding that redefined the demo

**The Ladesäulenverordnung § 4, last sentence:** the notification duties apply afresh when an
**existing charge point newly becomes publicly accessible.**

So `Oeffentlich_zugaenglich__c` is **not an attribute — it is a transition.** The moment it
flips:

- **LSV § 4** notification duty starts (two weeks)
- **Eichrecht** applies in full
- **AFIR** payment obligations attach
- **THG** revenue becomes claimable
- **§ 14a** *deactivates* — the tariff and the hardware assumption both change

**One checkbox. Five consequences. Two of them in opposite directions.**

And **§ 6** closes the loop: the regulator forwards registration data **monthly to the
metrology authorities.** Ticking that box is not a private act — it tells the Eichamt.

**This is the demo.** And note what it is: **an engine insight.** No agent discovers it. This
is what decided §2.1.

## 4.4 The finding nobody was looking for

**The Ladesäulenverordnung was replaced on 1 January 2026.** The 2016 text was repealed in
full. The new LSV has **six paragraphs and contains no payment rules** — Germany deleted its
national provisions because AFIR is directly applicable.

**Anyone citing "LSV § 4 requires card payment" is quoting a repealed provision** — which is
exactly what a model trained before 2026 will do, and what a demo built last year contains.

The definition also moved: *öffentlich zugänglicher Ladepunkt* is now **§ 2 Nr. 2**, and the
THG regulation was amended in the same instrument to follow it.

---

# PART 5 — Where the repository stands right now

```
docs/
  AGENT_DESIGN_FOR_REVIEW.md   1,600 lines — the doc you read, UNEDITED, with a
                                corrections banner and ⚠️C1…C13 markers at the
                                thirteen evidence tags that were later refuted
  DECISION_LOG.md              ~1,030 lines — all eight reviews, 18 conflicts resolved
  PHASE0_VERIFICATION.md       ~440 lines — measured platform behaviour, 5 runs
  DOMAIN_VERIFICATION.md       ~480 lines — statutes, quoted verbatim, two rounds
  platform-probes/variance-runs.jsonl   raw per-run data
force-app/  Reseller__c · Document__c · Opportunity fields · 108 tests green
scripts/apex/  German catalogue (57 SKUs) · 11 partners · pipeline seeds
```

**On the thirteen wrong `[V]` tags:** I did **not** delete them. That document is the artefact
you read; editing it retroactively would falsify the record that makes it worth keeping. The
claims stand verbatim, the tags are marked, and a table at the top says what is actually true.

Among them: I cited **Art. 26(6)/(7) of the AI Act** for logging and works-council duties.
Art. 26 is headed *"Obligations of deployers of **high-risk** AI systems"* and I classify this
as minimal-risk. **Citing it undercut everything around it.** The **BetrVG § 87(1)(6)**
co-determination point survives and is stronger.

---

# PART 6 — What I am asking you

## 6.1 The wall questions — highest value

For each of these, I want either *"that is a real wall"* or *"here is the way around it."*

1. **§3.6 — the scorer template server crash.** Has anyone deployed an
   `agentforce_session_tracing__scorerMeasurement` prompt template from source? What is the
   valid `<definition>` for a `Session` input? Is there a non-Metadata-API route?
   **This is the item I most want to be wrong about.**
2. **§3.1 — Agent Script publish 404.** Edition boundary, or a setting?
3. **§3.2 — `topic_assertion` truncation.** Known? Avoidable? Worth filing?
4. **§3.3 — quality judges punishing correct refusals.** Any way to give them guardrail
   context, or is this a finding rather than a bug to route around?
5. **§3.8 / §3.15 — genuine multi-subagent behaviour.** Is a composite Apex action the only
   honest answer, or is there a pattern that produces real orchestration today?
6. **§3.17 — the Escalation Gap with nothing to catch.** Planted violation, or is there a
   naturally-occurring gap in a realistic partner sharing model?
7. **§3.9 — measuring credits in Developer Edition.** Any route at all?
8. **§3.11 — the child-formula-checkbox + filtered-roll-up pattern.** Sound, or will it hit a
   limit I have not found?

## 6.2 The judgement questions

9. **Was the identity decision right?** Engine first, agent as interface — given that the risk
   argument that motivated it no longer applies, and the reason is now *"the best finding is an
   engine insight."*
10. **Is §3.18 — writing up `factuality` as anti-correlated with correctness — a strong
    finding, or excuse-making?**
11. **Is the two-tier gate (§2.3) actually novel,** or does it just sound novel? R7 claimed
    nobody in the Agentforce ecosystem publishes a gate with a power calculation behind it.
12. **Which of the §3D cuts was wrong?**

## 6.3 The question I care about most

> **What would make this dramatically stronger that is on none of these lists?**

Concretely:

- **What could this project do that would make a Salesforce engineer say *"I did not know you
  could do that"*?** Not "that is thorough." Not "that is well-tested." The reaction I am
  after is genuine surprise at a capability.
- **What is the most impressive thing that is possible today, in a Developer Edition, that
  essentially nobody has shipped?** I have platform access, unlimited credits in practice,
  and no deadline pressure. Constraint is imagination, not budget.
- **Where is this project still ordinary?** Which part would a reviewer skim past? I would
  rather cut a whole section than ship something forgettable.
- **Is the German regulatory depth actually the differentiator I think it is** — or is it
  invisible to a Salesforce reviewer who cannot evaluate it, and I should be spending that
  effort on something a Salesforce engineer *can* judge?

Be blunt. The last round of this was worth more than everything I did on my own.
