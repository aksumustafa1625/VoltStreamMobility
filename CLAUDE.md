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

## Project state (what's built, what's not)

**Phase 1 — Channel Partner Auto-Linking — COMPLETE.**
Reseller__c object, Opportunity custom fields, Apex trigger family with
four-layer separation, `ResellerSelector`, `StringUtils`,
`TestDataFactory`, permission set, list views, demo seed script. 100%
coverage, all tests green.

**Phase 2 — Document Manager LWC — COMPLETE.**
`Document__c` object with Chatter feeds enabled. `documentManager` LWC
with folder cards, upload modal, share-to-Chatter (ContentPost with file
attachment + auto-navigate to record after share), recent activity
strip. `DocumentController` + `DocumentSelector`. Inline-SVG folder
icons (one per category color).

**Roadmap (not started):** Reseller Tier picklist + commission rollup,
reports / dashboards, batch Apex for partner-master sync, "My Channel
Pipeline" LWC tile. See README for the full list.

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
