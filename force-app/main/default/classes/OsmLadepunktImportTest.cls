/**
 * @description  Tests for the OpenStreetMap import.
 *
 *               The payload is not invented. It is the shape a live Overpass call actually returned
 *               for a bounding box around Alexanderplatz, including its imperfections: one node
 *               operated by E.ON with a socket count and no power, one with an operator and nothing
 *               else, and one with neither. Fixtures written from the documentation would have been
 *               tidier and would have tested a source that does not exist.
 *
 *               The case that carries the project is the last one. A real charge point, mapped by a
 *               real person, operated by a real operator, arrives with nothing German metrology law
 *               asks for — so it evaluates to UNBEKANNT. On fixtures that was a principle; here it
 *               is what the world hands over.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-24
 */
@IsTest
private class OsmLadepunktImportTest {

    /** Captured from a live Overpass response, imperfections included. */
    private static final String ANTWORT_JSON = '{"version":0.6,"elements":['
        + '{"type":"node","id":1244644142,"lat":52.5219,"lon":13.4132,"tags":'
        + '  {"amenity":"charging_station","operator":"E.ON","capacity":"2",'
        + '   "ref":"BA-0504-8 / BA-0503-1","socket:type2":"2","socket:type2:output":"22 kW"}},'
        + '{"type":"node","id":7907513285,"lat":52.5181,"lon":13.3998,"tags":'
        + '  {"amenity":"charging_station","operator":"Berliner Stadtwerke","capacity":"2"}},'
        + '{"type":"node","id":9525700650,"lat":52.5203,"lon":13.4051,"tags":'
        + '  {"amenity":"charging_station","capacity":"2"}},'
        + '{"type":"node","id":3311220011,"lat":52.5240,"lon":13.4090,"tags":'
        + '  {"amenity":"charging_station","operator":"E.ON","name":"Ladepark Alexanderplatz",'
        + '   "socket:type2_combo":"2","socket:type2_combo:output":"150 kW"}}'
        + ']}';

    private class Spiegel implements HttpCalloutMock {
        private final List<Integer> antworten;
        private Integer aufruf = 0;
        public Integer versuche = 0;
        Spiegel(List<Integer> antworten) {
            this.antworten = antworten;
        }
        public HttpResponse respond(HttpRequest anfrage) {
            versuche++;
            System.assert(anfrage.getEndpoint().startsWith('callout:Overpass_'),
                'Der Aufruf muss ueber eine Named Credential laufen: ' + anfrage.getEndpoint());
            System.assertEquals('POST', anfrage.getMethod(),
                'Overpass-Abfragen gehen als POST, damit die Abfrage nicht in einer URL-Laenge endet.');
            Integer status = antworten[Math.min(aufruf, antworten.size() - 1)];
            aufruf++;
            HttpResponse antwort = new HttpResponse();
            antwort.setStatusCode(status);
            antwort.setStatus(status == 200 ? 'OK' : 'Gateway Timeout');
            antwort.setBody(status == 200 ? ANTWORT_JSON : 'server busy');
            return antwort;
        }
    }

