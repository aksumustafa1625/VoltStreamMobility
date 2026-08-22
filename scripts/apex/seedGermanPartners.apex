/**
 * seedGermanPartners.apex
 *
 * Rebuilds the channel: 11 Reseller__c partners across the German OEM and
 * dealer-network segments, plus the end customers they sell to.
 *
 * The compliance data is deliberately uneven, and that is the point. One partner
 * has a lapsed Installateurverzeichnis and legally cannot install; one expires
 * inside the three-month notification window from BDEW/ZVEH Grundsätze §5.2; one
 * has an expired §48b certificate, which does not stop the work but does mean
 * VoltStream must withhold 15% Bauabzugsteuer on payment. A partner network where
 * every record is green has nothing for an agent to find.
 *
 * Dates are relative to today so the demo does not rot.
 *
 * ---------------------------------------------------------------------------
 * ASSERTION RULE — read before writing any test against this data.
 *
 * Agentforce evaluations run against live org data. There is no
 * Test.setFixedTime() and no way to freeze "today" inside an agent test run,
 * so any assertion that depends on the distance between now and a seeded date
 * is a bomb with a known fuse. The partner below at T.addDays(58) is inside the
 * §5.2 notification window today and simply expired 92 days from now, at which
 * point a test expecting WARNUNG correctly returns BLOCKIERT and goes red for
 * no reason anyone will find quickly.
 *
 * Assert only on things that do not move:
 *   - values derived from a FIXED input (Eichfrist_Ende__c from a hard-coded
 *     Inverkehrbringen date is stable forever)
 *   - status enums (OK / WARNUNG / BLOCKIERT)
 * Never assert a day count, and never assert a phrase like "in 58 Tagen".
 *
 * Re-run this script as the first step of any evaluation run.
 * ---------------------------------------------------------------------------
 *
 * Idempotent: deletes and rebuilds its own records.
 *
 * Run:  sf apex run --file scripts/apex/seedGermanPartners.apex -o VoltStreamDev
 */

Date T = Date.today();

// --- wipe --------------------------------------------------------------------
delete [SELECT Id FROM Opportunity LIMIT 50000];
delete [SELECT Id FROM Account LIMIT 50000];
delete [SELECT Id FROM Reseller__c LIMIT 50000];

// --- channel partners --------------------------------------------------------
List<Reseller__c> rs = new List<Reseller__c>();

// -- Vertragshaendler / Autohausgruppe: sell the car, the charger follows it --
rs.add(new Reseller__c(
    Name = 'Autohaus Rheinbach GmbH', Company_Email__c = 'fuhrpark@autohaus-rheinbach.example',
    Country__c = 'Germany', Phone__c = '+49 2226 90210', Active__c = true,
    Reseller_Type__c = 'Vertragshaendler', Partner_Tier__c = 'Gold',
    Handwerksrolle_Nr__c = 'HWK-BN-114792', Betriebshaftpflicht_Deckung__c = 5000000,
    Datenschutz_Rolle__c = 'Eigenstaendig Verantwortlicher'));

rs.add(new Reseller__c(
    Name = 'Mobility Center Hamburg-Nord GmbH', Company_Email__c = 'gewerbe@mobility-hh-nord.example',
    Country__c = 'Germany', Phone__c = '+49 40 5544120', Active__c = true,
    Reseller_Type__c = 'Vertragshaendler', Partner_Tier__c = 'Silber',
    Handwerksrolle_Nr__c = 'HWK-HH-208814', Betriebshaftpflicht_Deckung__c = 3000000,
    Datenschutz_Rolle__c = 'Eigenstaendig Verantwortlicher'));

rs.add(new Reseller__c(
    Name = 'Sueddeutsche Automobil Gruppe SE', Company_Email__c = 'b2b@sag-gruppe.example',
    Country__c = 'Germany', Phone__c = '+49 89 74410300', Active__c = true,
    Reseller_Type__c = 'Autohausgruppe', Partner_Tier__c = 'Platin',
    Handwerksrolle_Nr__c = 'HWK-M-331507', Betriebshaftpflicht_Deckung__c = 10000000,
    Datenschutz_Rolle__c = 'Gemeinsam Verantwortlicher Art 26'));

