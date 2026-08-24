// One charge point with a full working life, for the demo.
//
// Every other seeded record isolates a single fact pattern, which is right for a test matrix and
// wrong for a screenshot: the card ends up showing three provisions and an empty history. This one
// has been operated, repaired, worked on, re-calibrated and finally taken out of service by a
// software update - so the card shows six provisions, four events and four different consequences.
//
// The verdict is the most interesting state in the whole domain: the calibration period is running
// and valid, and the charge point may still not be operated.
//
// Idempotent: safe to re-run.

final String EVSE = 'DE*VSM*E00001001';

delete [SELECT Id FROM Ladepunkt__c WHERE EVSE_ID__c = :EVSE];

List<Account> vorhanden = [SELECT Id FROM Account WHERE Name = 'Stadtwerke Musterstadt GmbH' LIMIT 1];
Account betreiber;
if (vorhanden.isEmpty()) {
    betreiber = new Account(Name = 'Stadtwerke Musterstadt GmbH');
    insert betreiber;
} else {
    betreiber = vorhanden[0];
}

Ladepunkt__c lp = new Ladepunkt__c(
    Betreiber__c = betreiber.Id,
    Standort_Adresse__c = 'Ladepark Alexanderplatz, Säule 3, 10178 Berlin',
    EVSE_ID__c = EVSE,
    Inverkehrbringen__c = Date.newInstance(2015, 6, 1),
    Inbetriebnahme__c = Date.newInstance(2015, 7, 15),
    Ladeleistung_kW__c = 22,
    Stromart__c = 'AC',
    Oeffentlich_zugaenglich__c = true,
    Oeffentlich_seit__c = Date.newInstance(2015, 7, 15),
    BNetzA_Anzeige_am__c = Date.newInstance(2015, 7, 20),
    BNetzA_veroeffentlicht__c = true,
    TEN_T_Netz__c = 'Kein TEN-T',
    Datenquelle__c = 'Manuell'
);
insert lp;

// 1 — a repair that met all four conditions of § 37 Abs. 5. The period survives it untouched,
//     which is the whole point of the exemption and is worth showing next to one that does not.
Eingriff__c instandsetzung = new Eingriff__c(
    Ladepunkt__c = lp.Id,
    Typ__c = 'Instandsetzung',
    Datum__c = Date.newInstance(2018, 4, 12),
    Beschreibung__c = 'Austausch des Displays durch die Fa. Elektro Nord (staatlich anerkannte '
                    + 'Prüfstelle). Messtechnische Einrichtungen nicht berührt.',
    Instandsetzer_befugt__c = true,
    Nacheichung_beantragt__c = true,
    Kennzeichnung_41__c = true,
    Behoerde_informiert__c = true
);

// 2 — an intervention that CAN affect metrological properties. The test is "can", not "did", so
//     the period ends early even though the meter demonstrably kept measuring correctly.
Eingriff__c eingriff = new Eingriff__c(
    Ladepunkt__c = lp.Id,
    Typ__c = 'Eingriff',
    Datum__c = Date.newInstance(2020, 9, 15),
    Beschreibung__c = 'Tausch des Ladekabels nach Vandalismus. Der Eingriff kann Einfluss auf die '
                    + 'messtechnischen Eigenschaften haben; die Messrichtigkeit wurde nicht bestritten.'
);

// 3 — the re-calibration that cures it, and it came in time, so the new period starts on the day
//     of calibration rather than being backdated.
Eingriff__c nacheichung = new Eingriff__c(
    Ladepunkt__c = lp.Id,
    Typ__c = 'Nacheichung',
    Datum__c = Date.newInstance(2021, 3, 10),
    Beschreibung__c = 'Nacheichung durch die Eichbehörde Berlin. Neue Eichfrist ab dem Tag der '
                    + 'Eichung nach § 34 Abs. 1 Satz 2 MessEV.'
);

// 4 — the state the domain is most interesting about: the period runs on untouched, and the
//     charge point may not be operated until the authority signs off.
Eingriff__c softwareUpdate = new Eingriff__c(
    Ladepunkt__c = lp.Id,
    Typ__c = 'Software-Update',
    Datum__c = Date.newInstance(2024, 5, 20),
    Beschreibung__c = 'Update der Abrechnungssoftware auf Version 4.2 durch den Hersteller. '
                    + 'Zustimmung des Verwenders liegt vor, die behördliche Freigabe steht aus.'
);

insert new List<Eingriff__c>{instandsetzung, eingriff, nacheichung, softwareUpdate};

Ladepunkt__c geladen = [
    SELECT Name, Eichstatus__c, Fristbeginn__c, Eichfrist_Ende__c
    FROM Ladepunkt__c WHERE Id = :lp.Id LIMIT 1];

EichrechtCardController.Ansicht karte = EichrechtCardController.ladeEichrecht(lp.Id);

System.debug(LoggingLevel.ERROR, '');
System.debug(LoggingLevel.ERROR, '=== ' + geladen.Name + ' — ' + karte.statusText + ' ===');
System.debug(LoggingLevel.ERROR, karte.begruendung);
System.debug(LoggingLevel.ERROR, 'Frist: ' + karte.fristbeginn + ' -> ' + karte.fristende);
System.debug(LoggingLevel.ERROR, 'Formel sagt: ' + geladen.Eichstatus__c);
System.debug(LoggingLevel.ERROR, '--- Rechtsgrundlagen (' + karte.rechtsgrundlagen.size() + ') ---');
for (EichrechtCardController.Normbezug n : karte.rechtsgrundlagen) {
    System.debug(LoggingLevel.ERROR, '  ' + n.norm);
}
System.debug(LoggingLevel.ERROR, '--- Verlauf (' + karte.verlauf.size() + ') ---');
for (EichrechtCardController.Ereignis e : karte.verlauf) {
    System.debug(LoggingLevel.ERROR, '  ' + e.datum + ' ' + e.typ + ' -> ' + e.wirkung.abbreviate(100));
}