    /** Overpass answers 200 with an HTML page when it throttles - a success carrying no data. */
    private class Gedrosselt implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest anfrage) {
            HttpResponse antwort = new HttpResponse();
            antwort.setStatusCode(200);
            antwort.setBody('<html>rate limited</html>');
            return antwort;
        }
    }

    @IsTest
    static void kartierteLadepunkteWerdenUebernommen() {
        Test.setMock(HttpCalloutMock.class, new Spiegel(new List<Integer>{200}));

        Test.startTest();
        OsmLadepunktImport.Ergebnis e =
            OsmLadepunktImport.importiereBereich(52.51, 13.38, 52.53, 13.42, 10);
        Test.stopTest();

        System.assertEquals(4, e.gelesen);
        System.assertEquals(4, e.uebernommen);
        System.assertEquals(1, e.ohneBetreiber,
            'Ein kartierter Ladepunkt ohne Betreiber ist kein Fehler, sondern die Regel in dieser '
            + 'Quelle - und die Luecke gehoert gezaehlt statt weggelassen.');

        Map<String, Ladepunkt__c> jeQuelle = new Map<String, Ladepunkt__c>();
        for (Ladepunkt__c lp : [SELECT Quell_ID__c, Ladeleistung_kW__c, Stromart__c,
                                       Standort_Adresse__c, Datenquelle__c, Betreiber__r.Name
                                FROM Ladepunkt__c WHERE Datenquelle__c = 'OpenStreetMap']) {
            jeQuelle.put(lp.Quell_ID__c, lp);
        }

        Ladepunkt__c eon = jeQuelle.get('OSM:1244644142');
        System.assertEquals(22, eon.Ladeleistung_kW__c, 'Aus "22 kW" wird 22.');
        System.assertEquals('AC', eon.Stromart__c, 'Ein Typ-2-Anschluss allein bedeutet Wechselstrom.');
        System.assertEquals('E.ON', eon.Betreiber__r.Name,
            'Der kartierte Betreiber wird zum Account - hier ein echter Betreiber in Berlin.');

        Ladepunkt__c schnell = jeQuelle.get('OSM:3311220011');
        System.assertEquals(150, schnell.Ladeleistung_kW__c);
        System.assertEquals('DC', schnell.Stromart__c, 'CCS bedeutet Gleichstrom.');
        System.assertEquals('Ladepark Alexanderplatz', schnell.Standort_Adresse__c);

        Ladepunkt__c ohneAlles = jeQuelle.get('OSM:9525700650');
        System.assertEquals(null, ohneAlles.Ladeleistung_kW__c,
            'Eine nicht lesbare Leistung bleibt leer statt geraten zu werden: ein falscher Wert '
            + 'schiebt einen Ladepunkt still ueber eine rechtliche Schwelle.');
        System.assertEquals('52.5203, 13.4051', ohneAlles.Standort_Adresse__c,
            'Ohne Namen und ohne Adresse bleiben die Koordinaten - ein Standort, den niemand '
            + 'finden kann, ist keiner.');
    }

    @IsTest
    static void einEchterLadepunktIstEichrechtlichUnbekannt() {
        Test.setMock(HttpCalloutMock.class, new Spiegel(new List<Integer>{200}));

        Test.startTest();
        OsmLadepunktImport.Ergebnis e =
            OsmLadepunktImport.importiereBereich(52.51, 13.38, 52.53, 13.42, 10);
        Test.stopTest();

        Ladepunkt__c eon = [SELECT Id, Inverkehrbringen__c FROM Ladepunkt__c
                            WHERE Quell_ID__c = 'OSM:1244644142' LIMIT 1];

        // The whole argument, on a charge point somebody can go and stand in front of. The source
        // knows its operator, its socket and its power. It knows nothing about when it was placed
        // on the market or when it was last calibrated, because no public charge point database
        // exists to answer a German metrology question.
        System.assertEquals(null, eon.Inverkehrbringen__c);

        DecisionResult d = EichrechtService.bewerteEichfrist(
            LadepunktSelector.byIds(new Set<Id>{eon.Id})[0], new List<Eingriff__c>(), Date.today());
        System.assertEquals(DecisionResult.Status.UNBEKANNT, d.ergebnis,
            'Ein importierter Ladepunkt ist eichrechtlich unbekannt, nicht unbedenklich.');
        System.assert(e.hinweis.contains('UNBEKANNT'),
            'Und der Import sagt es, statt es den Aufrufer entdecken zu lassen: ' + e.hinweis);
    }

    @IsTest
    static void faellitDerErsteSpiegelAusUebernimmtDerZweite() {
        Spiegel spiegel = new Spiegel(new List<Integer>{504, 200});
        Test.setMock(HttpCalloutMock.class, spiegel);

        Test.startTest();
        OsmLadepunktImport.Ergebnis e =
            OsmLadepunktImport.importiereBereich(52.51, 13.38, 52.53, 13.42, 10);
        Test.stopTest();

        // Measured against the live service: two of three attempts came back 502 or 504. A single
        // endpoint would make the demo a coin toss, so the fallback is not decoration.
        System.assertEquals(2, spiegel.versuche, 'Der zweite Spiegel wird tatsaechlich versucht.');
        System.assertEquals(4, e.uebernommen);
        System.assertEquals('callout:Overpass_Mirror', e.spiegel,
            'Das Ergebnis sagt, welcher Spiegel geantwortet hat.');
        System.assertEquals(1, [SELECT COUNT() FROM Integrationsfehler__c WHERE Statuscode__c = 504],
            'Und der Ausfall des ersten bleibt protokolliert, statt vom Erfolg des zweiten '
            + 'verdeckt zu werden.');
    }

    @IsTest
    static void faellenBeideSpiegelAusWirdNichtsBehauptet() {
        Test.setMock(HttpCalloutMock.class, new Spiegel(new List<Integer>{504, 502}));

        Test.startTest();
        OsmLadepunktImport.Ergebnis e =
            OsmLadepunktImport.importiereBereich(52.51, 13.38, 52.53, 13.42, 10);
        Test.stopTest();

        System.assertEquals(0, e.uebernommen);
        System.assert(e.hinweis.contains('Kein Overpass-Spiegel'),
            'Ein leerer Lauf muss sich melden: ein Aufruf, der nichts liefert, sieht aus wie einer, '
            + 'der nichts gefunden hat.');
        System.assertEquals(2, [SELECT COUNT() FROM Integrationsfehler__c]);
    }

    @IsTest
    static void einZweiterLaufAktualisiertStattZuVerdoppeln() {
        Test.setMock(HttpCalloutMock.class, new Spiegel(new List<Integer>{200}));

        Test.startTest();
        OsmLadepunktImport.importiereBereich(52.51, 13.38, 52.53, 13.42, 10);
        OsmLadepunktImport.importiereBereich(52.51, 13.38, 52.53, 13.42, 10);
        Test.stopTest();

        System.assertEquals(4, [SELECT COUNT() FROM Ladepunkt__c WHERE Datenquelle__c = 'OpenStreetMap'],
            'Der Upsert laeuft ueber die Quell-ID, sonst waere jeder naechtliche Lauf ein neuer Bestand.');
        System.assertEquals(2, [SELECT COUNT() FROM Account WHERE Name IN ('E.ON', 'Berliner Stadtwerke')],
            'Und der Betreiber wird beim zweiten Lauf gefunden, nicht noch einmal angelegt.');
    }

    @IsTest
    static void eineUnlesbareAntwortBrichtNichtDurch() {
        Test.setMock(HttpCalloutMock.class, new Gedrosselt());

        Test.startTest();
        OsmLadepunktImport.Ergebnis e =
            OsmLadepunktImport.importiereBereich(52.51, 13.38, 52.53, 13.42, 10);
        Test.stopTest();

        // Overpass answers 200 with an HTML error page when it is throttling, which is the worst
        // kind of failure: a success status carrying no data.
        System.assertEquals(0, e.uebernommen);
        System.assert(e.hinweis.contains('nicht lesbar'));
    }
}