rs.add(new Reseller__c(
    Name = 'TechnikPartner Werkstattkette AG', Company_Email__c = 'einkauf@technikpartner.example',
    Country__c = 'Germany', Phone__c = '+49 221 66702140', Active__c = true,
    Reseller_Type__c = 'Werkstattkette', Partner_Tier__c = 'Silber',
    Handwerksrolle_Nr__c = 'HWK-K-905233', Betriebshaftpflicht_Deckung__c = 3000000,
    Datenschutz_Rolle__c = 'Eigenstaendig Verantwortlicher'));

// -- Elektroinstallationsunternehmen: the segment carrying the NAV §13 gate --
rs.add(new Reseller__c(
    Name = 'Berlin Elektrotechnik GmbH', Company_Email__c = 'kontakt@berlin-elektrotechnik.example',
    Country__c = 'Germany', Phone__c = '+49 30 12345678', Active__c = true,
    Reseller_Type__c = 'Elektroinstallationsunternehmen', Partner_Tier__c = 'Gold',
    Installateurverzeichnis_Nr__c = 'IV-SNB-2022-4471',
    Installateurverzeichnis_Gueltig_Bis__c = T.addMonths(31),
    Netzbetreiber__c = 'Stromnetz Berlin GmbH', VEFK_Name__c = 'Dipl.-Ing. Katrin Vogel',
    Freistellungsbescheinigung_Bis__c = T.addMonths(14),
    Handwerksrolle_Nr__c = 'HWK-B-441028', Betriebshaftpflicht_Deckung__c = 5000000,
    Datenschutz_Rolle__c = 'Eigenstaendig Verantwortlicher'));

// Expires inside the §5.2 three-month notification window: should surface as a warning.
rs.add(new Reseller__c(
    Name = 'Elektro Wagner und Soehne KG', Company_Email__c = 'info@elektro-wagner.example',
    Country__c = 'Germany', Phone__c = '+49 711 4470155', Active__c = true,
    Reseller_Type__c = 'Elektroinstallationsunternehmen', Partner_Tier__c = 'Bronze',
    Installateurverzeichnis_Nr__c = 'IV-NBW-2021-8830',
    Installateurverzeichnis_Gueltig_Bis__c = T.addDays(58),
    Netzbetreiber__c = 'Netze BW GmbH', VEFK_Name__c = 'Meister Jonas Wagner',
    Freistellungsbescheinigung_Bis__c = T.addMonths(8),
    Handwerksrolle_Nr__c = 'HWK-S-772610', Betriebshaftpflicht_Deckung__c = 3000000,
    Datenschutz_Rolle__c = 'Eigenstaendig Verantwortlicher'));

// Lapsed registration: may not legally work behind the house fuse. Hard block.
rs.add(new Reseller__c(
    Name = 'Nordlicht Elektroinstallation GmbH', Company_Email__c = 'service@nordlicht-elektro.example',
    Country__c = 'Germany', Phone__c = '+49 40 33028890', Active__c = true,
    Reseller_Type__c = 'Elektroinstallationsunternehmen', Partner_Tier__c = 'Silber',
    Installateurverzeichnis_Nr__c = 'IV-HH-2019-1204',
    Installateurverzeichnis_Gueltig_Bis__c = T.addDays(-46),
    Netzbetreiber__c = 'Stromnetz Hamburg GmbH', VEFK_Name__c = null,
    Freistellungsbescheinigung_Bis__c = T.addMonths(5),
    Handwerksrolle_Nr__c = 'HWK-HH-119043', Betriebshaftpflicht_Deckung__c = 3000000,
    Datenschutz_Rolle__c = 'Eigenstaendig Verantwortlicher'));

// -- Fleet, utility, parking, property --
// §48b certificate lapsed: work may proceed, but payment triggers 15% withholding.
rs.add(new Reseller__c(
    Name = 'LogistikFlotte Rhein-Ruhr GmbH', Company_Email__c = 'fuhrpark@lf-rheinruhr.example',
    Country__c = 'Germany', Phone__c = '+49 203 80115500', Active__c = true,
    Reseller_Type__c = 'Flottenbetreiber', Partner_Tier__c = 'Gold',
    Freistellungsbescheinigung_Bis__c = T.addDays(-19),
    Handwerksrolle_Nr__c = null, Betriebshaftpflicht_Deckung__c = 5000000,
    Datenschutz_Rolle__c = 'Eigenstaendig Verantwortlicher'));

