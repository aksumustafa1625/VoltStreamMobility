/**
 * @description  Tests for the OCPI import.
 *
 *               The case that carries the design is `einImportierterLadepunktIstUnbekannt`: a
 *               charge point that arrives from a CPO backend evaluates to UNBEKANNT, because OCPI
 *               models availability and power and carries nothing German metrology law asks for.
 *               That is asserted rather than assumed, because it is the sentence the whole project
 *               argues — a data gap is not a clean bill of health — and an integration is where it
 *               stops being a principle and becomes a fleet.
 *
 *               The other cases are about not losing data quietly: a malformed EVSE, a duplicate
 *               identifier, an unreachable endpoint and a refused call each have to leave a trace
 *               and let the rest of the import through.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-24
 */
@IsTest
private class OcpiImportServiceTest {

    /** Two locations. One EVSE has no evse_id, one is a duplicate, one AC and one DC. */
    private static final String ANTWORT = '{'
        + '"status_code":1000,"data":['
        + '{"id":"LOC-BER-01","address":"Alexanderplatz 1","postal_code":"10178","city":"Berlin",'
        + '  "evses":['
        + '    {"evse_id":"DE*VSM*E00000001","status":"AVAILABLE","connectors":['
        + '      {"power_type":"AC_3_PHASE","max_electric_power":11000},'
        + '      {"power_type":"AC_1_PHASE","max_electric_power":3700}]},'
        + '    {"evse_id":"DE*VSM*E00000002","status":"CHARGING","connectors":['
        + '      {"power_type":"DC","max_electric_power":150000}]},'
        + '    {"status":"OUTOFORDER","connectors":[]}'
        + '  ]},'
        + '{"id":"LOC-MUC-07","address":"Marienplatz 8","postal_code":"80331","city":"München",'
        + '  "evses":['
        + '    {"evse_id":"DE*VSM*E00000001","status":"AVAILABLE","connectors":['
        + '      {"power_type":"AC_3_PHASE","max_electric_power":22000}]}'
        + '  ]},'
        + '{"id":"LOC-HAM-99","address":"Reeperbahn 1","city":"Hamburg"}'
        + ']}';

    private class Antwortgeber implements HttpCalloutMock {
        private final Integer status;
        private final String koerper;
        private final Boolean wirft;
        Antwortgeber(Integer status, String koerper, Boolean wirft) {
            this.status = status;
            this.koerper = koerper;
            this.wirft = wirft;
        }
        public HttpResponse respond(HttpRequest anfrage) {
            System.assert(anfrage.getEndpoint().startsWith('callout:OCPI_CPO'),
                'Der Aufruf muss ueber die Named Credential laufen, nicht ueber eine feste URL: '
                + anfrage.getEndpoint());
            if (wirft) {
                throw new CalloutException('Endpunkt nicht erreichbar');
            }
            HttpResponse antwort = new HttpResponse();
            antwort.setStatusCode(status);
            antwort.setStatus(status == 200 ? 'OK' : 'Forbidden');
            antwort.setBody(koerper);
            return antwort;
        }
    }

