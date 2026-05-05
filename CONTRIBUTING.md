# Contributing to VoltStream Mobility

This is primarily a portfolio project, but it follows the same conventions a
small Salesforce team would. If you're cloning to learn from the codebase, or
extending it, the rules below keep the repo consistent.

## Setup

You need:
- [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli) (`sf` v2.x)
- A Salesforce org (Developer Edition or Trailhead Playground are fine)
- Node.js 20+ if you want to run the Jest LWC tests (none ship today)

```bash
git clone https://github.com/aksumustafa1625/VoltStreamMobility.git
cd VoltStreamMobility
sf org login web --alias VoltStreamDev --set-default
sf project deploy start --source-dir force-app --test-level RunLocalTests
sf org assign permset --name VoltStream_Reseller_Access
sf apex run --file scripts/apex/seedData.apex
```

## Standing rules

These are the rules every change in this repo must follow. They live in `memory/`
as `feedback_*.md` notes (project memory for AI-assisted development), but the
short version is below.

### Apex architecture

- **Trigger framework:** Every Apex trigger extends Kevin O'Hara's
  `TriggerHandler` (`force-app/main/default/classes/TriggerHandler.cls`).
  Trigger files are 3 lines; logic lives in a Handler/Helper pair.
- **Four-layer separation:**
  `Trigger` (route) → `Handler` (dispatch) → `Helper` (algorithm) → `Selector` (SOQL)
  Helpers and Handlers never write inline SOQL — call `<SObject>Selector` instead.
- **String normalization:** Email lowercasing, phone formatting, and whitespace
  cleanup go through `StringUtils`. Never inline `.toLowerCase()` or `.trim()`.
- **Test data:** Build records via `TestDataFactory` so schema changes ripple
  through one file, not every test class.

### Documentation

Every custom class and trigger we author starts with an ApexDoc header:

```apex
/**
 * @description  What this class does and why.
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         YYYY-MM-DD
 */
```

Every public method gets `@description`, `@param`, and `@return` blocks. Every
private method gets at least a one-line `// what this does` comment above it.

Vendored third-party files (currently `TriggerHandler.cls` and
`TriggerHandler_Test.cls`) are NOT touched — the README and LICENSE credit
the upstream author.

### Testing

- Every class ships with a dedicated `<ClassName>Test.cls`. Coverage target: 100%
  on the class, not just 75%.
- Helper / Selector / utility classes get **unit tests** that exercise the static
  methods directly without DML on the Opportunity.
- Trigger / Handler classes get **integration tests** that go through DML so the
  trigger actually fires.
- Assertions include a descriptive message: `System.assertEquals(expected, actual, 'why')`.

### Commits

- **Atomic** — one logical change per commit. Five fields = five commits if the
  fields are independent; one commit if it's "add five fields to the new object".
- **Conventional Commits** prefixes:
  `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`, `perf:`, `style:`.
- **Multi-line message body** explains the *why* and any non-obvious tradeoffs.

### Code style

- Apex API version: 65.0.
- `with sharing` on every class that does DML or SOQL.
- `WITH USER_MODE` on SOQL when running in user context (Selector-level FLS).
- Line endings are LF (enforced via `.gitattributes`).

## Continuous integration

GitHub Actions runs PMD static analysis on every push and pull request to `main`.
A scratch-org deploy + test job runs when the `SFDX_AUTH_URL` repository secret
is set (see [.github/workflows/ci.yml](.github/workflows/ci.yml) for the
authoring details).

To enable scratch-org CI:

1. Authorize a DevHub locally: `sf org login web --set-default-dev-hub`
2. Generate an SFDX auth URL: `sf org display --target-org <DevHub> --verbose --json`
   and copy the `sfdxAuthUrl` value.
3. Add it as a repository secret named `SFDX_AUTH_URL` under
   Settings → Secrets and variables → Actions.

## Validation deploy

Before merging anything to `main`, validate the change against the org without
actually committing it:

```bash
sf project deploy validate --source-dir force-app --test-level RunLocalTests
```

The `validate` flag runs the deployment and tests inside a transaction that is
rolled back at the end, so the org is unchanged regardless of the result.

## Pull request checklist

Even on solo work, these should be true at merge time:

- [ ] All tests pass (`sf apex run test --test-level RunLocalTests`)
- [ ] Coverage stays at 100% on every custom class
- [ ] PMD lint produces no new violations
- [ ] Any new class has its `*Test.cls` companion in the same PR
- [ ] Any new SOQL is in a Selector class, not inline
- [ ] ApexDoc headers are in place on new classes/methods
- [ ] README is updated if the public surface changed
