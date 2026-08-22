/**
 * seedGermanPipeline.apex
 *
 * Builds the pipeline: 15 opportunities with real line items drawn from the
 * German catalogue.
 *
 * Deliberately, no opportunity here sets Reseller__c directly. Each one carries
 * only Reseller_Email__c and lets OpportunityTrigger resolve the lookup, so
 * running this script is itself a live check that the trigger, the helper and
 * ResellerSelector still work end to end. Two rows point at an inactive partner
 * and one at an address nobody owns — those must come out with a null lookup,
 * because ResellerSelector filters on Active__c.
 *
 * Idempotent: deletes and rebuilds its own opportunities.
 *
 * Run:  sf apex run --file scripts/apex/seedGermanPipeline.apex -o VoltStreamDev
 */

Date T = Date.today();
Id pbId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;

Map<String, Id> acc = new Map<String, Id>();
for (Account a : [SELECT Id, Name FROM Account LIMIT 50000]) acc.put(a.Name, a.Id);

Map<String, PricebookEntry> pbe = new Map<String, PricebookEntry>();
for (PricebookEntry p : [SELECT Id, UnitPrice, Product2.ProductCode
                         FROM PricebookEntry WHERE Pricebook2Id = :pbId LIMIT 50000]) {
    pbe.put(p.Product2.ProductCode, p);
}

delete [SELECT Id FROM Opportunity LIMIT 50000];

// name | account | stage | close offset (days) | reseller email
List<List<String>> deals = new List<List<String>>{
new List<String>{'Kraftverkehr Sauerland - Depotladen 12x22 kW','Kraftverkehr Sauerland GmbH','Proposal/Price Quote','24','info@elektro-wagner.example'},
new List<String>{'Hotel Rheinblick - Gaesteladen 6x22 kW','Hotel Rheinblick Betriebs GmbH','Negotiation/Review','16','technik@rheinland-iv.example'},
new List<String>{'Maschinenbau Lindner - Mitarbeiterladen 40 Punkte','Maschinenbau Lindner AG','Value Proposition','62','b2b@sag-gruppe.example'},
new List<String>{'Klinikum Weserbergland - Besucherparkhaus 20x22 kW','Klinikum Weserbergland gGmbH','Needs Analysis','78','kontakt@berlin-elektrotechnik.example'},
new List<String>{'Baumarkt Nordwest - Kundenparkplatz DC 2x150 kW','Baumarkt Nordwest eG','Qualification','95','b2b@parkservice-de.example'},
new List<String>{'Wohnbau Leipzig Ost - GEIG Nachruestung 24 Stellplaetze','Wohnbau Leipzig Ost eG','Prospecting','120','technik@rheinland-iv.example'},
new List<String>{'Speditionsgruppe Donau - eTruck Ladehub 400 kW','Speditionsgruppe Donau GmbH & Co KG','Proposal/Price Quote','41','fuhrpark@lf-rheinruhr.example'},
new List<String>{'Stadtverwaltung Freiberg - Dienstflotte 8x22 kW','Stadtverwaltung Freiberg','Id. Decision Makers','57','channel@sw-musterstadt.example'},
new List<String>{'Autohof Vogtland - HPC Standort 2x300 kW','Autohof Vogtland Betriebs GmbH','Negotiation/Review','12','fuhrpark@autohaus-rheinbach.example'},
new List<String>{'Technologiepark Karlsruhe - Campusladen 30 Punkte','Technologiepark Karlsruhe GmbH','Value Proposition','69','b2b@sag-gruppe.example'},
new List<String>{'Pflegeheime Ostsee - Standorte Rostock und Wismar','Pflegeheime Ostsee gGmbH','Qualification','88','service@nordlicht-elektro.example'},
new List<String>{'Getraenke Hansen - Depot Kiel Nachtladen','Getraenke Hansen Logistik GmbH','Closed Won','-9','gewerbe@mobility-hh-nord.example'},
new List<String>{'Kraftverkehr Sauerland - Erweiterung DC Booster','Kraftverkehr Sauerland GmbH','Closed Won','-27','fuhrpark@lf-rheinruhr.example'},
new List<String>{'Maschinenbau Lindner - Werk 2 Lastmanagement','Maschinenbau Lindner AG','Closed Won','-44','einkauf@technikpartner.example'},
new List<String>{'Hotel Rheinblick - Pilot 2 Wallboxen','Hotel Rheinblick Betriebs GmbH','Closed Lost','-15','niemand@kein-partner.example'}
};

