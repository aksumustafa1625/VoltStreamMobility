# VoltStream Mobility — Claude project guide

This file is the source of truth for how Claude should work on this repo.
Read it first every session; it captures the conventions, hard rules, and
workflows that the README does not spell out.

For business context (scenario, data model, screenshots, demo steps) read
[README.md](README.md). This file deliberately does **not** repeat it.

---

## What this project is, in one line

A Salesforce DX portfolio project (Apex + LWC) showing a B2B EV-charging
channel-partner CRM, built to clear the bar for senior Salesforce job
postings in the German e-mobility / automotive market.

---

## Architecture rules (non-negotiable)

These are hard rules. Violating them is a regression, not a style choice.

1. **Kevin O'Hara trigger framework, four-layer separation.**
   Every Apex trigger must extend `kevinohara80/sfdc-trigger-framework`'s
   `TriggerHandler`. Layers stay strictly separated:
   - `*Trigger.trigger` — 3 lines, `new ...Handler().run();`
   - `*Handler.cls` — only context dispatch, zero business logic
   - `*Helper.cls` — stateless static logic, fully unit-testable
   - `TriggerHandler.cls` / `TriggerHandler_Test.cls` — framework files,
     copied **verbatim**; never edit.

2. **All SOQL goes through a `<SObject>Selector` class.**
   Handlers and Helpers must not inline SOQL. Every query needs a
   `LIMIT 50000` defensive cap and `WITH USER_MODE` where applicable.
   Examples: `ResellerSelector`, `DocumentSelector`.

3. **All string normalization goes through `StringUtils`.**
   Never inline `.toLowerCase()`, `.trim()`, or phone formatting in Helpers
   or Controllers. When the rule changes it must change in one file. Null
   safe contract: blank in -> null out, never throws.

4. **ApexDoc headers on every custom class and trigger.**
   Every file we own ships with:
   ```apex
   /**
    * @description  ...
    * @group        VoltStream Channel Partner Management
    * @author       Mustafa Aksu
    * @date         YYYY-MM-DD
    */
   ```
   Public methods get `@param` / `@return`. Kevin O'Hara verbatim files
   stay untouched.

5. **Every custom class ships with its own `<Name>Test.cls`.**
   Coverage target: 100% on custom code. Helpers get unit tests (direct
   static calls, no DML). Triggers / Handlers get integration tests
   (through DML so the trigger actually fires). Tests use
   `TestDataFactory` — never re-implement record builders per test.

---

## LWC conventions

The recent `documentManager` LWC established these:

- **Do not rely on SLDS CSS variables to color `lightning-icon`.**
  Shadow-DOM inheritance is unreliable across SDS / SLDS generations and
  silently leaves icons in the default dark gray. When a colored icon is
  needed, use a raw inline `<svg fill="currentColor">` and set the color
  via `style="color: ..."` from JS. See `documentManager.html` /
  `documentManager.js` for the pattern.

- **Apex backing classes follow the same layered pattern.**
  LWC controllers (e.g. `DocumentController`) are thin facades — they
  validate input, then delegate SOQL to a Selector and side effects to
  whatever helper makes sense. Same rule: no inline SOQL.

---

## Workflow (commands you'll actually run)

### Deploy a focused change

```powershell
sf project deploy start --source-dir <path> --ignore-conflicts
```

Use a narrow `--source-dir` (an Apex class, an LWC folder) rather than
deploying all of `force-app`. Faster, and avoids unrelated metadata drift.

### Deploy + run only the tests that matter

```powershell
sf project deploy start `
  --source-dir force-app/main/default/classes/<Class>.cls `
  --source-dir force-app/main/default/classes/<Class>Test.cls `
  --test-level RunSpecifiedTests --tests <ClassTest> `
  --ignore-conflicts
```

### Full validation before merging

```powershell
sf project deploy validate --source-dir force-app --test-level RunLocalTests
```

`validate` is a dry run — org state is unchanged regardless of the result.

### Commit + push (auto-commit pattern)

For this project, **commit and push after every meaningful change without
asking**. Atomic commits, conventional prefixes (`feat:`, `fix:`,
`refactor:`, `test:`, `docs:`, `style:`, `chore:`). One commit per
logical change.

Commit message body should explain the *why*, not the *what*. Trailer
line is always:

