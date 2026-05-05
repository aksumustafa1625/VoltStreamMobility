# VoltStream Mobility — Salesforce CRM

Salesforce DX project for **VoltStream Mobility**, a B2B supplier of EV charging infrastructure based in Germany. The org models VoltStream's reseller channel: electricians, solar installers, and energy consultancies that resell wallboxes, DC fast chargers, and load-management solutions to end customers.

## Scope

- **Reseller** custom object — tracks partner companies, certification level, and territory
- **Opportunity** lookup to Reseller — attributes deals to the channel partner that sourced them
- **Apex trigger** on Opportunity — automatic reseller commission calculation and reseller-tier rollup
- **Test class** with full coverage of trigger logic
- **Report & dashboard** — reseller pipeline performance and commission forecast

## Stack

- Salesforce DX (sfdx-project format)
- Apex (triggers, classes, tests)
- Custom objects, fields, validation rules
- Reports & dashboards

## Project status

Portfolio project — built to demonstrate Salesforce admin + developer skills for the German job market (e-mobility / automotive domain focus).