    @IsTest
    static void einStandortWirdZuEinemLadepunktJeEvse() {
        Test.setMock(HttpCalloutMock.class, new Antwortgeber(200, ANTWORT, false));

        Test.startTest();
        OcpiImportService.Ergebnis e = OcpiImportService.importiereLadepunkte();
        Test.stopTest();

        System.assertEquals(3, e.standorte, 'Drei Standorte kamen in der Antwort.');
        System.assertEquals(2, e.uebernommen,
            'Zwei EVSE mit gueltiger Kennung; der dritte hat keine, der vierte ist ein Duplikat.');

        Map<String, Ladepunkt__c> jeEvse = new Map<String, Ladepunkt__c>();
        for (Ladepunkt__c lp : [SELECT EVSE_ID__c, Ladeleistung_kW__c, Stromart__c, OCPI_Status__c,
                                       OCPI_Standort_ID__c, Standort_Adresse__c, Datenquelle__c,
                                       Zuletzt_importiert_am__c
                                FROM Ladepunkt__c WHERE Datenquelle__c = 'OCPI']) {
            jeEvse.put(lp.EVSE_ID__c, lp);
        }
        System.assertEquals(2, jeEvse.size());

        Ladepunkt__c ac = jeEvse.get('DE*VSM*E00000001');
        // The EVSE has an 11 kW and a 3.7 kW connector. Every threshold in the German rules asks
        // what the point can deliver, so the stronger one wins.
        System.assertEquals(11, ac.Ladeleistung_kW__c,
            'Bei mehreren Anschluessen zaehlt der staerkste.');
        System.assertEquals('AC', ac.Stromart__c);
        System.assertEquals('AVAILABLE', ac.OCPI_Status__c);
        System.assertEquals('LOC-BER-01', ac.OCPI_Standort_ID__c);
        System.assertEquals('Alexanderplatz 1, 10178, Berlin', ac.Standort_Adresse__c);
        System.assertNotEquals(null, ac.Zuletzt_importiert_am__c);

        Ladepunkt__c dc = jeEvse.get('DE*VSM*E00000002');
        System.assertEquals(150, dc.Ladeleistung_kW__c, 'OCPI meldet Watt, das Recht rechnet in kW.');
        System.assertEquals('DC', dc.Stromart__c, 'AC_1_PHASE und AC_3_PHASE sind beide AC.');
    }

    @IsTest
    static void einImportierterLadepunktIstEichrechtlichUnbekannt() {
        Test.setMock(HttpCalloutMock.class, new Antwortgeber(200, ANTWORT, false));

        Test.startTest();
        OcpiImportService.Ergebnis e = OcpiImportService.importiereLadepunkte();
        Test.stopTest();

        Ladepunkt__c lp = [SELECT Id, Inverkehrbringen__c, Eichstatus__c
                           FROM Ladepunkt__c WHERE EVSE_ID__c = 'DE*VSM*E00000001' LIMIT 1];

        // The point of the whole integration. OCPI carries availability, power and connector type;
        // it carries no Inverkehrbringen, no Tag der Eichung and no Nacheichung. So a CPO can hand
        // over an entire estate and not one record of it can be assessed under MessEG.
        System.assertEquals(null, lp.Inverkehrbringen__c,
            'OCPI fuehrt kein Inverkehrbringen - es gibt nichts, woraus es abzuleiten waere.');

        DecisionResult d = EichrechtService.bewerteEichfrist(
            LadepunktSelector.byIds(new Set<Id>{lp.Id})[0], new List<Eingriff__c>(), Date.today());
        System.assertEquals(DecisionResult.Status.UNBEKANNT, d.ergebnis,
            'Ein importierter Ladepunkt ist eichrechtlich unbekannt, nicht unbedenklich.');
        System.assert(!d.hatAussage(), 'Und UNBEKANNT ist keine Aussage ueber den Ladepunkt.');
        System.assert(e.hinweis.contains('UNBEKANNT'),
            'Der Import sagt das ausdruecklich, statt es den Aufrufer entdecken zu lassen: '
            + e.hinweis);
    }

    @IsTest
    static void einEvseOhneKennungWirdProtokolliertStattStillVerworfen() {
        Test.setMock(HttpCalloutMock.class, new Antwortgeber(200, ANTWORT, false));

        Test.startTest();
        OcpiImportService.importiereLadepunkte();
        Test.stopTest();

        // Nachricht__c is a long text area and SOQL cannot filter one, so the selection happens
        // here rather than in the query.
        List<Integrationsfehler__c> fehler = new List<Integrationsfehler__c>();
        for (Integrationsfehler__c f : [SELECT Nachricht__c, Kennung__c, Nutzlast__c
                                        FROM Integrationsfehler__c]) {
            if (f.Nachricht__c != null && f.Nachricht__c.contains('evse_id')) {
                fehler.add(f);
            }
        }
        System.assertEquals(1, fehler.size(),
            'Ein EVSE ohne Kennung ist kein Grund zum Abbrechen, aber auch keiner zum Schweigen.');
        System.assertEquals('LOC-BER-01', fehler[0].Kennung__c,
            'Der Standort wird genannt, damit jemand ihn beim CPO reklamieren kann.');
        System.assertNotEquals(null, fehler[0].Nutzlast__c,
            'Und die Nutzlast bleibt erhalten - ein Mapping-Fehler ist ohne seine Form nicht '
            + 'reproduzierbar, und den CPO um ein erneutes Senden zu bitten ist keine Option.');
    }