```
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

Pushes target `main` directly (this is a portfolio repo, no PR review
gate). If the harness blocks the push as a soft default-branch guard,
run `git push origin main` separately and let it through.

---

## Where things live

- `force-app/main/default/classes/` — all Apex (production + tests).
  Naming: `<Name>.cls` + `<Name>Test.cls`, no separate test folder.
- `force-app/main/default/triggers/` — one-liner trigger files only.
- `force-app/main/default/objects/<SObject>/` — custom objects, fields,
  list views, validation rules.
- `force-app/main/default/lwc/<componentName>/` — LWC bundles (html, js,
  css, meta.xml).
- `force-app/main/default/layouts/` — page layouts.
- `force-app/main/default/permissionsets/` — permission sets.
- `scripts/apex/` — idempotent demo data and one-off scripts.
- `manifest/` — `package.xml` + `destructiveChanges.xml`.

---

## 📍 WHERE WE ARE — read this first, every session

**Last updated: 2026-08-22.** Everything below is the current state after eight
design reviews, ten research agents and one measured platform probe round.

### The one-paragraph version

Phases 1 and 2 are deployed and green. **Phase 3 is a German EV-charging
regulatory compliance engine, with Agentforce as its interface.** The design was
reviewed by eight independent AI reviewers, then every platform assumption was
measured in the live org, then every legal claim was read from the statutes. The
research is **finished**. Nothing new is deployed yet. **The next action is a
six-probe session, then a vertical slice.**

### The decision that shapes everything

> **The engine decides. The agent explains.**

Per-record legal status is a **formula field visible in a list view** — a reviewer
sees compliance state without running an agent, without running CI. Cross-record
aggregation is **Apex**. The agent's job is to pick which deterministic check runs
and to narrate the result in German. It never makes a legal decision.

The interview sentence: *"The agent cannot get the compliance decision wrong,
because the agent does not make the compliance decision."*

**Agent orchestration (connected subagents) was considered and CANCELLED
2026-08-22.** One agent, 3–4 subagents inside it, decomposed by verb not by legal
regime. Reasons: it puts the legal decision back inside four LLMs, it costs 6 LLM
generations per question against a Developer Edition ceiling of 150/hour, and it
is Beta.

### Where the documents are

| File | What it holds | Lines |
|---|---|---|
| `docs/DOMAIN_VERIFICATION.md` | German law, quoted from primary text. **The differentiator.** | ~1,180 |
| `docs/MARKET_REALITY.md` | What the German job market actually asks for. Uncomfortable. | ~870 |
| `docs/PRIOR_ART.md` | What is already public, what is genuinely unoccupied | ~820 |
| `docs/PHASE0_VERIFICATION.md` | Measured platform behaviour, 5 runs | ~430 |
| `docs/DECISION_LOG.md` | Eight reviewers, every proposal, with a status | ~2,040 |
| `docs/AGENT_DESIGN_FOR_REVIEW.md` | The doc the reviewers read — **unedited**, with a corrections banner | ~1,650 |
| `docs/PROBE_PLAN.md` | **The next session starts here** | — |

---

## 🧱 Wall status — what is settled, what is open

Eighteen walls were recorded. After research and three second-round reviews:

| Wall | Verdict |
|---|---|
| Agent Script publish `404` | ✅ **DEAD, 2026-08-23.** `default_agent_user` was this project's **System Administrator**; Salesforce's known-issues says that returns the failure **masked**, which is the bare 404. The org already held an `EinsteinServiceAgent User` with the `Einstein Agent User` profile. One line changed → publish succeeded, `BotDefinition` + `BotVersion 1` created. **Agent Script is the deployed source. Days 5–6 are Agent Script.** |
| Scorer template server NPE | ✅ **Off the critical path, 2026-08-23.** The NPE is gone on CLI 2.148.3 — the server now returns a proper validation naming `[AllowedRange, Session]`. `Session` wants an SObject that only exists once Data Cloud is provisioned (licensed, never set up). **But Probe 5 made it optional:** cosine similarity scored a correct German legal statement 0.919 and a lie about repealed law 0.855 — six points. Semantic scoring is the wrong instrument here. **The deterministic transcript gate is the design, not the fallback.** |
| `AiAgentScorerDefinition` not in CLI registry | ✅ **DEAD, confirmed 2026-08-23.** `sf update` → CLI 2.148.3 → the error changed from `RegistryError` to `ComponentSetError: No source-backed components`, which means the registry now knows the type. |
| `topic_assertion` truncated to `"p"` | ✅ **G1-ONLY, proven 2026-08-23.** The same spec through `run-eval` (G3) returns the **full** topic name and passes. The defect belongs to the Testing Center evaluation service, not the platform. Route assertions are usable on G3. |
| Quality judges fail a correct refusal | ✅ **G1-ONLY, proven 2026-08-23.** G3 translates the case to the reference-based `bot_response_rating` and scored the pancake refusal **5 / PASS** against the spec’s own `expectedOutcome`. No suite-splitting needed — the runner does it. |
| Standard Knowledge action steals the turn | 🔴 **Real behaviour, cheap fix.** Remove standard actions from the topic. In Agent Script the model can only reach what the `.agent` file declares. |
| One turn → one subagent | 🟢 **Refuted.** `@subagent.<name>` is call-and-return; `@utils.transition` is one-way; `before_reasoning` pins deterministic actions before the model reasons. The hero demo is back. |
| Credits unmeasurable in DE | 🟡 **Wallet is a wall; measurement is not.** Derive it: token count from the local transcript × published rate card (`roundup(token/2000) × 10` for Standard). Label `[Derived]`, print the formula. |
| Escalation Gap always green | 🟢 **Wrong wall.** Salesforce documents the natural gap: *"Without additional configuration, the customer has access to all of the records that the agent user has access to."* Service agents run as **EinsteinServiceAgent User**. No planted violation needed. |
| `factuality` anti-correlated | 🟢 **Our analysis holds** — and it is NGT-runner only, so the experiment runs on G2. Pair it with `response_match` (`needsExpected: true`) for a matched design. |
| Formula cannot aggregate children | 🔴 **Real, pattern is sound.** Child formula checkbox → filtered roll-up COUNT/MAX. **Trap: roll-up criteria may not reference `TODAY()`/`NOW()`** — so expiry logic stays in the parent formula or in Apex, never in the criteria field. |
| Eichfrist needs more than a formula | 🔴 **Real.** Four start branches, not one. See below. |
| CMDT not insertable by DML | ✅ **Built, 2026-08-23.** 16 Normen deployed. Build-time artifact = every legal change is a git diff. **And a masked error bit again:** record deploys failed with a bare `UNKNOWN_EXCEPTION` through source *and* mdapi, three API versions, even a throwaway type — because the generator emitted `xsi:type="xsd:string"` while declaring only two namespaces. **`xmlns:xsd` was missing.** Isolated by deploying a record with no `<values>` at all, which succeeded. Third time an input error wore a platform limit's clothes. |
| `escapeHtml4` corrupts German | 🟢 **Our analysis correct.** `@InvocableVariable` serialisation already escapes. Add `GermanTextSerializationTest` and stop. |
| Statistical 5/5 gate | 🔴 **Real, and the two-tier design is the answer.** |
| Data Library has no metadata type | 🔴 **Real.** Deferred to v1.1, correctly. |
| Trust Layer as deployable metadata | 🔴 **Real and it kills a claim.** `EinsteinGptSettings` has **thirteen** fields (verified by retrieve 2026-08-23 — an earlier count of nine was wrong), **none of them Trust Layer.** Masking, audit trail and retention are configuration, not source. Do not claim "Trust Layer as code." |
| `isConfirmationRequired` under test | ❓ **Still unknown.** Unchanged — no client-side confirm logic exists. A 30-minute empirical probe remains a publishable finding. |

---

## ⚖️ The domain — what must be right

Full detail in `docs/DOMAIN_VERIFICATION.md`. The six facts that carry the project:

1. **12 kVA je elektrischer Anlage** (NAV § 19 Abs. 2), not 11 kW. And **there is no
   Genehmigungsfiktion** — two months binds the operator to answer, silence is not consent.
2. **The Eichfrist start lives in § 34 Abs. 1 MessEV, which has _four sentences_** — and
   Satz 4 is **relief from Satz 3**, not a fourth independent branch:
   *S. 1* default is **two years**, so the eight is Anlage 7 Nr. 6.7, a table entry ·
   *S. 2* `Tag der Eichung`, unless § 37 Abs. 1 S. 2 MessEG gives `Inverkehrbringen` ·
   *S. 3* calibrated **after** expiry → the new period starts at the **old period's end**,
   a backdating penalty · *S. 4* the only escape: **`nachweislich`** unused > 1 year → back to
   the calibration day. Then § 34 Abs. 2 pushes the end to **31 December** of that year.
   **Defaulting to S. 4 is wrong in the dangerous direction** — measured: the formula returns
   2032-12-31 where the statute says 2031-12-31. Hence `Stilllegung_nachgewiesen__c`.
3. **§ 14a EnWG excludes publicly accessible charge points** — in the statute's own words. The
   4.2 kW is BK6-22-300 only, and it is a **dimming floor**, not a shutdown — but a
   relay-only wallbox is lawfully taken to **zero** and cannot claim the hardship exemption.
4. **The Ladesäulenverordnung was repealed on 1 January 2026.** The new one has six
   paragraphs and **no payment rules** — AFIR applies directly. Anyone citing "LSV § 4
   requires card payment" is quoting a repealed provision. **This is the factuality
   experiment's core evidence.**
5. **`Oeffentlich_zugaenglich__c` is a transition, not an attribute.** LSV § 4 last sentence:
   the notification duties apply afresh when an existing point becomes public. Flipping it
   activates LSV notification, Eichrecht, AFIR and THG eligibility — while § 14a
   **deactivates**. And § 6 forwards the registration data **monthly to the Eichbehörden**.
6. **§ 6 Abs. 4 der 38. BImSchV** is the bridge: THG revenue requires the point to be
   publicly accessible, carry an AFIR EVSE-ID, and be **published** by the BNetzA — not
   merely notified. Deadline **28 February**, preclusive.

**And a live commercial deadline:** the **GEIG amendment takes effect 1 January 2027** —
every charge point *erected or replaced* must support intelligent charging, and empty
conduit no longer counts as pre-cabling. Part of the product catalogue becomes unsellable.

---

## 📊 What the market research changed

`docs/MARKET_REALITY.md` in full. The three findings that matter:

- **The binding constraint is German at negotiation level**, not the portfolio. 13 of 13
  consulting-partner postings require it.
- **Deep German regulatory knowledge is invisible at the screening stage.** Zero postings
  pair Salesforce with EnWG/MsbG/Eichrecht. Even Eigenherd — an energy-*only* Salesforce
  partner — does not ask for it. Where it *is* demanded, the platform is SAP or Kraken.
- **Therefore: stop growing the domain work, start translating it.** The law lives in
  table-driven tests, not in the README. *A Salesforce engineer who cannot judge MessEV can
  judge `EichrechtServiceTest`, and sees both craft and domain in one file.*

**Two employers the data surfaced:** **Eigenherd GmbH** (Berlin — Salesforce + MuleSoft for
utilities, currently hiring an Architect, teaches domain in-house) and **JobRad** (Freiburg —
the only technical Salesforce posting in Germany accepting **B2 German**).

---

## ✅ Decisions taken (do not re-litigate)

| | Decision |
|---|---|
| **Identity** | Rules engine leads; Agentforce is its interface. Nothing is cut, the order changed. |
| **Orchestration** | **Cancelled.** One agent, 3–4 subagents inside it, decomposed by **verb** (`Briefing` · `Fristen` · `Pruefung` · `Aktion`), not by legal regime. |
| **Grounding** | `Rechtsnorm__mdt`, generated from official XML, **cited by key**. Not vector similarity. Add `Gueltig_von__c` / `Gueltig_bis__c` — the corpus is **bitemporal**. |
| **Gate** | Two tiers. Deterministic Apex = **100 %, zero tolerance**. Routing (`actions_assertion`) = a stated error budget. LLM-judged scores = **reported, never gated**. |
| **Escalation Gap** | Measure the **natural** service-agent gap Salesforce documents. Keep a planted violation only as a **CI mutation test** of the analyser itself. |
| **Groundedness** | A **deterministic transcript gate**: every `§` the agent cites must appear in the `rechtsgrundlage` returned by an action that ran in that turn. No LLM. Platform scorer is a bonus, not a dependency. |
| **Personal** | "relocating to Germany" · authorship line stays · `Audience: technical reviewers` |
| **`Partner_Tier__c`** | Bronze/Silber/Gold/Platin is **invented** — twelve German vendors publish no ranked ladder. Replace with certification status + **expiry** + partner type + points. |
| **Evidence labels** | `[M]` measured · `[D]` documented · `[I]` inferred · `[?]` unknown. **Never `[V]` again** — thirteen of those turned out wrong. |

---

## ▶️ NEXT ACTION

**The six probes are finished — 2026-08-23. Results in `docs/PROBE_PLAN.md`.**

Five of eighteen walls came down, and three of those turned out to be the *old test runner*
rather than the platform. The score:

| | |
|---|---|
| **Probe 1** — `sf update` | ✅ CLI was 179 days stale. Registry wall died with it. |
| **Probe 2** — fresh org | ❌ **Cancelled.** The org is already a Feb-2026 Agentforce DE. |
| **Probe 3** — Agent Script publish | ✅ **PUBLISHED.** The `default_agent_user` was an admin; the error came back masked. |
| **Probe 4** — Session Tracing | 🟡 NPE gone, schema narrowed to one unknown, blocked on Setup. |
| **Probe 5** — G3 `run-eval` | ✅ Two more walls were G1-only. And cosine similarity was measured unfit. |
| **Probe 6** — two contradictions | ✅ Field count corrected; the activation flag does not activate. |

**Stop probing. Build the vertical slice.**

```
Ladepunkt__c  +  Eingriff__c        ✅ DEPLOYED 2026-08-23 — 15 PASS · 1 DEFERRED · 0 FAIL
      ↓
