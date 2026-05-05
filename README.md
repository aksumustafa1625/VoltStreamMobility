# VoltStream Mobility — Salesforce CRM

> A Salesforce DX portfolio project that models a B2B EV charging infrastructure supplier in Germany. Sales reps enter a single field on an Opportunity, an Apex trigger built on the **Kevin O'Hara `sfdc-trigger-framework`** auto-links the deal to the right channel partner, and reports surface revenue per reseller.

[![Trigger framework](https://img.shields.io/badge/trigger--framework-Kevin%20O%27Hara-blue)](https://github.com/kevinohara80/sfdc-trigger-framework)
[![API version](https://img.shields.io/badge/API-65.0-orange)]()
[![Test coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)]()
[![Tests](https://img.shields.io/badge/tests-24%2F24%20passing-brightgreen)]()

---

## Why this project

The German Salesforce market is hiring aggressively in **e-mobility and automotive** (EnBW mobility+, Ionity, Allego, Mercedes-Benz Mobility). This project demonstrates the exact skill mix those job posts ask for: a real custom-object + trigger + test + dashboard scenario, built with industry-standard patterns rather than the inline "logic-in-the-trigger" style typical of beginner work.

---

## Business scenario

VoltStream Mobility GmbH (fictional) is a B2B supplier of EV charging hardware and software. They sell **through a channel-partner network**, not direct to consumers:

| Reseller type | Example |
|---|---|
| Electrical Contractor | Berlin Elektrotechnik GmbH |
| Auto Dealer | Mercedes-Benz Berlin Mitte |
| Hotel Chain | Steigenberger Hotels |
| Mall | MediaMarkt Deutschland |
| Parking Operator | APCOA Parking Deutschland |
| Energy Company | Stadtwerke München |

**Pain point:** When a sales rep creates a new Opportunity, they need to attribute it to the reseller that sourced the deal. Manual lookup is slow and error-prone.

**Solution:** The rep types the reseller's company email into one field. An Apex trigger looks up the matching `Reseller__c` (case-insensitive, only active resellers) and auto-populates the Reseller lookup. Reports aggregate revenue per reseller so leadership can see which partners drive the channel.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Opportunity (standard)                      │
│  ┌──────────────────────────┐    ┌──────────────────────────┐   │
│  │ Reseller_Email__c        │    │ Reseller__c (lookup)     │   │
│  │ (sales rep types email)  │    │ (auto-populated)         │   │
│  └────────────┬─────────────┘    └─────────▲────────────────┘   │
│               │                            │                    │
└───────────────┼────────────────────────────┼────────────────────┘
                │                            │
                │  insert / update           │  matched Id
                ▼                            │
┌─────────────────────────────────────────────────────────────────┐
│   OpportunityTrigger (1 line)                                   │
│      new OpportunityTriggerHandler().run();                     │
└────────────────────────────┬────────────────────────────────────┘
                             │ delegates via dispatch
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│   OpportunityTriggerHandler extends TriggerHandler              │
│   - beforeInsert():  bulk-match emails to Reseller__c           │
│   - beforeUpdate():  re-match only when email changed           │
└────────────────────────────┬────────────────────────────────────┘
                             │ extends
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│   TriggerHandler (Kevin O'Hara framework)                       │
│   - context dispatch, recursion control, bypass API             │
└─────────────────────────────────────────────────────────────────┘
```

The trigger runs **one bulkified SOQL** per batch (handles 200-record inserts within governor limits) and fails safely — if no reseller matches, the lookup stays null instead of blocking the save.

---

## What's in the project

### Custom object: `Reseller__c`

| Field | Type | Notes |
|---|---|---|
| `Name` | Text | Labelled "Company Name" |
| `Company_Email__c` | Email, required, unique | Matching key for the trigger |
| `Reseller_Type__c` | Picklist (6 values) | Drives report grouping |
| `Country__c` | Text, default "Germany" | |
| `Phone__c` | Phone | |
| `Active__c` | Checkbox, default true | Inactive resellers are excluded from matching |

### Opportunity custom fields

| Field | Type | Notes |
|---|---|---|
| `Reseller_Email__c` | Email | Sales rep input |
| `Reseller__c` | Lookup → `Reseller__c` | Read-only via permission set; trigger owns writes. Delete constraint = SetNull (Opportunity survives reseller deletion) |

### Apex

| Class | Purpose | Coverage |
|---|---|---|
| `TriggerHandler` | Kevin O'Hara framework base class (verbatim copy) | 100% |
| `TriggerHandler_Test` | Kevin O'Hara framework test class | — |
| `OpportunityTrigger` | One-line trigger, delegates to handler | 100% |
| `OpportunityTriggerHandler` | Channel-partner matching logic, bulkified, case-insensitive | 100% |
| `OpportunityTriggerHandlerTest` | 10 test methods covering every branch + bulk + bypass | — |

### UI

- `Reseller` tab (Custom20: Plug motif, fits the EV theme)
- `Reseller Layout` page layout (two sections: Reseller Information + System Information)
- `Channel Partner` section added to the standard Opportunity Layout
- `All Resellers` and `Active Resellers` list views

### Permissions

- `VoltStream Reseller Access` permission set — grants CRUD on `Reseller__c`, FLS on every custom field, and read-only access to `Opportunity.Reseller__c` (the trigger owns it)

### Scripts

- `scripts/apex/seedData.apex` — idempotent demo data loader (6 resellers + 10 opportunities covering match / no-match / inactive / case-insensitive / direct-deal scenarios)

### Manifests

- `manifest/package.xml` and `manifest/destructiveChanges.xml` — preserved from the original org cleanup so the deployment is reproducible

---

## Repository structure

```
force-app/main/default/
├── classes/                  Apex classes + tests
│   ├── TriggerHandler.cls
│   ├── TriggerHandler_Test.cls
│   ├── OpportunityTriggerHandler.cls
│   └── OpportunityTriggerHandlerTest.cls
├── triggers/
│   └── OpportunityTrigger.trigger
├── objects/
│   ├── Reseller__c/          Custom object + fields + list views
│   └── Opportunity/fields/   Custom fields on the standard object
├── layouts/
│   ├── Reseller__c-Reseller Layout.layout-meta.xml
│   └── Opportunity-Opportunity Layout.layout-meta.xml
├── tabs/
│   └── Reseller__c.tab-meta.xml
└── permissionsets/
    └── VoltStream_Reseller_Access.permissionset-meta.xml

scripts/apex/seedData.apex    Idempotent demo data loader
manifest/                     package.xml + destructiveChanges.xml
```

---

## Setup

### Prerequisites

- [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli) (`sf` v2.x)
- A Developer Edition org or Trailhead Playground

### Step 1 — Authorize the target org

```bash
sf org login web --alias VoltStreamDev --set-default
```

### Step 2 — Deploy all metadata + run all tests

```bash
sf project deploy start --source-dir force-app --test-level RunLocalTests
```

Expected result: 15 components deployed, 24 tests passing, 100% coverage on custom Apex.

### Step 3 — Assign the permission set to your user

```bash
sf org assign permset --name VoltStream_Reseller_Access
```

This is required — without it, custom fields are invisible to the running user (Salesforce field-level security).

### Step 4 — Seed demo data

```bash
sf apex run --file scripts/apex/seedData.apex
```

Creates 6 resellers and 10 opportunities; the trigger fires automatically. The script is idempotent — safe to re-run any time.

### Step 5 — Open the org and explore

```bash
sf org open
```

Navigate: **App Launcher → Sales → Resellers** (switch the list view from "Recently Viewed" to "All Resellers"). Open any reseller to see its related Opportunities, populated by the trigger.

---

## Testing

Run the Apex test suite locally with code coverage:

```bash
sf apex run test --test-level RunLocalTests --code-coverage --result-format human --synchronous
```

Expected: **24 tests pass, 100% coverage on custom code, 0 failures.**

The `OpportunityTriggerHandlerTest` covers every branch of the matching logic:

- Email match (lowercase) → lookup populated
- Case-insensitive match (`PARTNER@X.DE` matches `partner@x.de`)
- Inactive reseller (`Active__c = false`) → no match
- Unknown email → silent null (never blocks save)
- Null email → skipped cleanly
- Bulk insert of 200 records → proves bulkification (would hit 100-SOQL governor limit if not bulkified)
- Update with changed email → re-matches
- Update with cleared email → lookup cleared
- Update with unchanged email → lookup preserved
- `TriggerHandler.bypass('OpportunityTriggerHandler')` → trigger skipped (proves the framework's bypass API is wired up)

---

## Design decisions

A few non-obvious choices, called out so reviewers don't have to guess:

- **Kevin O'Hara framework is non-negotiable.** Every trigger in this project goes through `TriggerHandler.run()`. No business logic lives in trigger files. This is the de-facto enterprise pattern; copying it ships recursion control, bypass API, and max-loop protection for free.
- **Lookup is read-only on the layout** — even though Salesforce permits manual editing, the permission set restricts `Opportunity.Reseller__c` to read-only. The trigger is the single source of truth; allowing manual edits would mislead users.
- **Inactive resellers are excluded at SOQL level**, not in post-query Apex. Cheaper and explicit.
- **No-match is silent.** A missing reseller must never block an Opportunity from saving — channel attribution is a nice-to-have, not a gating field.
- **Update path is optimised.** On update, the trigger only re-queries when `Reseller_Email__c` actually changed (using `Trigger.oldMap`), so editing unrelated fields adds zero SOQL.
- **Tier picklist (Bronze/Silver/Gold/Platinum) is intentionally deferred** to a future phase to keep the first iteration focused on the matching mechanic.

---

## Roadmap

Planned next phases (not built yet):

- **Reseller Tier picklist** + commission rate per tier + rollup of YTD commission
- **Reports**: Opportunities per Reseller, Pipeline by Reseller Type, Commission Forecast
- **Dashboard** combining the above with bar / pie / KPI tiles
- **Notification on new match**: post a Chatter message to the reseller's Chatter feed when a new Opportunity is auto-linked
- **Lightning Web Component**: "My Channel Pipeline" tile for the rep home page
- **CI**: GitHub Actions workflow that deploys to a scratch org and runs the test suite on every PR

---

## Credits

- Trigger framework: [`kevinohara80/sfdc-trigger-framework`](https://github.com/kevinohara80/sfdc-trigger-framework) (MIT licensed). `TriggerHandler.cls` and `TriggerHandler_Test.cls` are copied verbatim from that repo.
- Built and documented as a Salesforce portfolio project for the **German job market**, focused on the e-mobility / automotive domain.