List<Opportunity> opps = new List<Opportunity>();
for (List<String> d : deals) {
    opps.add(new Opportunity(
        Name               = d[0],
        AccountId          = acc.get(d[1]),
        StageName          = d[2],
        CloseDate          = T.addDays(Integer.valueOf(d[3])),
        Pricebook2Id       = pbId,
        Reseller_Email__c  = d[4]   // the trigger resolves Reseller__c from this
    ));
}
insert opps;

Map<String, Id> oppByName = new Map<String, Id>();
for (Opportunity o : opps) oppByName.put(o.Name, o.Id);

// deal name | product code | quantity
List<List<String>> lines = new List<List<String>>{
new List<String>{'Kraftverkehr Sauerland - Depotladen 12x22 kW','VS-AC-D22-FLEET','6'},
new List<String>{'Kraftverkehr Sauerland - Depotladen 12x22 kW','VS-INST-MITTEL','6'},
new List<String>{'Kraftverkehr Sauerland - Depotladen 12x22 kW','VS-LM-DYN','1'},
new List<String>{'Kraftverkehr Sauerland - Depotladen 12x22 kW','VS-BE-PRO','12'},

new List<String>{'Hotel Rheinblick - Gaesteladen 6x22 kW','VS-AC-D22-EICH','3'},
new List<String>{'Hotel Rheinblick - Gaesteladen 6x22 kW','VS-INST-GERING','3'},
new List<String>{'Hotel Rheinblick - Gaesteladen 6x22 kW','VS-BE-BILL','6'},
new List<String>{'Hotel Rheinblick - Gaesteladen 6x22 kW','VS-SLA-PRO','1'},

new List<String>{'Maschinenbau Lindner - Mitarbeiterladen 40 Punkte','VS-AC-Q22-EICH','10'},
new List<String>{'Maschinenbau Lindner - Mitarbeiterladen 40 Punkte','VS-INST-MITTEL','10'},
new List<String>{'Maschinenbau Lindner - Mitarbeiterladen 40 Punkte','VS-LM-DYN','2'},
new List<String>{'Maschinenbau Lindner - Mitarbeiterladen 40 Punkte','VS-BE-ENT','40'},
new List<String>{'Maschinenbau Lindner - Mitarbeiterladen 40 Punkte','VS-ACC-RFID','250'},

new List<String>{'Klinikum Weserbergland - Besucherparkhaus 20x22 kW','VS-AC-D22-EICH','10'},
new List<String>{'Klinikum Weserbergland - Besucherparkhaus 20x22 kW','VS-INST-HOCH','10'},
new List<String>{'Klinikum Weserbergland - Besucherparkhaus 20x22 kW','VS-BE-BILL','20'},
new List<String>{'Klinikum Weserbergland - Besucherparkhaus 20x22 kW','VS-LM-14A','20'},

new List<String>{'Baumarkt Nordwest - Kundenparkplatz DC 2x150 kW','VS-DC-150','2'},
new List<String>{'Baumarkt Nordwest - Kundenparkplatz DC 2x150 kW','VS-INST-DC','2'},
new List<String>{'Baumarkt Nordwest - Kundenparkplatz DC 2x150 kW','VS-ACC-FUND-DC','2'},
new List<String>{'Baumarkt Nordwest - Kundenparkplatz DC 2x150 kW','VS-BE-THG','4'},
new List<String>{'Baumarkt Nordwest - Kundenparkplatz DC 2x150 kW','VS-BE-CARD','4'},

new List<String>{'Wohnbau Leipzig Ost - GEIG Nachruestung 24 Stellplaetze','VS-AC-11-W','24'},
new List<String>{'Wohnbau Leipzig Ost - GEIG Nachruestung 24 Stellplaetze','VS-INST-MITTEL','24'},
new List<String>{'Wohnbau Leipzig Ost - GEIG Nachruestung 24 Stellplaetze','VS-LM-STAT','3'},

new List<String>{'Speditionsgruppe Donau - eTruck Ladehub 400 kW','VS-HPC-400','2'},
new List<String>{'Speditionsgruppe Donau - eTruck Ladehub 400 kW','VS-INST-HPC','1'},
new List<String>{'Speditionsgruppe Donau - eTruck Ladehub 400 kW','VS-SLA-HPC','1'},
new List<String>{'Speditionsgruppe Donau - eTruck Ladehub 400 kW','VS-BE-ENT','4'},

new List<String>{'Stadtverwaltung Freiberg - Dienstflotte 8x22 kW','VS-AC-D22-MID','4'},
new List<String>{'Stadtverwaltung Freiberg - Dienstflotte 8x22 kW','VS-INST-GERING','4'},
new List<String>{'Stadtverwaltung Freiberg - Dienstflotte 8x22 kW','VS-BE-BASIC','8'},

new List<String>{'Autohof Vogtland - HPC Standort 2x300 kW','VS-HPC-300','2'},
new List<String>{'Autohof Vogtland - HPC Standort 2x300 kW','VS-INST-HPC','1'},
new List<String>{'Autohof Vogtland - HPC Standort 2x300 kW','VS-BE-ROAM','4'},
new List<String>{'Autohof Vogtland - HPC Standort 2x300 kW','VS-BE-THG','4'},
new List<String>{'Autohof Vogtland - HPC Standort 2x300 kW','VS-SLA-DC','2'},

new List<String>{'Technologiepark Karlsruhe - Campusladen 30 Punkte','VS-AC-Q22-EICH','7'},
new List<String>{'Technologiepark Karlsruhe - Campusladen 30 Punkte','VS-DC-50','1'},
new List<String>{'Technologiepark Karlsruhe - Campusladen 30 Punkte','VS-INST-MITTEL','8'},
new List<String>{'Technologiepark Karlsruhe - Campusladen 30 Punkte','VS-LM-EMS','1'},

new List<String>{'Pflegeheime Ostsee - Standorte Rostock und Wismar','VS-AC-22-EICH','12'},
new List<String>{'Pflegeheime Ostsee - Standorte Rostock und Wismar','VS-INST-GERING','12'},
new List<String>{'Pflegeheime Ostsee - Standorte Rostock und Wismar','VS-BE-BASIC','12'},

new List<String>{'Getraenke Hansen - Depot Kiel Nachtladen','VS-AC-D22-FLEET','4'},
new List<String>{'Getraenke Hansen - Depot Kiel Nachtladen','VS-INST-MITTEL','4'},
new List<String>{'Getraenke Hansen - Depot Kiel Nachtladen','VS-LM-DYN','1'},
new List<String>{'Getraenke Hansen - Depot Kiel Nachtladen','VS-BE-PRO','8'},

new List<String>{'Kraftverkehr Sauerland - Erweiterung DC Booster','VS-DC-BOOST-60','1'},
new List<String>{'Kraftverkehr Sauerland - Erweiterung DC Booster','VS-BE-PRO','2'},
new List<String>{'Kraftverkehr Sauerland - Erweiterung DC Booster','VS-SLA-DC','1'},

new List<String>{'Maschinenbau Lindner - Werk 2 Lastmanagement','VS-LM-DYN','2'},
new List<String>{'Maschinenbau Lindner - Werk 2 Lastmanagement','VS-LM-EMS','1'},
new List<String>{'Maschinenbau Lindner - Werk 2 Lastmanagement','VS-LM-LIC','1'},

new List<String>{'Hotel Rheinblick - Pilot 2 Wallboxen','VS-AC-22-MID','2'},
new List<String>{'Hotel Rheinblick - Pilot 2 Wallboxen','VS-INST-GERING','2'}
};

List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
for (List<String> l : lines) {
    PricebookEntry e = pbe.get(l[1]);
    if (e == null || oppByName.get(l[0]) == null) continue;
    olis.add(new OpportunityLineItem(
        OpportunityId    = oppByName.get(l[0]),
        PricebookEntryId = e.Id,
        Quantity         = Decimal.valueOf(l[2]),
        UnitPrice        = e.UnitPrice
    ));
}
insert olis;

// --- report: did the trigger resolve the lookups? ----------------------------
Integer linked = 0, unlinked = 0;
Decimal pipeline = 0;
for (Opportunity o : [SELECT Id, Name, Amount, StageName, Reseller__c, Reseller_Email__c
                      FROM Opportunity LIMIT 50000]) {
    if (o.Reseller__c != null) { linked++; } else { unlinked++; }
    if (o.StageName != 'Closed Lost') pipeline += (o.Amount == null ? 0 : o.Amount);
}
System.debug(LoggingLevel.ERROR, 'PIPELINE -> Opportunity:' + opps.size()
    + ' LineItem:' + olis.size()
    + ' | trigger linked:' + linked + ' unlinked:' + unlinked
    + ' | value EUR ' + pipeline.setScale(0));