// Inactive: ResellerSelector filters these out, so the trigger must never link a deal here.
rs.add(new Reseller__c(
    Name = 'Stadtwerke Musterstadt AoeR', Company_Email__c = 'channel@sw-musterstadt.example',
    Country__c = 'Germany', Phone__c = '+49 89 67890123', Active__c = false,
    Reseller_Type__c = 'Energieversorger', Partner_Tier__c = 'Bronze',
    Datenschutz_Rolle__c = 'Gemeinsam Verantwortlicher Art 26'));

rs.add(new Reseller__c(
    Name = 'ParkService Deutschland GmbH', Company_Email__c = 'b2b@parkservice-de.example',
    Country__c = 'Germany', Phone__c = '+49 711 22890440', Active__c = true,
    Reseller_Type__c = 'Parkraumbetreiber', Partner_Tier__c = 'Silber',
    Betriebshaftpflicht_Deckung__c = 3000000,
    Freistellungsbescheinigung_Bis__c = T.addMonths(19),
    Datenschutz_Rolle__c = 'Eigenstaendig Verantwortlicher'));

rs.add(new Reseller__c(
    Name = 'Rheinland Immobilien Verwaltung GmbH', Company_Email__c = 'technik@rheinland-iv.example',
    Country__c = 'Germany', Phone__c = '+49 211 5540210', Active__c = true,
    Reseller_Type__c = 'Immobilienbetreiber', Partner_Tier__c = 'Bronze',
    Betriebshaftpflicht_Deckung__c = 2000000,
    Freistellungsbescheinigung_Bis__c = T.addMonths(26),
    Datenschutz_Rolle__c = 'Eigenstaendig Verantwortlicher'));

insert rs;

// --- end customers -----------------------------------------------------------
List<Account> accs = new List<Account>{
    new Account(Name = 'Kraftverkehr Sauerland GmbH',        Industry = 'Transportation', BillingCity = 'Arnsberg',   BillingCountry = 'Germany', NumberOfEmployees = 240),
    new Account(Name = 'Hotel Rheinblick Betriebs GmbH',      Industry = 'Hospitality',    BillingCity = 'Koblenz',    BillingCountry = 'Germany', NumberOfEmployees = 95),
    new Account(Name = 'Maschinenbau Lindner AG',             Industry = 'Manufacturing',  BillingCity = 'Augsburg',   BillingCountry = 'Germany', NumberOfEmployees = 1400),
    new Account(Name = 'Klinikum Weserbergland gGmbH',        Industry = 'Healthcare',     BillingCity = 'Hameln',     BillingCountry = 'Germany', NumberOfEmployees = 2100),
    new Account(Name = 'Baumarkt Nordwest eG',                Industry = 'Retail',         BillingCity = 'Oldenburg',  BillingCountry = 'Germany', NumberOfEmployees = 620),
    new Account(Name = 'Wohnbau Leipzig Ost eG',              Industry = 'Real Estate',    BillingCity = 'Leipzig',    BillingCountry = 'Germany', NumberOfEmployees = 80),
    new Account(Name = 'Speditionsgruppe Donau GmbH & Co KG', Industry = 'Transportation', BillingCity = 'Regensburg', BillingCountry = 'Germany', NumberOfEmployees = 510),
    new Account(Name = 'Stadtverwaltung Freiberg',            Industry = 'Government',     BillingCity = 'Freiberg',   BillingCountry = 'Germany', NumberOfEmployees = 430),
    new Account(Name = 'Autohof Vogtland Betriebs GmbH',      Industry = 'Transportation', BillingCity = 'Plauen',     BillingCountry = 'Germany', NumberOfEmployees = 60),
    new Account(Name = 'Technologiepark Karlsruhe GmbH',      Industry = 'Real Estate',    BillingCity = 'Karlsruhe',  BillingCountry = 'Germany', NumberOfEmployees = 150),
    new Account(Name = 'Pflegeheime Ostsee gGmbH',            Industry = 'Healthcare',     BillingCity = 'Rostock',    BillingCountry = 'Germany', NumberOfEmployees = 340),
    new Account(Name = 'Getraenke Hansen Logistik GmbH',      Industry = 'Transportation', BillingCity = 'Kiel',       BillingCountry = 'Germany', NumberOfEmployees = 180)
};
insert accs;

System.debug(LoggingLevel.ERROR, 'PARTNERS -> Reseller__c:' + rs.size() + ' Account:' + accs.size());