DateUtils                           ✅ DEPLOYED 2026-08-23 — 5 tests, 20/20 coverage
      ↓
Rechtsnorm__mdt                     ✅ DEPLOYED 2026-08-23 — 16 Normen, 9 tests green
      ↓
EichrechtService  +  DecisionResult ✅ DEPLOYED 2026-08-23 — 138 local tests green, 100 % cov
      ↓
Konsistenztest Formel ↔ Apex        ✅ DEPLOYED 2026-08-23 — 142 local tests green
      ↓
LWC-Karte (eichrechtCard)           ✅ DEPLOYED 2026-08-23 — 149 local tests green
      ↓
Agent-Action (PruefeEichfristen)     ✅ DEPLOYED 2026-08-23 — 162 local tests green
      ↓
Agent Script (VS_Eichrecht)          ✅ PUBLISHED + AKTIV 2026-08-23 — Smoke 3/3 PASS
      ↓
Transkript-Gate  +  CI               ◀ NEXT
```

One object, end to end. If a platform blocker exists it surfaces there — early, and on one
object instead of six. Partner and Netzanschluss then follow the same template with no new
architectural risk.

### Step 1 is done, and it produced a finding

21 fields on `Ladepunkt__c`, 13 on `Eingriff__c` (master-detail), permission set
`VoltStream_Eichrecht_Access`. Four roll-ups and five formulas, so **legal status is a column in
a list view** — no agent, no CI run, which is the whole thesis.

Verified against **real DML in the live org**, not asserted in a unit test —
`scripts/apex/seedEichrechtMatrix.apex` → `verifyEichrechtMatrix.apex`, sixteen cases:

> **15 PASS · 1 GELÖST · 0 FAIL** — and the matrix now prints **three** expiry columns:
> what the formula produces, what § 34 MessEV requires, and what `EichrechtService` computes.
> **The engine column equals the statute column in every row**, case `E` included.

Case `E` was `DEFERRED` until step 4 existed. **A green 16/16 on two columns would have meant the
test was asserting the formula against itself** — which is what it was doing, until the statute
was re-read.

That re-read is the finding: **§ 34 Abs. 1 has four sentences and this project had read two.**
Satz 3 backdates a late Nacheichung to the old period's end; Satz 4 is the only escape and
demands `nachweislich`. The declarative layer silently took the favourable branch. Corrected in
`docs/DOMAIN_VERIFICATION.md`, and the escape now needs an evidenced checkbox
(`Eingriff__c.Stilllegung_nachgewiesen__c`) that **defaults to the harsher answer**.

**Two things the probes changed about how to build it:**

1. **The agent is authored in Agent Script and deployed from it.** `before_reasoning` pins the
   regulatory checks as deterministic steps before the model reasons; `available when` gates the
   write action on a `BLOCKIERT` section. The flow is written down, not left to the planner.
2. **Groundedness is a deterministic transcript gate, not a scorer.** Every `§` the agent cites
   must appear in the `rechtsgrundlage` an action returned that turn. Probe 5 measured why:
   similarity cannot separate a correct German legal sentence from a false one.

### Steps 2–4 are done. Three things they settled

1. **`DateUtils`** — the four § 34 Abs. 1 sentences as pure date arithmetic, table-driven test.
2. **`Rechtsnorm__mdt`** — **16 Normen**, `Wortlaut__c` verbatim or empty, repealed law kept with
   `Gueltig_bis__c` + a successor key. `DateUtilsTest` now asserts its constants **against the
   corpus**, so the number and the sentence that sets it cannot drift.
3. **`EichrechtService` + `DecisionResult`** — the chronology walk. **Case E is answered**: the
   engine returns 2031-12-31 where the formula returns 2032-12-31. The formula stays; where they
   differ the service is the authority.

**`rechtsgrundlagen` is live.** Every answer cites only the branches that fired — a device inside
its period does **not** cite § 38, and a test asserts that it does not. That list is what the
transcript gate reads.

**`NICHT_ANWENDBAR` has a real statutory home:** `pruefeVerspaeteteEichung` returns it for a device
whose Eichfrist still runs, because § 38 governs *verspätete* Eichungen and says nothing about a
running period. Not the same as `UNBEKANNT`, and neither is "not protected".

**Step 5 turned the claim into a check.** `EichrechtKonsistenzTest` holds both layers against
each other on twelve fact patterns — ten must agree, two are **named** divergences. The second of
those is the argument for the whole engine in one assertion:

> the list view reports a charge point as **GÜLTIG** that the ordinance says has been
> **ABGELAUFEN** since last year.

Two guards keep the exemption list honest: a named divergence must **still diverge** (so repairing
the formula fails the suite instead of leaving a stale excuse), and every string the formula emits
must map onto the enum (so changing the formula text without the mapping is caught).
**All fixtures are relative to `Date.today()`** — the formula runs on `TODAY()`, and fixed dates
would rot the suite on a calendar boundary.

**Step 6 made it visible.** `eichrechtCard` on the `Ladepunkt_Eichrecht` record page: verdict,
German reasoning, both dates, and **every cited provision expandable to its verbatim wording plus
a link to gesetze-im-internet.de**. That is what turns a status badge into evidence.

⚠️ **One Setup click is outstanding** — the FlexiPage is deployed but Lightning record-page
*activation* has no metadata representation. Setup → Object Manager → Ladepunkt → Lightning Record
Pages → `Ladepunkt Eichrecht` → **Activate**.

**Step 7 put the architecture in a file instead of a claim.** `PruefeEichfristen` resolves which
charge points a question is about, hands them to the engine, and returns its German sentences
**unchanged**. It computes no deadline and could not — no date arithmetic exists on that side.

Three properties the agent depends on, each a test:
- a point **inside** its period does **not** hand over § 38 — otherwise the gate would wave
  through a citation about a device the norm says nothing about;
- an unknown charge point returns a **refusal plus an instruction not to name a status**, because
  silence is the easiest thing for a compliance assistant to report as compliance;
- a missing date counts as **Handlungsbedarf**, not as quiet.

**`GermanTextSerializationTest` is the escaping rule with teeth** — and one of its tests
*demonstrates* the damage rather than forbidding it, because a rule nobody can see the reason for
is a rule somebody will delete. It then justified a change it was not written for: the engine's
German had been transliterated (`laeuft`, `unberuehrt`) out of caution the measurements disprove.
**The output now reads as German** — which is the point, since the target is German at negotiation
level and that has to be true of what the agent says, not only of the README.

### Step 8 — the agent, and the failure that argued for step 9

`VS_Eichrecht` is authored in Agent Script, deployed from the file, published and **active**.
Smoke suite **3/3 PASS**, every case 5/5.

**It failed first, and the failure is the finding.** The script compiled, published and answered in
fluent German — with the wrong answers. Asked the same question twice it said *"ohne bestimmbaren
Status"* once and *"für den Betrieb gesperrt"* the next; the truth was *"abgelaufen"*. Both wrong
answers were **phrases lifted from my own instructions**. The action had never run.

Cause: the action block named `target:` but declared **no `inputs:` and no `outputs:`**, so the
tool reached the model with nothing to call. With them declared, the agent now returns the engine's
sentence word for word and cites exactly what was handed over:

> *"Die Eichfrist ist am 31.12.2023 abgelaufen und eine erneute Eichung wurde nicht beantragt."*
> Rechtsgrundlagen: `MessEV Anlage 7 Tabelle 1 Nr. 6.7; § 34 Abs. 2 MessEV; § 37 Abs. 1 Satz 2 MessEG`

**This is the argument for the transcript gate, made accidentally and early.** An agent that sounds
right in a language the reviewer may not read is exactly the risk — and it took *two runs of the
same question* to notice. The gate would have caught it in one.

**The standing rule:** the next thing committed should be deployed metadata, not another document.

---

## Things to skip / not do

- **Don't run `find`, `grep`, `cat`, `head`, `tail` in PowerShell.** Use
  Glob / Grep / Read tools instead.
- **Don't deploy all of `force-app`** when a narrow folder will do — it's
  slower and pollutes the deploy report.
- **Don't add a `<!-- TODO -->` or `// removed X` breadcrumb** for things
  you actually removed. Delete cleanly.
