/**
 * seedGermanCatalog.apex
 *
 * Builds VoltStream's German EV-charging catalogue: 57 SKUs across 8 product
 * families, each with a standard-pricebook entry in EUR.
 *
 * Prices are anchored to real German B2B list prices surveyed in August 2026
 * (see docs/AGENTFORCE_RESEARCH.md §8) — an Alfen-class 22 kW MID wallbox sits
 * around €710, the same unit eichrechtskonform around €999, a Compleo-class
 * Eichrecht duo around €5,309, an Alpitronic-class 200 kW HPC from ~€67,800.
 * SKUs are VoltStream-branded rather than carrying real vendor names: the
 * domain knowledge belongs in the structure (MID vs Eichrecht tiers, §14a
 * control boxes, AFIR payment terminals), not in borrowed trademarks.
 *
 * Idempotent: wipes every VS-* product and its pricebook entries first, so
 * re-running produces the same catalogue rather than duplicates.
 *
 * Run:  sf apex run --file scripts/apex/seedGermanCatalog.apex -o VoltStreamDev
 */

Id stdPbId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;

// --- wipe previous run -------------------------------------------------------
List<Product2> old = [SELECT Id FROM Product2 WHERE ProductCode LIKE 'VS-%' LIMIT 50000];
if (!old.isEmpty()) {
    delete [SELECT Id FROM PricebookEntry WHERE Product2Id IN :old LIMIT 50000];
    delete old;
}

