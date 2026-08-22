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
| Agent Script publish `404` | 🟡 **Probably not a wall.** Three likely causes: CLI six months stale (2.135.7 release note fixes exactly this 404), `default_agent_user` given an admin instead of an Einstein-Agent-licensed user (Salesforce's own known-issues says the error returns **masked**), or the org being a pre-2025 classic DE with no Agentforce/Data Cloud provisioning. **Probe 3.** |
| Scorer template server NPE | 🟡 **Provisioning, not schema.** Org has **zero `ssot__*` objects** — Data Cloud is not provisioned, so `agentforce_session_tracing` types have no backing definition. Session Tracing needs Enterprise+; Developer Edition is not listed. **Probe 2 + 4.** |
| `AiAgentScorerDefinition` not in CLI registry | 🟢 **Not a wall.** Added to SDR in April 2026. `sf update` deletes it. **Probe 1.** |
| `topic_assertion` truncated to `"p"` | 🔴 **Real, server-side.** Two independent source reads confirm the CLI passes values verbatim. **Nobody has reported this — we would be first.** Route on `actions_assertion` instead. |
| Quality judges fail a correct refusal | 🔴 **Real but not a bug.** `coherence`/`completeness`/`conciseness`/`factuality` are all `needsExpected: false` — reference-free. Use `bot_response_rating` (`output_validation`, `needsExpected: true`) with an expected refusal, and omit `metrics:` on refusal cases. Per-case opt-in is the spec's design, not a hack. |
| Standard Knowledge action steals the turn | 🔴 **Real behaviour, cheap fix.** Remove standard actions from the topic. In Agent Script the model can only reach what the `.agent` file declares. |
| One turn → one subagent | 🟢 **Refuted.** `@subagent.<name>` is call-and-return; `@utils.transition` is one-way; `before_reasoning` pins deterministic actions before the model reasons. The hero demo is back. |
| Credits unmeasurable in DE | 🟡 **Wallet is a wall; measurement is not.** Derive it: token count from the local transcript × published rate card (`roundup(token/2000) × 10` for Standard). Label `[Derived]`, print the formula. |
| Escalation Gap always green | 🟢 **Wrong wall.** Salesforce documents the natural gap: *"Without additional configuration, the customer has access to all of the records that the agent user has access to."* Service agents run as **EinsteinServiceAgent User**. No planted violation needed. |
| `factuality` anti-correlated | 🟢 **Our analysis holds** — and it is NGT-runner only, so the experiment runs on G2. Pair it with `response_match` (`needsExpected: true`) for a matched design. |
| Formula cannot aggregate children | 🔴 **Real, pattern is sound.** Child formula checkbox → filtered roll-up COUNT/MAX. **Trap: roll-up criteria may not reference `TODAY()`/`NOW()`** — so expiry logic stays in the parent formula or in Apex, never in the criteria field. |
| Eichfrist needs more than a formula | 🔴 **Real.** Four start branches, not one. See below. |
| CMDT not insertable by DML | 🔴 **Real and fine.** `Rechtsnorm__mdt` is a build-time artifact — which means the statute corpus is version-controlled and every legal change shows in a git diff. Frame it as a feature. |
| `escapeHtml4` corrupts German | 🟢 **Our analysis correct.** `@InvocableVariable` serialisation already escapes. Add `GermanTextSerializationTest` and stop. |
| Statistical 5/5 gate | 🔴 **Real, and the two-tier design is the answer.** |
| Data Library has no metadata type | 🔴 **Real.** Deferred to v1.1, correctly. |
| Trust Layer as deployable metadata | 🔴 **Real and it kills a claim.** `EinsteinGptSettings` has nine fields, **none of them Trust Layer.** Masking, audit trail and retention are configuration, not source. Do not claim "Trust Layer as code." |
| `isConfirmationRequired` under test | ❓ **Genuinely unknown.** No client-side confirm logic exists in the CLI source. A 30-minute empirical probe would be a publishable finding. |

---

## ⚖️ The domain — what must be right

Full detail in `docs/DOMAIN_VERIFICATION.md`. The six facts that carry the project:

1. **12 kVA je elektrischer Anlage** (NAV § 19 Abs. 2), not 11 kW. And **there is no
   Genehmigungsfiktion** — two months binds the operator to answer, silence is not consent.
2. **The Eichfrist has four start branches**, not one:
   `Inverkehrbringen` · `Tag der Eichung` · **`Nacheichung_nach_Ablauf`** (calibrated after
   expiry → the new period starts at the **old period's end**, a backdating penalty) ·
   **`Nacheichung_nach_Stilllegung`** (unused >1 year → starts at the calibration day).
   Then § 34 Abs. 2 MessEV pushes the end to **31 December** of that year.
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

**`docs/PROBE_PLAN.md` — six probes, about two hours.** They decide whether Days 5–6 are
Agent Script or legacy XML, whether the groundedness claim needs the platform at all, and
whether a fresh org removes two walls at once.

After the probes: a **vertical slice** — `Ladepunkt__c` + `Eingriff__c` + `EichrechtService`
+ `Rechtsnorm__mdt` + one LWC card + one agent action + one eval case, end to end. Then
Partner and Netzanschluss follow the same template.

**A standing warning, from the ninth reviewer and it is correct:**

> *"The ninth revision of the documents proves less than the engine's first deploy."*

8,000 lines of documentation exist. Zero new objects are deployed. **Build now.**

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
- **Don't write `[V]`.** Use `[M]` / `[D]` / `[I]` / `[?]`.
- **Don't say credits are unlimited.** Say: no failure observed across N runs; consumption
  unknown because Digital Wallet is absent in this edition.
- **Don't start more research.** It is finished. The next artifact is deployed metadata.