    @IsTest
    static void eineDoppelteEvseIdNimmtDenLaufNichtMit() {
        Test.setMock(HttpCalloutMock.class, new Antwortgeber(200, ANTWORT, false));

        Test.startTest();
        OcpiImportService.Ergebnis e = OcpiImportService.importiereLadepunkte();
        Test.stopTest();

        // Upserting a batch that repeats an external id fails the entire batch. The duplicate is
        // dropped and recorded instead, so one sloppy CPO response costs one record and not eight
        // hundred.
        System.assertEquals(2, e.uebernommen);
        Integer doppelt = 0;
        for (Integrationsfehler__c f : [SELECT Nachricht__c FROM Integrationsfehler__c]) {
            if (f.Nachricht__c != null && f.Nachricht__c.contains('mehrfach')) {
                doppelt++;
            }
        }
        System.assertEquals(1, doppelt, 'Das Duplikat wird genannt.');
    }

    @IsTest
    static void einUnerreichbarerEndpunktMeldetSichStattLeerZuLaufen() {
        Test.setMock(HttpCalloutMock.class, new Antwortgeber(200, null, true));

        Test.startTest();
        OcpiImportService.Ergebnis e = OcpiImportService.importiereLadepunkte();
        Test.stopTest();

        // The failure this guards against: a callout that returns nothing looks exactly like a
        // callout that found nothing to import. A silent empty run reports an empty fleet as a
        // clean fleet.
        System.assertEquals(0, e.uebernommen);
        System.assert(e.hinweis.contains('nicht erreichbar'), 'Der Hinweis sagt, was passiert ist.');
        System.assertEquals(1, [SELECT COUNT() FROM Integrationsfehler__c WHERE Statuscode__c = 0],
            'Statuscode null bedeutet: der Aufruf hat den Endpunkt nie erreicht.');
    }

    @IsTest
    static void einAbgelehnterAbrufWirdMitStatusUndKoerperProtokolliert() {
        Test.setMock(HttpCalloutMock.class, new Antwortgeber(403, '{"status_code":2001}', false));

        Test.startTest();
        OcpiImportService.Ergebnis e = OcpiImportService.importiereLadepunkte();
        Test.stopTest();

        System.assertEquals(0, e.uebernommen);
        Integrationsfehler__c fehler = [SELECT Statuscode__c, Nutzlast__c, Vorgang__c
                                        FROM Integrationsfehler__c LIMIT 1];
        System.assertEquals(403, fehler.Statuscode__c);
        System.assertEquals('GET /locations', fehler.Vorgang__c,
            'Der Vorgang trennt ein Berechtigungsproblem von einem Mapping-Problem, ohne dass '
            + 'jemand die Nutzlast oeffnen muss.');
        System.assertNotEquals(null, fehler.Nutzlast__c);
    }

    @IsTest
    static void einZweiterLaufAktualisiertStattZuVerdoppeln() {
        Test.setMock(HttpCalloutMock.class, new Antwortgeber(200, ANTWORT, false));

        Test.startTest();
        OcpiImportService.importiereLadepunkte();
        OcpiImportService.importiereLadepunkte();
        Test.stopTest();

        // Without the external id the nightly job would create the estate again every night.
        System.assertEquals(2, [SELECT COUNT() FROM Ladepunkt__c WHERE Datenquelle__c = 'OCPI'],
            'Der Upsert laeuft ueber die EVSE-ID, die einzige Kennung, die CPO-Backend und '
            + 'Eichrecht teilen.');
    }

    @IsTest
    static void eineUnlesbareAntwortBrichtNichtDurch() {
        Test.setMock(HttpCalloutMock.class, new Antwortgeber(200, 'kein JSON', false));

        Test.startTest();
        OcpiImportService.Ergebnis e = OcpiImportService.importiereLadepunkte();
        Test.stopTest();

        System.assertEquals(0, e.uebernommen);
        System.assert(e.hinweis.contains('nicht lesbar'));
        System.assertEquals(1, [SELECT COUNT() FROM Integrationsfehler__c]);
    }
}
