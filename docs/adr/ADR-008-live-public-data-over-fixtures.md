# ADR-008: The fleet is imported from a live public map, not seeded from a fixture

## Status

**Accepted**

## Date

2026-08-23

## Author

Mustafa Aksu

## Context

The compliance engine evaluates charge points against German calibration law.
The obvious way to demonstrate it is a seed script with charge points carrying
the dates the engine needs, producing a satisfying spread of compliant and
overdue records.

That demonstration would prove the engine's arithmetic and nothing about the
world. A fixture author who knows what the engine reads will supply what it
reads.

## Decision

Import **twenty-five real charge points in central Berlin** from the
**OpenStreetMap Overpass API** — operators including Allego, Vattenfall, Shell
Recharge, Berliner Stadtwerke and E.ON — with **no API key and no account**.

They arrive with an operator, a socket type and sometimes a power rating. They
arrive with **no date of placing on the market, no calibration date and no
re-calibration date**, because no public charge point database carries what a
German metrology question requires.

Every one of the twenty-five therefore evaluates to **`UNBEKANNT`**.

## Alternatives Considered

- **A hand-built fixture with plausible dates.** Rejected: it would prove the
  engine can subtract dates, which was never in doubt.
- **A commercial charge point data source.** Rejected: an API key, an account
  and a cost, for fields the evidence suggests it would not carry either.
- **Both — fixtures for the demo, live data for one test.** Partially adopted:
  seed scripts still exist for the walkthrough, but the live import is the
  headline and has its own test.

## Consequences

- The demonstration is unflattering, and that is the finding. `UNBEKANNT` across
  a whole imported estate is a real statement about the gap between public
  charge point data and what the law asks for.
- **`UNBEKANNT` counts as work to do, not as a clean bill of health.** The
  distinction between "we cannot tell" and "nothing to report" stopped being a
  design principle at that import and became an observed state.
- The import depends on a public endpoint whose availability nobody guarantees,
  so the test asserts on committed sample output rather than calling out live.

## References

- `force-app/main/default/classes/OsmLadepunktImport.cls`
- `force-app/main/default/classes/OsmLadepunktImportTest.cls`
- `scripts/apex/importiereBerlinLive.apex`
