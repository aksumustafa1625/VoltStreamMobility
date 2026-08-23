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

**Result:** _______________

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

**Result:** _______________

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

**Result:** _______________

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

**Result:** _______________

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

**Result:** _______________

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