- **Don't add comments that restate the code.** Comments only earn their
  place when they explain *why* the obvious-looking thing exists.
- **Don't bypass the four-layer separation** "just for this small change."
  Every shortcut becomes the next person's "this used to be a rule."
- **Don't introduce mocks for SOQL.** Use real DML in tests — that's the
  whole reason the Selector pattern exists; it stays testable through DML.
- **Don't put `TODAY()` or `NOW()` in a roll-up summary filter criterion**, or in
  a formula the criterion references. The platform rejects it. Expiry comparison
  belongs in the parent formula or in Apex.
- **Don't use `String.escapeHtml4()` on anything the planner reads.** It turns
  `ü` into `&uuml;` and destroys German output. Invocable serialisation already escapes.
- **Don't assert on `topic_assertion`.** It truncates custom topic names to a single
  character, 5 runs out of 5. Assert on actions.
- **Don't put `coherence` / `completeness` / `conciseness` in a suite containing
  refusals.** They score a correct refusal as incoherent, by design.
- **Don't claim "Trust Layer as code."** `EinsteinGptSettings` has no Trust Layer fields.
- **Don't emit a `CustomMetadata` record without all three namespaces.** `xmlns`,
  `xmlns:xsd` **and** `xmlns:xsi`. Every `<value>` carries `xsi:type="xsd:..."`, and an
  undeclared `xsd` prefix comes back as a masked `UNKNOWN_EXCEPTION` naming nothing.
