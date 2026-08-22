# Prior art — what is already public, and what is actually unoccupied

Researched 2026-08-22 against GitHub code search, Salesforce's own repositories, the Agentforce
docs, and the wider LLM-evaluation ecosystem. The purpose was not to find ideas. It was to find
out **which of this project's claims survive contact with someone who checks.**

Three of them did not.

---

## 1. The testing gap is real — but the number this project was going to publish is wrong

The design's headline market claim was *"only five public repositories run Agentforce agent
tests in CI."* The measurement method matters more than the number, so here it is.

**Method.** `gh api "search/code?q=<q>&per_page=1" --jq .total_count`, authenticated, run
2026-08-22. Distinct repos by paging `.items[].repository.full_name` and deduping.

**Four caveats, all of which apply to any number quoted from this:**

1. GitHub's code index is partial — private repos, very large files and most forks are excluded.
   **Every figure is a lower bound, never a census.**
2. **Qualifier-only queries such as `path:aiEvaluationDefinitions` are rejected by the API and
   return `0` silently.** Any earlier census built on bare `path:` qualifiers is simply wrong.
3. Results cap at 1,000 per query.
4. Code search is rate-limited to 10 requests/minute.

| Query | Files | Distinct repos |
|---|---|---|
| `AiEvaluationDefinition` (bare string) | 599 | 118 |
| **`AiEvaluationDefinition extension:xml`** | **39** | **19** |
| `AiTestingDefinition extension:xml` | 4 | 3 *(two are Salesforce's own tooling)* |
| **`AiAgentScorerDefinition extension:xml`** | **3** | **2** |
| `AiAuthoringBundle extension:xml` | 381 | 45 |
| `GenAiPlannerBundle extension:xml` | 70 | 46 |
| `AiRetriever extension:xml` | **3** | — |
| `McpServerDefinition extension:xml` | 34 | 23 |
| **`"sf agent test run" path:.github/workflows`** | **5** | **3** |

**The bare-string number is 599 and the real number is 39.** The remainder is skill mirrors,
documentation scrapes and unrelated projects — `FoodBite`, `Alx_DjangoLearnLab`. Quoting 599
would be checkable and wrong. **Never publish the bare-string figure.**

### Who actually runs agent tests in CI: two repositories, one author

Three matched; all three workflows were read.

- **`Think2Corp/AgentforceCICD`** (4★) — the genuine article and the best public prior art.
  `sf agent test list --json | jq` → an Actions **matrix** → `sf agent test run` → results →
  artifact upload → aggregate job → **`if PERCENT < 75 → exit 1`**. Scratch-org pooling with
  return-to-pool, and a `patchTestVersions.sh` that rewrites test definitions with the latest
  agent version.
- **`Think2Corp/AgentforceWorldTour25`** (3★) — same author, earlier.
- **`dnortje-sys/SV1-2-Prototype`** — the `sf agent test run` block is **commented out.**

**And nobody gates on a score.** The single public gate in existence is a flat pass-rate
percentage across everything. No public repository asserts on an evaluator threshold, a
per-metric score, or a delta against a committed baseline.

### Salesforce's own samples ship evaluations and never run them

| Repo | ★ | Ships an eval? | Runs it in CI? |
|---|---|---|---|
| `trailheadapps/coral-cloud` | 152 | **Yes** — `Employee_agent_tests.aiEvaluationDefinition` | **No.** Six workflows: Jest and `sf apex test run`. `sf agent test` appears in none. |
| `forcedotcom/afdx-pro-code-testdrive` | 6 | **Yes** — `.agent` + `testSpec.yaml` | **No `.github/` directory at all.** |
| `msrivastav13/agent-development-lifecylce` | — | Two evals, two bundles | Only `deploy-pages.yml` |
| `SalesforceAIResearch/agentforce-adlc` | 100 | — | Only a pytest job over skill assets |

**No official Salesforce sample ships an agent, an evaluation, and CI that runs the evaluation.
That combination does not exist publicly.** The claim survives; only its arithmetic changes.

---

## 2. Two of this project's planned "wow" items are already ordinary

### 2.1 Prompt-injection red-teaming is now Salesforce's own shipped product

`forcedotcom/sf-skills` contains an `agentforce-test` skill whose Mode C is a full **OWASP LLM
Top 10** methodology: seven payload catalogues, severity weights (CRITICAL −25, HIGH −15,
MEDIUM −8, LOW −3) and an **A–F rubric** where any CRITICAL forces FAILED.

Building that is no longer a differentiator. And there is a worse problem, which is the same
structural defect that killed the Escalation Gap:

> **`Inappropriate_Content`, `Prompt_Injection` and `Reverse_Engineering` are platform-level
> topics that intercept the utterance before the custom planner ever sees it.**

So an injection suite **grades Salesforce, not this project**, and comes back green by
construction. That is the second time a headline metric has turned out to be structurally
incapable of failing. The lesson is now a rule: **before adopting a metric, ask what would have
to be true for it to come back red.**

### 2.2 Mutation testing of grounding is well-trodden — the claim must be rewritten

The plan was to claim *"nobody publicly mutation-tests an AI agent's grounding."* **That is
false and would be caught immediately.**

- **promptfoo ships corpus poisoning as a documented product feature** —
  `promptfoo redteam poison <docs> --goal "..."` generates poisoned versions of your own
  documents, and its `rag-poisoning` plugin explicitly covers **factual corruption**, not merely
  instruction injection.
- Active academic literature since 2024: **PoisonedRAG** (arXiv 2402.07867 — five documents in a
  corpus of millions, >90 % success), **Drowzee** (2405.00648, metamorphic testing for
  fact-conflicting hallucination), metamorphic hallucination detection (2502.15844), and several
  2026 papers on knowledge-base poisoning.

**What survives, and it is a narrower and better claim.** All of that work is either *security*
research (can an attacker break the system?) or benchmark construction. It targets the **agent**.
This project's claim targets the **test suite**: seed known corruptions into a corpus you own and
report **what fraction your own scorers caught** — a mutation score for the evaluation, not an
attack on the model. Nothing found does that.

And the Salesforce-specific gap is citable, from Salesforce's own methodology:

> `skills/agentforce-test/references/owasp-categories.md` — *"**LLM03: Training Data Poisoning —
> Out of Scope** — requires access to training pipelines, not runtime behavior."*

Its LLM09 Misinformation techniques are entirely prompt-side — gaslighting, false premises,
pressure. **Never corpus-side.**

**Wording that survives a skeptic:**

| ❌ Do not say | ✅ Say instead |
|---|---|
| *"Nobody publicly does this."* | *"We report a **mutation score for the evaluation suite itself**: N seeded corruptions of the statute corpus, M caught, and which scorer caught which."* |
| *"Mutation testing of AI grounding is novel."* | *"**No public Agentforce repository does grounding-corpus fault injection**, and Salesforce's own OWASP methodology declares data poisoning out of scope."* |

The engineering contribution is the **mechanism**, not the idea: `sf agent adl file delete` +
`file add` triggers a SearchIndex re-hydration, which makes the mutation scriptable in CI. That
part nobody has built.

---

## 3. What is genuinely rare — measured, not asserted

| Artifact | Public files / repos | Note |
|---|---|---|
| **`AiAgentScorerDefinition`** | **3 / 2** | One of the two is this project's own probe. **The rarest deployable artifact on the platform.** |
| **`AiRetriever`** | **3** | Effectively unused publicly |
| `AiTestingDefinition` | 4 / 3 | Two are Salesforce's own tooling |
| `sf agent test run` in a workflow | 5 / 3 | Two really run |
| `Regulation__mdt` | **0** | Compliance-as-code on Salesforce is empty |
| `XRechnung` / `Peppol` / `Marktlokation` in Apex | **0 / 0 / 0** | — |
| `EnWG` in Apex · `Eichrecht` in Apex | **1 · 1** | — |

**German energy law as code exists as two unstarred Python repositories and nothing at all on
Salesforce.**

---

## 4. Agent Script is open source, on npm, and extensible — the best unexploited surface

`github.com/salesforce/agentscript`, created 2026-04-13, Apache-2.0, 264★, pushed 2026-08-21.
A monorepo containing the tree-sitter parser, the compiler, an LSP, Monaco/VSCode integration —
and a **lint engine with fifteen built-in passes and a documented `defineRule` extension API**
(`apps/docs/docs/extending/custom-lint-passes.md`).

Published to npm as `@sf-agentscript/*` — `parser` 4.0.19 (9,430 downloads/month), `language`
3.2.3, `compiler` 3.8.1.

**It needs no org, no credits and no deployment.** A custom lint pass over the `.agent` file runs
in milliseconds in CI and can enforce project rules statically:

- every binding in `reasoning.actions` must carry a `description`
- no subagent may expose a write action without an `available when` guard
- every referenced action must exist in the Apex layer

That turns agent review into **static analysis**, and virtually no Salesforce engineer knows the
compiler is on npm.

Two related mechanisms worth keeping:

- **`before_reasoning` / `after_reasoning` are explicitly non-LLM.** SPEC.md §6: *"Template
  strings (`|`) are not permitted — this block is deterministic and not LLM-driven."* So Apex can
  normalise units or route jurisdiction **before the model reasons**, with the result driving
  `available when` guards.
- **`sf agent preview start|send|end|sessions` is a programmatic session API**, not an
  interactive REPL — so a multi-turn German conversation can be scripted, and then asserted
  against `sf agent trace read --format detail --dimension routing`, from local files, with no
  Data Cloud.

---

## 5. The scorer catalogue settles the gate design

From `forcedotcom/agents/src/ngtScorerCatalog.ts` (Apache-2.0), which is the source of truth:

| Deterministic — `PASS_FAIL`, **no LLM in the loop** | LLM-judged |
|---|---|
| `topic_sequence_match` | `coherence`, `conciseness`, `factuality`, `completeness` — `LLM_0_100` |
| `action_sequence_match` | `task_resolution` — `LLM_0_5`, multi-turn only |
| `agent_handoff_match` | `bot_response_rating`, `response_match` — `LLM_PASS_FAIL` |
| `output_latency_milliseconds` — `NUMERIC` | |

**Gate the build on the deterministic three. Publish everything else as a trend artifact.**

Everyone assumes agent tests are inherently ungateable because a judge is always involved.
Almost nobody has read the catalogue closely enough to know which scorers have no judge — and
the one public CI repository gates a flat 75 % across all of them indiscriminately.

**And do not gate on latency.** This project's own probe data (`docs/platform-probes/variance-runs.jsonl`)
shows `output_latency_milliseconds` at 2778 / 2881 / **4352** ms across identical runs — a 57 %
spread. Use a percentile over N runs, or a delta against a committed baseline.

---

## 6. Techniques worth stealing from outside the Salesforce world

- **Judge calibration** — the strongest transferable pattern. Score a representative set with the
  judge, have humans label the same set, measure agreement, **set the deploy threshold below the
  measured agreement**, and run any new scorer in **shadow mode before it blocks anything.**
- **Regression from production** — turn observed failures into permanent regression cases.
- **Statistical grounding is a live differentiator**, not a nicety: Braintrust's results page has
  no significance concept at all, and LangSmith markets statistical rigour against it. A gate with
  a power calculation behind it is genuinely uncommon.
- **Division of labour in mature teams** — promptfoo for red-team gates, DeepEval (pytest) for
  quality gates, Ragas for continuous RAG dashboards.
- **Sobering** — independent benchmarks report that no framework reliably distinguishes a
  factually wrong context from a correct one. Which is itself the argument for **citation by key
  over similarity retrieval**.

---

## 7. Steal the provenance model from NIST OSCAL

The statute-in-Custom-Metadata design was invented here. It does not have to be — **NIST OSCAL's
catalog schema already specifies exactly this shape**, and citing it converts an invented
architecture into a sourced one:

| OSCAL | `Rechtsnorm__mdt` |
|---|---|
| `control.id` — stable key | `DeveloperName` |
| `part.prose` — normative text | `Text__c` |
| `link.rel="reference"` | self-lookup for hierarchy |
| `back-matter.resources[].citation.text` + `rlinks.href` | `Quelle__c` — resolvable URL |

OSCAL: 942★, pushed 2026-08-20. **Catala** (2,366★) is the intellectual precedent for
law-to-code faithfulness — statute text annotated article by article.

Add a CI check that the committed Custom Metadata still hashes to the upstream
gesetze-im-internet XML, and a hallucinated citation becomes **structurally impossible**: the key
comes from the rules engine, not from a similarity search.

---

## 8. Agentforce Energy & Utilities — the two facts that carry credibility

**The product was renamed.** It is now **"Agentforce Energy & Utilities"** (formerly Energy &
Utilities Cloud), on the Agentforce 360 Platform. Origin: Vlocity, acquired 2020 for $1.33 bn.

**And there are two runtimes, mid-migration** — the legacy Vlocity **managed package**
(`vlocity_cmt__` namespace) and the newer **OmniStudio standard runtime on core** (standard
objects, no namespace), with a Salesforce-supplied Migration Assistant CLI between them. The
trial org page offers three flavours reflecting exactly that split.

**Knowing this migration exists, and being able to name both sides, is the highest-credibility
single thing to demonstrate about this product.**

### The data-model trap

Real standard objects (E&U Developer Guide v66.0): **`ServicePoint`** *(with `ServiceType`,
`PremisesId → Location`, `InstallationType` including Smart Meter)*, `EnergyServiceAgreement`,
`EnergyServiceAgreementItem`, `BillingAccount`, `Location`, `Address`.

**`Meter`, `Meter Reading`, `Consumption`, `Premises`, `Service Account`, `Party` and `Place` are
NOT standard objects.** They are managed-package or purely conceptual entities in the Data Model
Gallery. **Anyone claiming "Salesforce has a standard Meter object" is wrong** — and that is a
cheap way to be caught.

**No Developer Edition exists for E&U** — 30-day trials only. But **Business Rules Engine
documents itself as available in Developer Edition** (Industries Common Resources Developer
Guide), while third-party sources call it an Industries add-on. That is a fifteen-minute test in
the existing org with a large payoff: BRE = Expression Sets + Decision Matrices + Decision
Tables, invocable from Flow, OmniStudio, **Agentforce actions**, Connect REST and Apex.

**Zero real public E&U Cloud code exists on GitHub** — the two matching repos are certification
exam dumps, and all 51 `EnergyServiceAgreement` hits are documentation scrapes.

### And E.ON *is* a published Agentforce customer

**A Salesforce customer story for E.ON Energie Deutschland on Agentforce was published
2026-05-20**, German-language. It is thin — no customer quote, no metrics, **no mention of E&U
Cloud** — but it exists and is citable, which a parallel research pass had concluded it did not.

For contrast, the deepest Agentforce-in-energy reference anywhere is **ENGIE Belgium**: Agentforce
+ Data 360 + E&U Cloud, French and Dutch, **1,500+ conversations per day, 71 % resolved
autonomously, 83 % accuracy**, calling SAP ERP to activate smart charging. Salesforce's own
Agentforce customer hub names **only ENGIE** in energy.

The deepest German reference is **evo (Energieversorgung Oberhausen) with Salesfive** —
Experience Cloud + E&U Cloud + OmniStudio + Service Cloud, integrated to **SAP IS-U via
MuleSoft**, live December 2024, 23,000+ portal customers, NPS +49.

**Scope advice:** align with the standard E&U naming and publish a mapping table with doc URLs.
Gesture at MaLo/MeLo and OCPP. **Avoid CIM** — it is a grid/network model and Salesforce's is not
CIM-aligned. **Avoid EDIFACT/MaKo** — a half-implementation of a multi-year integration domain
reads as naive; saying *"handled by the MaKo layer"* reads as someone who knows where the
boundary is.

---

## 9. What would actually surprise a working Agentforce engineer

Ranked by surprise × feasibility. Every one is grounded in a verified mechanism.

| # | Thing | Why it surprises | Difficulty | DE |
|---|---|---|---|---|
| **1** | **Gate CI only on the three deterministic `PASS_FAIL` scorers**; demote every judged score to non-blocking telemetry | Everyone believes agent tests are ungateable because a judge is always involved. Almost nobody has read the catalogue. | LOW | ✅ |
| **2** | **Assert on the agent's action *input parameters*** via `customEvaluations` JSONPath — `$.generatedData.invokedActions[*][?(@.function.name=='X')].function.input.leistung_kw` | Proves the model parsed "12 kVA" into `12` — judging nothing. Documented only inside a `.a4drules` file in a 6★ repo. | MED | ✅ |
| **3** | **Mutation score for the eval suite**, driven by `sf agent adl file delete\|add` in CI | Demonstrates the tests *can* fail — which every eval demo skips | HIGH | ⚠️ verify |
| **4** | **A custom Agent Script lint pass** via `@sf-agentscript/language`'s `defineRule`, gated on the PR | Zero org, zero credits, milliseconds. Turns agent review into static analysis. | MED | ✅ (no org) |
| **5** | **Script multi-turn conversations** with `sf agent preview start\|send\|end`, then assert on `sf agent trace read --dimension routing` | Everyone thinks preview is an interactive REPL | MED | ✅ |
| **6** | **A German/English delta harness** — identical spec in two locales, routing must match | Zero public German Agentforce demos; German is Beta; Winter '27 adds 24 languages | MED | ✅ |
| **7** | **Statute in Custom Metadata cited by key**, generated from official XML, hash-checked in CI, modelled on OSCAL | Makes a hallucinated citation *structurally impossible*. `Regulation__mdt` = 0 public hits. | MED | ✅ |
| **8** | **A `before_reasoning` deterministic pre-LLM guard** running Apex on the raw user input | Most people assume everything upstream of the model is prompt engineering | MED | ✅ |
| **9** | **JUnit output plus a per-case regression ratchet** against a committed baseline | Converts a stochastic suite into an ordinary engineering artifact — and sidesteps the threshold argument entirely | LOW | ✅ |
| **10** | **Commit the failures** — a quarantine list of what the agent gets wrong, with the platform's own trace explaining why | Portfolio repos are uniformly all-green. This reads as senior. | LOW | ✅ |

Deliberately ranked lower: a custom `AiAgentScorerDefinition` — only 2 public repos have one, so
it is extremely rare, but it is Beta, needs the Agentforce Scorer Beta permission set, and
Session-scope-only sharply limits what it can see.

---

## 10. What is already ordinary — do not spend effort here

1. **An agent with subagents and Apex invocable actions.** 381 files / 45 repos. Table stakes.
2. **An LWC dashboard.** Every portfolio project has one. It is a screenshot, not evidence.
3. **Prompt-injection red-teaming.** Salesforce ships the methodology — and the platform
   intercepts before your planner sees it, so it grades green by construction.
4. **A security A–F badge.** Salesforce publishes the exact rubric and thresholds.
5. **Headless Agent API / a custom chat UI.** 65+ repos including Cognizant, Accenture, AWS Labs.
6. **Scratch-org CI running `sf apex test run` at 100 % coverage.** Hygiene, not a differentiator —
   though missing it is a negative.
7. **"Grounded in Data Cloud."** Free to say, impossible to verify from a README, and not properly
   reachable in Developer Edition anyway. Citation-by-key is stronger *because it is checkable.*
8. **A Trailhead badge wall.**
9. **An MCP server exposing Salesforce data.** 34 files / 23 repos, plus Salesforce's own Hosted
   MCP Servers shipping free in every DE org.
10. **"AI agent for X" with no failure analysis.** The differentiator is never that it works.

---

## 11. Things a model trained before mid-2025 would not know

**Release train:** Winter '26 = Oct 2025 · Spring '26 ≈ Feb 2026 (topics officially renamed
**subagents**, April 2026) · **Summer '26 = June 2026, current in production today** ·
**Winter '27 release notes published 2026-08-19**, production 2026-09-04 onward.

**TDX 2026 (15–16 April 2026, Moscone West):** Agent Script **open-sourced** · **Salesforce
Headless 360** with 60+ new MCP tools and integrations for Claude Code, Cursor, Codex, Windsurf ·
**Agentforce Vibes 2.0**, multi-model, **free in every Developer Edition org** · **Agentforce
Experience Layer** rendering agent UI across Slack, ChatGPT, Claude, Gemini, Teams ·
**AgentExchange** · Slackbot as an MCP client · $50 M developer fund.

**Winter '27 (Oct 2026):** Agentforce Observability (Beta) · MCP interoperability · **24
additional languages** · Data 360 SQL from Apex · Flow Test Mode with reusable scenarios.

Data Cloud is now branded **Data 360**. Dreamforce 2026 is **15 September 2026**.

*Unverified:* a claim that Agent Script became the default on 13 July 2026 could not be
substantiated — the docs confirm only the April 2026 rename. Do not repeat it.

---

## 12. The exact hole in the public state of the art

The best public CI repository does this:

```bash
p=$(jq '[.result.testCases[]? | .testResults[]? | select(.result == "PASS")] | length' "$file")
percentage=$((passed * 100 / total))
# gate:  if PERCENT < 75 → exit 1
```

**`.testResults[].score` is never read.** Every `LLM_0_100` score, every `LLM_0_5` score, and
`output_latency_milliseconds` — all of it collapsed into a boolean and thrown away. One run per
test, ever. No baseline, no variance handling, no `$GITHUB_STEP_SUMMARY`, no JUnit, no PR comment.

**That is the entire public state of the art.** The gap is not conceptual; it is that nobody has
read the numbers the platform already returns.

---

## 13. The epoch loop — and why Agentforce *forces* it

Every serious evaluation framework outside Salesforce treats repeated sampling as a first-class
flag:

| Tool | Mechanism |
|---|---|
| **Inspect** (UK AISI) | `--epochs N` + `--epochs-reducer`: `mean`, `median`, `mode`, `max`, `at_least_{k}`, `pass_at_{k}`, `pass_k_{k}` |
| promptfoo | `--repeat <n>` |
| DeepEval | `--repeat`, `-r` |
| LangSmith | `evaluate(..., num_repetitions=3)` — UI shows mean **and standard deviation** |
| Braintrust | `trial_count`, per-row `EvalCase(..., trial_count=5)` |

**The reducers are the substance.** `mode_score()` is majority vote. `at_least(k, value)` is
"correct if ≥ k scores ≥ value." `pass_at(k)` is Chen et al. — and note the asymmetry:
**`pass_at` is optimistic and belongs in capability claims; `mode` and `at_least` are
conservative and are what a CI gate actually wants.** `pass^k` — all k must pass — is
`at_least(k=N)` with N = epochs.

### The structural argument, which is worth more than the code

**Agentforce gives you the repeat flag and nothing else.** There is no temperature control, no
seed, no `--grader`, no rubric override at any layer. So the thesis writes itself:

> *"I cannot pin the judge's temperature or seed, therefore I must characterise its variance
> empirically rather than assume it away."*

Backed by Inspect's reducer taxonomy and Evan Miller's *Adding Error Bars to Evals*
(arXiv 2411.00640, Anthropic — standard errors, clustered SEs for related question sets, paired
differences, and power analysis for how many cases you actually need), that sentence carries more
weight than any implementation detail.

**And the public prior art's matrix axis is wrong for this.** It shards over test name. Shard over
**repetition**:

```yaml
strategy:
  fail-fast: false
  matrix:
    epoch: [1, 2, 3]
# reduce across epochs in the aggregate job with at_least(k=3)
```

---

## 14. Judge calibration — strongest *because* the box is closed

Everywhere else, measuring judge alignment is step one of **fixing the judge**. On Agentforce you
cannot touch the judge's prompt or model. That looks like a dead end. It is actually the move.

**Measure alignment, then use the result to decide which scorers are allowed to gate.**

The method has published numbers to anchor it:

- **LangSmith** is the only product with a named metric — **`alignment score`**, "the percentage
  of examples where the evaluator's judgment matches that of the human expert."
- **Ragas** publishes a worked run: **75.6 % → 86.9 % alignment on 160 samples** after one prompt
  iteration, with the guidance that **"100–200 examples covering diverse scenarios is
  sufficient."**
- **Hamel Husain** is the practitioner canon — Honeycomb reached ">90 % agreement" in three
  iterations from ~30 examples, with the warning that matters: **"using raw agreement is generally
  not recommended and can be misleading when classes are imbalanced. Instead… measure precision
  and recall separately."** He also calls 1–5 scales "a sign of a bad eval process."
- **MT-Bench** (arXiv 2306.05685) sets the empirical ceiling: GPT-4 judges reach ">80 % agreement,
  the same level of agreement between humans" — while documenting position, verbosity and
  self-enhancement bias.

**Nobody ships kappa.** Not LangSmith, not Langfuse, not Phoenix, not Braintrust. The closest
primitives are Phoenix's `precision-recall-fscore` and Braintrust's raw match/diverge counts.

A conclusion of this shape has, as far as can be found, **never been published in the Salesforce
ecosystem**:

> *`coherence` shows κ = 0.31 against our labels, so it reports and never blocks.
> `action_sequence_match` is deterministic and blocks outright.
> `factuality` at κ = 0.68 blocks only on a 3-of-3 majority.*

That inverts the closed box from an excuse into a finding.

**One more design lever:** Phoenix states plainly that *"LLMs often struggle with the subtleties
of continuous scales… scores fluctuate significantly."* Categorical beats numeric. Which is the
citation for demoting every `LLM_0_100` scorer to advisory.

---

## 15. Ten things that are **impossible** on Agentforce — say them out loud

Stating a limit precisely is more credible than working around it silently.

| | Not possible | Consequence |
|---|---|---|
| 1 | **Temperature-0 or seed pinning**, on judge or agent | *This is why the epoch loop is mandatory, not optional* |
| 2 | **Overriding the judge model or prompt** — no `--grader`, no rubric file | You can *measure* alignment; you can never *improve* it. Route around bad metrics instead. |
| 3 | Few-shot correction loops into the judge | No injection point exists |
| 4 | Response caching for cost | Every run re-invokes the live agent — and caching is incompatible with repeats anyway |
| 5 | Cheap-model prefilter | You don't select the grading model. Levers are case count, epoch count, PR-vs-nightly split. |
| 6 | Pairwise / comparative scoring | Position bias is not mitigable — but also not incurred, since scoring is absolute |
| 7 | Hill climbing (last run's output as this run's `expected`) | Expected values are static in the deployed spec |
| 8 | **Per-case repeat counts** | Repetition is whole-suite. Honest workaround: split flaky cases into their own definition and invoke it more often. |
| 9 | Sub-metric introspection | You get a score, not a manipulable rationale |
| 10 | Server-side online eval feeding the CI dataset | The "filter production traces → add to dataset" loop has no CLI equivalent. Promotion must be human-authored. |

**Three things to build, in order:** the score-reading gate layer *(table stakes, done right)*;
the epoch loop with `at_least(k=N)` *(lifted verbatim from AISI's Inspect)*; and the calibration
study that decides which scorers may block *(never published in this ecosystem)*.

Two free wins that prior art ignores entirely: **`output_latency_milliseconds` is NUMERIC and
100 % unused** — gate on p95 across epochs, never the mean (this project's own probe:
2778 / 2881 / **4352** ms). And shadow-mode promotion costs one line: `continue-on-error: true`.

---

## 16. The hiring reality — and it is not kind to portfolios

This was researched to answer §6.3's crux question honestly. The answer is uncomfortable and
should change how the project is presented, not whether it is built.

### 16.1 What the numbers say

**Salesforce Ben Administrator Survey, 2 June 2025:**

| Factor | Score /10 |
|---|---|
| **Hands-on experience** | **9.3** |
| Certifications | 6.2 |

**Mason Frank / Tenth Revolution, 1,000+ respondents** — ranked salary boosters:
**Salesforce experience 93 % > exposure to large projects 84 % > certifications 81 %.**

**A personal portfolio project does not appear in that ranking at all.**

And the sharpest quote, from a self-identified hiring manager on r/salesforce (5 March 2023) —
his interview questions *"involve the project that you are currently working on"*:

> *"This tells me more about your abilities and understanding than a portfolio ever could."*

### 16.2 The DACH evidence is a hole

**Zero German, Austrian or Swiss accounts exist of a portfolio project producing a Salesforce
hire.** The DACH entry stories that do exist — Salesforce Deutschland's own career-changer blog
(1 May 2022) and Capgemini Deutschland's Salesforce Consultant story (July 2022) — credit
**Trailhead, certifications, community and sponsored programmes. Never a portfolio.**

Capgemini states its own entry bar plainly: graduates and career changers **do not need deep
Salesforce expertise beforehand**; Trailhead builds the foundation in **3–6 months on the job**.

**And Capgemini Germany is the only German employer on record with a position on GitHub in
applications at all.** Roughly a dozen German query variants across employer blogs, dev media and
recruiter sites produced no second one. The German-language search results for this topic are
dominated by AI CV-generator content farms. *(A "55 % higher interview rate" figure circulating on
one of them is vendor marketing with no methodology. Do not use it.)*

### 16.3 But read the nuance before concluding the wrong thing

The hiring manager is **not** saying built work is worthless. He is saying that **fluently
narrating a real project under questioning** beats a static artifact. That is an argument for
being able to defend every architectural decision in this repository out loud — not an argument
against building it.

And the one genuine convergence in the German-language evidence points at exactly this project's
shape. **Capgemini (employer, 31 Oct 2023)** and **Jobriver (job board, 14 Jan 2025)**
independently recommend the same thing:

> *"Verlinke **maximal zwei bis drei repräsentative Repositories** in der Bewerbung und erläutere
> diese kurz im Lebenslauf oder Anschreiben."*
> *"Es ist sinnvoller, **wenige, dafür aber sorgfältig gepflegte Repositories** einzubringen,
> statt eine Vielzahl halbfertiger… Projekte."*

**Two to three curated, deeply documented repositories — not a scattering of tutorials.** That is
the shape of one deep project, which is what this is.

The only Germany-attributed statement found ranking portfolio above certification is anonymous —
*"Professional experience and a corresponding project portfolio are more important than holding a
certification,"* Solution Architect, Germany (Mason Frank). In recruiter register, "project
portfolio" there almost certainly means **a track record of delivered professional projects**, not
a GitHub repo. Do not overclaim it.

### 16.4 The language question has two different answers

- **Salesforce Germany's own careers page:** *"English is our primary business language… fluency
  in English is essential."* German *"can be a great asset in customer-facing roles."*
  **An asset, not a gate.**
- **E.ON Energie Deutschland's senior Salesforce postings:** *"Deutsch (C1) sowie auf Englisch
  (C1)"* — **an explicit, non-negotiable gate.**

Both are true. The bar is set by the employer, not the market. Practitioner consensus for
English-only candidates in continental Europe: target **large consultancies**, where enterprise
projects run in English; the difficulty rises sharply on small and mid-size projects with direct
local-language client contact.

### 16.5 Trailhead rank and superbadges — the verdict is negative

Practitioner consensus, consistent across threads and including a recruiter with 50+ Salesforce
hires (*"I never care about super badges"* — and it *"almost is a detriment"* on a CV):

**real-world experience > certifications > superbadges.**

The actively harmful case, stated by a hiring manager: *"If I see a bunch of superbadges or
'Ranger status' and no certs, I assume they're a beginner who has brute-forced their way
through."*

**95 %** of Salesforce professionals use Trailhead — which is precisely what makes it a
non-differentiator.

**One exception, and it is relevant to this project's target employers:** *"If your employer is an
SI or ISV to Salesforce, they do care about badges. Counts to their partner ranking."* At
Capgemini, Accenture, adesso, factory42 or Merkle, badges have instrumental value — **to the
employer's partner tier, not as evidence of skill.**

**No German employer, recruiter or DACH source anywhere expressed a view on Trailhead rank in
hiring.** That gap is itself a finding.

### 16.6 What this changes

| Was going to | Now |
|---|---|
| Present the repository as the evidence | Present it as **the thing to be interrogated about**. Every architectural decision must be defensible out loud, in one sentence, without notes. |
| Scatter effort across several demos | **Two to three curated repositories**, deeply documented — which is what both German sources independently recommend |
| Assume depth is self-evidently valuable | Assume a reviewer spends minutes and does not run CI. The README carries the argument; the repo carries the proof. |
| Treat certifications as secondary | They rank above a portfolio in every survey found. **Not a substitute for building — a prerequisite alongside it.** |
| Treat "German C1" as a market-wide gate | It is **employer-specific**. Consultancies and Salesforce itself run in English; E.ON does not. |

---

## 17. The official Agent Script corpus — and the six recipes Salesforce parked

`trailheadapps/agent-script-recipes` (133★, created 2025-12-08, pushed 2026-08-13) is the real
Agent Script reference corpus — not coral-cloud. **32 `.agent` files** organised as a curriculum:
language essentials → action configuration → reasoning mechanics → architectural patterns.

### Three things it does not do, verified rather than inferred

**1. Zero test or evaluation artifacts.** A strict grep for
`aiEvaluationDefinition|aiTestingDefinition|testSpec.yaml` across all 729 paths returns **0**. The
official Agent Script reference corpus contains no agent tests of any kind.

**2. `bin/validate-agent-scripts.sh` exists and is wired into nothing.** The script is real and
correct — it walks every `.agent` file, runs `sf agent validate authoring-bundle`, tracks
VALIDATED/FAILED and exits 1 on any failure. All five workflows and `package.json` were checked:
**zero occurrences.** Salesforce wrote the compile gate, committed it, and never hooked it up.

**3. CI deploys agents and never exercises them.** `ci.yml` creates a scratch org, assigns
permission sets, deploys, imports data, creates a service-agent user — then stops. The only tests
that run are `sfdx-lwc-jest` and `sf code-analyzer`. *(Operational detail worth budgeting for: a
hardcoded `sleep 120` after scratch-org creation.)*

### The parked directory, and what its contents say

`.forceignore` line 28 excludes `**/future_recipes/**`. Six recipes sit there:

| Parked | Completeness |
|---|---|
| `complexStateManagement` | custom object, two flows, **Apex test** |
| `contextHandling` | custom object, **`Contact.Language__c` + `Timezone__c`**, two flows, Apex test |
| `multiSubagentOrchestration` | four custom objects, four flows, Apex test |
| `escalationPatterns` · `conditionalLogicPatterns` | `.agent` only |
| `subagentDelegation` | one flow |

**Read the list.** Salesforce shipped the easy patterns and parked the hard ones — state
management, conditional logic, context handling, escalation, multi-subagent orchestration and
delegation. Three of the six were built far enough to have custom objects, flows and Apex tests,
then held back. **And localization sits in the parked pile**, which quietly corroborates the
multilingual weakness §11 describes.

### What this sharpens

**§1's claim gets more precise, and stronger.** Of the four official Agentforce sample repos —
`coral-cloud` (152★), `agent-script-recipes` (133★), `afdx-pro-code-testdrive` (6★),
`agentforce-adlc` (100★) — **not one runs an agent test in CI.** Two ship eval definitions that
never execute; one ships a compile-validation script wired to nothing; one has no CI directory at
all.

**§9 gains a free win, slotting in around #4.** Wire `validate-agent-scripts.sh` — or its
`@sf-agentscript/compiler` equivalent — into a PR gate. Paired with the custom lint pass, that is a
**two-stage static gate on agent source: compile-check plus policy-check, before any org, credit or
LLM is touched.** And the framing is unusually good:

> *"Salesforce shipped this script and never ran it. I ran it."*

**§10 gains an entry.** Copying the recipe patterns themselves — `openGateRouter`,
`safetyAndGuardrails`, `errorHandling`, `bidirectionalNavigation` — is now explicitly **ordinary**.
They are the official teaching examples in a 133★ repo; demonstrating them proves you read the
docs. The **parked** six are the opposite: `escalationPatterns` and `conditionalLogicPatterns` are
patterns Salesforce itself has not published a working example of.

### One census correction

**`GenAiFunction.isConfirmationRequired` is ordinary, not rare — 842 files.** Any framing that
presents human-in-the-loop confirmation as a differentiator is wrong and would be caught. Worth
*using* — it is the only declarative HITL field in the metadata model — never worth *claiming*.

Three that get sharper, all file counts, all lower bounds:

| Query | Files | Read |
|---|---|---|
| `customEvaluations string_comparison` | **24** | Confirms §9 item #2 as genuinely rare |
| `"de_DE" extension:agent` | **3** | **German Agent Script barely exists.** §9 item #6 is on empty ground |
| `"sf agent adl"` | **39** | The mutation mechanism rests on a command almost nobody has scripted — the upside and the risk in one fact |
| `ruleExpressions genAiPlannerBundle` | 37 | Rarer than expected for the only non-prose declarative guardrail — supporting evidence, not a headline |