// --- catalogue ---------------------------------------------------------------
// Each row: code | name | family | unit price | description
List<List<String>> rows = new List<List<String>>{

// ---------- AC-Ladestationen ----------
new List<String>{'VS-AC-11-W','VoltStream Wallbox Home 11 kW, Typ 2 Buchse','AC-Ladestationen','649','11 kW AC, Typ 2 Buchse, OCPP 1.6J, RFID, WLAN/LAN, IP54.'},
new List<String>{'VS-AC-11-K','VoltStream Wallbox Home 11 kW, Typ 2 Kabel 5 m','AC-Ladestationen','749','11 kW AC, fest angeschlagenes Kabel 5 m, OCPP 1.6J, RFID.'},
new List<String>{'VS-AC-22-MID','VoltStream Wallbox Pro 22 kW, MID-Zaehler','AC-Ladestationen','710','22 kW AC, MID-konformer Zaehler. Nicht fuer Abrechnung im geschaeftlichen Verkehr.'},
new List<String>{'VS-AC-22-EICH','VoltStream Wallbox Pro 22 kW, eichrechtskonform','AC-Ladestationen','999','22 kW AC, eichrechtskonform nach MessEG/MessEV, DE-M Kennzeichnung, Eichfrist 8 Jahre.'},
new List<String>{'VS-AC-22-EICH-K','VoltStream Wallbox Pro 22 kW, eichrechtskonform, Kabel','AC-Ladestationen','1249','22 kW AC eichrechtskonform mit fest angeschlagenem Kabel 7,5 m.'},
new List<String>{'VS-AC-D22-MID','VoltStream Ladesaeule Duo 2x22 kW, MID','AC-Ladestationen','3890','Zwei Ladepunkte a 22 kW, MID-Zaehler, OCPP 1.6J, LTE und LAN, IP54/IK10.'},
new List<String>{'VS-AC-D22-EICH','VoltStream Ladesaeule Duo 2x22 kW, eichrechtskonform','AC-Ladestationen','5309','Zwei Ladepunkte a 22 kW, eichrechtskonform, RCD Typ A mit 6 mA DC-Erkennung, Modbus TCP.'},
new List<String>{'VS-AC-D22-FLEET','VoltStream Ladesaeule Duo Fleet 2x22 kW, Spiralkabel','AC-Ladestationen','7210','Depotladen: zwei Spiralkabel, eichrechtskonform, Lastmanagement vorbereitet.'},
new List<String>{'VS-AC-Q22-EICH','VoltStream Ladesaeule Quattro 4x22 kW, eichrechtskonform','AC-Ladestationen','11899','Vier Ladepunkte a 22 kW fuer Parkhaeuser und Mitarbeiterladen.'},
new List<String>{'VS-AC-D22-HAK','VoltStream Ladesaeule Duo 2x22 kW mit Hausanschlusskasten','AC-Ladestationen','8264','Zwei Ladepunkte mit integriertem HAK fuer den oeffentlichen Raum.'},

// ---------- DC-Schnellladestationen ----------
new List<String>{'VS-DC-30','VoltStream DC Compact 30 kW','DC-Schnellladestationen','14900','30 kW DC, CCS2, eichrechtskonform, kompaktes Gehaeuse fuer Autohaeuser.'},
new List<String>{'VS-DC-50','VoltStream DC Compact 50 kW','DC-Schnellladestationen','19900','50 kW DC, CCS2 und CHAdeMO, eichrechtskonform, OCPP 1.6J.'},
new List<String>{'VS-DC-50-2IN1','VoltStream DC Hybrid 50 kW DC + 22 kW AC','DC-Schnellladestationen','25999','Kombigeraet: 50 kW DC plus 22 kW AC, drei Ladepunkte, eichrechtskonform.'},
new List<String>{'VS-DC-75','VoltStream DC Power 75 kW','DC-Schnellladestationen','31500','75 kW DC, zwei Ladepunkte, Leistungsteilung, OCPP 2.0.1.'},
new List<String>{'VS-DC-120','VoltStream DC Power 120 kW','DC-Schnellladestationen','42900','120 kW DC, zwei CCS2-Ladepunkte, ISO 15118 vorbereitet.'},
new List<String>{'VS-DC-150','VoltStream DC Power 150 kW','DC-Schnellladestationen','51900','150 kW DC, AFIR-tauglich fuer TEN-T Standorte.'},
new List<String>{'VS-DC-BOOST-60','VoltStream DC Booster 60 kW, batteriegepuffert','DC-Schnellladestationen','58900','Batteriegepuffertes Schnellladen an schwachem Netzanschluss: 60 kW Ladeleistung bei nur 22 kW Netzbezug. Vermeidet Netzverstaerkung und Wartezeit beim Netzbetreiber.'},

// ---------- HPC-Ladestationen ----------
new List<String>{'VS-HPC-200','VoltStream HPC 200 kW, 2 Ladepunkte','HPC-Ladestationen','67814','200 kW HPC, zwei CCS2-Kabel 5 m, eichrechtskonform, barrierefrei.'},
new List<String>{'VS-HPC-300','VoltStream HPC 300 kW, 2 Ladepunkte','HPC-Ladestationen','84900','300 kW HPC, dynamische Leistungsverteilung, OCPP 2.0.1.'},
new List<String>{'VS-HPC-400','VoltStream HPC 400 kW, 4 Ladepunkte','HPC-Ladestationen','112000','400 kW HPC, bis zu vier Ladepunkte, 150-1000 V, ISO 15118 Plug and Charge.'},
new List<String>{'VS-HPC-400-PT','VoltStream HPC 400 kW mit Zahlungsterminal','HPC-Ladestationen','118500','400 kW HPC mit integriertem Kartenterminal. Erfuellt die AFIR-Anforderung an Kartenzahlung.'},
new List<String>{'VS-HPC-BOOST-300','VoltStream HPC Booster 300 kW, batteriegepuffert','HPC-Ladestationen','139000','300 kW HPC mit Pufferspeicher: Schnellladen an Standorten ohne Mittelspannungsanschluss.'},

// ---------- Backend und Software (Abonnement) ----------
new List<String>{'VS-BE-BASIC','VoltStream Connect Basic, Backend je Ladepunkt','Backend und Software','5','Monatliches Abonnement je Ladepunkt. Monitoring, Fernwartung, Nutzerverwaltung.'},
new List<String>{'VS-BE-PRO','VoltStream Connect Pro, Backend je Ladepunkt','Backend und Software','9','Monatlich je Ladepunkt. Zusaetzlich Tarifverwaltung, Reporting, API-Zugang.'},
new List<String>{'VS-BE-ENT','VoltStream Connect Enterprise, Backend je Ladepunkt','Backend und Software','14','Monatlich je Ladepunkt. Mandantenfaehig, SSO, SLA-Reporting, Datenexport.'},
new List<String>{'VS-BE-BILL','Abrechnungsmodul eichrechtskonform je Ladepunkt','Backend und Software','6','Monatlich je Ladepunkt. Signierte Messwerte, Transparenzsoftware, kWh-genaue Abrechnung.'},
new List<String>{'VS-BE-ROAM','eRoaming-Anbindung OCPI 2.3 je Ladepunkt','Backend und Software','4','Monatlich je Ladepunkt. Anbindung an Roaming-Plattformen, AFIR- und NAP-konform.'},
new List<String>{'VS-BE-THG','THG-Quoten-Service je Ladepunkt','Backend und Software','3','Monatlich je Ladepunkt. UBA-Meldung inklusive EVSE-ID, nur fuer oeffentlich zugaengliche Ladepunkte.'},
new List<String>{'VS-BE-CARD','Kartenzahlung Aktivierung je Ladepunkt','Backend und Software','199','Einmalige Einrichtung des Zahlungsterminals inklusive Acquirer-Anbindung.'},

// ---------- Installation und Montage ----------
new List<String>{'VS-INST-GERING','Installation gering, moderne Verteilung unter 5 m','Installation und Montage','650','Wandmontage, kurze Leitungswege, vorhandene Reserve im Zaehlerschrank.'},
new List<String>{'VS-INST-MITTEL','Installation mittel, 10-20 m mit Wanddurchbruch','Installation und Montage','1150','Leitungsweg 10-20 m, ein bis zwei Wanddurchbrueche, Anpassung der Unterverteilung.'},
new List<String>{'VS-INST-HOCH','Installation hoch, Zaehlerschrank und Erdarbeiten','Installation und Montage','2400','Austausch des Zaehlerschranks, Erdarbeiten, Leitungsweg ueber 30 m.'},
new List<String>{'VS-INST-DC','DC-Installation inklusive Fundament und Erdarbeiten','Installation und Montage','4800','Fundamenterstellung, Erdkabel, Anschluss und Erdung fuer DC-Ladesaeulen.'},
new List<String>{'VS-INST-HPC','HPC-Installation inklusive Trafostation','Installation und Montage','18500','Mittelspannungsanschluss, Trafostation, Tiefbau und Netzbetreiber-Abstimmung.'},
new List<String>{'VS-INST-NETZ','Netzverstaerkung und Hausanschlusserweiterung','Installation und Montage','500','Ertuechtigung des Hausanschlusses, typisch bei mehreren 22-kW-Ladepunkten.'},
new List<String>{'VS-INST-ANM','Netzanschluss-Anmeldung und Netzbetreiber-Koordination','Installation und Montage','390','Anmeldung nach NAV Paragraf 19, Zustimmungsverfahren ab 12 kVA, Fristverfolgung.'},
new List<String>{'VS-INST-INBET','Inbetriebnahme und Eichrechts-Dokumentation','Installation und Montage','280','Messprotokoll, Konformitaetsdokumentation, Uebergabe an den Betreiber.'},

// ---------- Service und Wartung (Abonnement) ----------
new List<String>{'VS-SLA-BASIS','Wartung Basis 8x5, Reaktion naechster Werktag','Service und Wartung','29','Monatlich je Standort. Fernwartung, jaehrliche Sichtpruefung.'},
new List<String>{'VS-SLA-PRO','Wartung Professional 8x5, Reaktion 8 Stunden','Service und Wartung','79','Monatlich je Standort. Vor-Ort-Service, DGUV V3 Pruefung inklusive.'},
new List<String>{'VS-SLA-ENT','Wartung Enterprise 24x7, Reaktion 4 Stunden','Service und Wartung','199','Monatlich je Standort. Rufbereitschaft, Ersatzteilvorhaltung, SLA-Reporting.'},
new List<String>{'VS-SLA-EICH','Eichrechts-Nachpruefung und Rezertifizierung','Service und Wartung','15','Monatlich je Ladepunkt. Fristueberwachung der 8-Jahres-Eichfrist und Nachpruefung.'},
new List<String>{'VS-SLA-DC','DC-Wartungspaket inklusive Kuehlsystem','Service und Wartung','320','Monatlich je DC-Ladesaeule. Kuehlkreislauf, Leistungselektronik, Kabelpruefung.'},
new List<String>{'VS-SLA-HPC','HPC-Vollwartung inklusive Ersatzteile','Service und Wartung','890','Monatlich je HPC-Standort. Vollabdeckung inklusive Powerstack-Tausch.'},

// ---------- Lastmanagement ----------
new List<String>{'VS-LM-STAT','Statisches Lastmanagement bis 8 Ladepunkte','Lastmanagement','890','Feste Leistungsaufteilung ohne Messung des Gebaeudeverbrauchs.'},
new List<String>{'VS-LM-DYN','Dynamisches Lastmanagement inklusive Energiezaehler','Lastmanagement','1890','Regelt die Ladeleistung nach tatsaechlichem Gebaeudebezug, verhindert Lastspitzen.'},
new List<String>{'VS-LM-14A','Steuerbox nach Paragraf 14a EnWG','Lastmanagement','420','Steuerbare Verbrauchseinrichtung ab 4,2 kW nach BNetzA-Festlegung BK6-22-300. Ermoeglicht reduzierte Netzentgelte.'},
new List<String>{'VS-LM-EMS','Energiemanagement-Gateway PV und Speicher','Lastmanagement','1290','Koppelt Ladeinfrastruktur mit PV-Anlage und Batteriespeicher, Ueberschussladen.'},
new List<String>{'VS-LM-LIC','Smart-Charging-Netzwerklizenz','Lastmanagement','119','Einmalige Lizenz zur Vernetzung mehrerer Ladepunkte zu einem Lastverbund.'},

// ---------- Zubehoer ----------
new List<String>{'VS-ACC-RFID','RFID-Ladekarte Eigenmarke','Zubehoer','3.95','Bedruckbare RFID-Karte zur Nutzerfreigabe am Ladepunkt.'},
new List<String>{'VS-ACC-CBL11','Ladekabel Typ 2, 11 kW, 5 m','Zubehoer','129','Mode-3-Ladekabel, 20 A, dreiphasig.'},
new List<String>{'VS-ACC-CBL22','Ladekabel Typ 2, 22 kW, 7,5 m','Zubehoer','159','Mode-3-Ladekabel, 32 A, dreiphasig.'},
new List<String>{'VS-ACC-HALT','Kabelhalter Wandmontage','Zubehoer','39','Wandhalterung fuer Typ-2-Ladekabel.'},
new List<String>{'VS-ACC-MGMT','Kabelmanagement-System','Zubehoer','999','Federzugsystem, haelt das Ladekabel vom Boden fern.'},
new List<String>{'VS-ACC-STAND','Standsaeule V2A fuer Wallbox','Zubehoer','599','Edelstahl-Standsaeule zur Aufnahme von ein bis zwei Wallboxen.'},
new List<String>{'VS-ACC-FUND-AC','Fertigfundament AC-Ladesaeule','Zubehoer','214','Betonfertigfundament mit Kabeleinfuehrung.'},
new List<String>{'VS-ACC-FUND-DC','Fertigfundament DC-Ladesaeule','Zubehoer','1010','Verstaerktes Betonfundament fuer DC- und HPC-Ladesaeulen.'},
new List<String>{'VS-ACC-RAMM','Rammschutzbuegel und Anfahrschutz','Zubehoer','289','Verzinkter Anfahrschutz nach Vorgabe vieler Parkraumbetreiber.'}
};