- **Don't paraphrase into `Rechtsnorm__mdt.Wortlaut__c`.** Official text or empty. It is
  what the agent narrates from; a paraphrase there defeats the grounding design.
- **Apex identifiers are case-insensitive — a name shadows any class or enum spelled the same
  in any casing.** A field `ergebnis` hid the enum `Ergebnis`; a local `json` hid the `JSON`
  class. Both surfaced as baffling "method does not exist" errors.
- **Identifiers cannot carry umlauts, strings must.** A blunt search-and-replace restoring
  German broke `Behoerde_informiert__c` and `pruefeVerspaeteteEichung`. Audit with
  `scratchpad/umlautaudit.py` — it strips strings and comments and reports what is left.
- **Don't build German text with `Date.format()`.** It follows the running user's locale, so
  `23.08.2026` becomes `8/23/2026` for an English-locale user — inside a sentence the agent
  narrates. Use `DateUtils.deutsch()`.
- **Never write an `.agent` file with PowerShell `Set-Content -Encoding UTF8`.** It prepends a
  BOM, and a BOM makes the compile service reject the file with a bare `422`. Use Python.
- **An Agent Script action needs `inputs:` and `outputs:` declared.** Without them the script
  still compiles, publishes and answers — from the prompt instead of from the action.
- **`default_locale` takes a language code**: `de`, not `de_DE`.
- **Action `outputs:` are scalars.** `list<string>` is rejected; join lists into text.
- **Don't write `[V]`.** Use `[M]` / `[D]` / `[I]` / `[?]`.
- **Don't say credits are unlimited.** Say: no failure observed across N runs; consumption
  unknown because Digital Wallet is absent in this edition.
- **Don't start more research.** It is finished. The next artifact is deployed metadata.