// --- insert ------------------------------------------------------------------
List<Product2> prods = new List<Product2>();
for (List<String> r : rows) {
    prods.add(new Product2(
        ProductCode = r[0],
        Name        = r[1],
        Family      = r[2],
        Description = r[4],
        IsActive    = true
    ));
}
insert prods;

Map<String, Decimal> priceByCode = new Map<String, Decimal>();
for (List<String> r : rows) priceByCode.put(r[0], Decimal.valueOf(r[3]));

List<PricebookEntry> pbes = new List<PricebookEntry>();
for (Product2 p : prods) {
    pbes.add(new PricebookEntry(
        Product2Id  = p.Id,
        Pricebook2Id = stdPbId,
        UnitPrice   = priceByCode.get(p.ProductCode),
        IsActive    = true
    ));
}
insert pbes;

// --- report ------------------------------------------------------------------
String summary = 'CATALOGUE -> Product2:' + prods.size() + ' PricebookEntry:' + pbes.size() + '\n';
for (AggregateResult ar : [SELECT Family f, COUNT(Id) c FROM Product2 WHERE ProductCode LIKE 'VS-%' GROUP BY Family]) {
    summary += '  ' + ar.get('f') + ': ' + ar.get('c') + '\n';
}
System.debug(LoggingLevel.ERROR, summary);
