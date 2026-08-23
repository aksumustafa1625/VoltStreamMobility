/**
 * @description  Proof that German survives the trip from the engine to the agent.
 *
 *               This exists because the opposite is easy to do by accident. A developer who
 *               escapes invocable output "to be safe" turns every ü into &uuml; and every § into
 *               &sect;, and the damage is invisible in Apex — it only appears in what the agent
 *               says, in a language the developer may not read. The rule is written in the project
 *               guide; this class is the rule with teeth, including one test that demonstrates the
 *               damage rather than merely forbidding it.
 *
 *               The proxy for the platform's serialisation is JSON, because that is what the
 *               platform does: an invocable's output is serialised to JSON before the planner ever
 *               sees it.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
@IsTest
private class GermanTextSerializationTest {

    /** Umlauts in both cases, the sharp s, the section sign, German quotes and an en dash. */
    private static final String PROBE =
        'Prüfung: Eichfrist für Ladesäulen – § 34 Abs. 1 MessEV, „Tag der Eichung", Größe 4,2 kW, Straße';

    private static final List<String> ZERSTOERT_DURCH_ESCAPING = new List<String>{
        '&uuml;', '&auml;', '&ouml;', '&szlig;', '&sect;', '&Uuml;', '&amp;'
    };

    @IsTest
    static void dieAntwortDerAktionUeberstehtDieSerialisierungUnveraendert() {
        PruefeEichfristen.Antwort antwort = new PruefeEichfristen.Antwort();
        antwort.zusammenfassung = PROBE;
        antwort.befunde = PROBE;
        antwort.rechtsgrundlagen = '§ 34 Abs. 1 Satz 3 MessEV';
        antwort.hinweis = PROBE;

        Test.startTest();
        String serialisiert = JSON.serialize(antwort);
        PruefeEichfristen.Antwort zurueck =
            (PruefeEichfristen.Antwort) JSON.deserialize(serialisiert, PruefeEichfristen.Antwort.class);
        Test.stopTest();

        System.assertEquals(PROBE, zurueck.zusammenfassung,
            'Der Text muss unveraendert zurueckkommen - Zeichen fuer Zeichen.');
        System.assertEquals(PROBE, zurueck.befunde);
        System.assertEquals(PROBE, zurueck.hinweis);
        System.assertEquals('§ 34 Abs. 1 Satz 3 MessEV', zurueck.rechtsgrundlagen,
            'Das Paragraphenzeichen traegt das Transkript-Gate. Geht es verloren, vergleicht das '
            + 'Gate zwei Zeichenfolgen, die nie uebereinstimmen koennen.');
    }

    @IsTest
    static void imSerialisiertenTextStehtKeineHtmlEntitaet() {
        PruefeEichfristen.Antwort antwort = new PruefeEichfristen.Antwort();
        antwort.zusammenfassung = PROBE;
        antwort.befunde = PROBE;

        Test.startTest();
        String serialisiert = JSON.serialize(antwort);
        Test.stopTest();

        for (String entitaet : ZERSTOERT_DURCH_ESCAPING) {
            System.assert(!serialisiert.contains(entitaet),
                'Die serialisierte Antwort enthaelt ' + entitaet + '. Irgendwo wurde escapeHtml4 '
                + 'angewendet - der Planner liest dann Entitaeten statt deutscher Woerter.');
        }
        System.assert(serialisiert.contains('ü') && serialisiert.contains('§') && serialisiert.contains('ß'),
            'Und die Zeichen selbst muessen tatsaechlich im JSON stehen.');
    }

    @IsTest
    static void escapeHtml4WuerdeGenauDasZerstoeren() {
        // Demonstrated rather than asserted as folklore. The project guide forbids escapeHtml4 on
        // anything the planner reads; this is what that rule is protecting against, in numbers.
        Test.startTest();
        String geschaedigt = 'Prüfung nach § 34 – Größe'.escapeHtml4();
        Test.stopTest();

        System.assert(geschaedigt.contains('&uuml;'),
            'escapeHtml4 macht aus ü eine Entitaet: ' + geschaedigt);
        System.assert(geschaedigt.contains('&sect;'),
            'Und aus § ebenfalls: ' + geschaedigt);
        System.assertNotEquals('Prüfung nach § 34 – Größe', geschaedigt,
            'Waere das Ergebnis gleich, waere die Regel ueberfluessig - und sie ist es nicht.');
    }

    @IsTest
    static void derNormenkorpusLiefertUnversehrtenWortlaut() {
        // The corpus is deployed metadata, so its text passed through XML, a deploy and a
        // retrieve before it ever reaches Apex. Every one of those is a chance to lose an umlaut.
        Test.startTest();
        Rechtsnorm__mdt norm = Rechtsnorm__mdt.getInstance('MessEV_34_1_3');
        Rechtsnorm__mdt anlage = Rechtsnorm__mdt.getInstance('MessEV_Anlage7_Tab1_Nr6_7');
        Test.stopTest();

        System.assert(norm.Wortlaut__c.contains('Messgerät'),
            'Der Wortlaut kommt mit Umlaut aus dem Korpus: ' + norm.Wortlaut__c);
        System.assert(norm.Norm__c.startsWith('§'),
            'Und das Zitat beginnt mit dem Paragraphenzeichen: ' + norm.Norm__c);
        System.assert(anlage.Wortlaut__c.contains('Elektrofahrzeuge'),
            'Auch der Anlagentext ueberlebt Deploy und Retrieve.');
        for (String entitaet : ZERSTOERT_DURCH_ESCAPING) {
            System.assert(!norm.Wortlaut__c.contains(entitaet),
                'Im Korpus steht eine HTML-Entitaet: ' + entitaet);
        }
    }

    @IsTest
    static void dieAktionGibtDeutschenTextAusEchtenDatenZurueck() {
        Ladepunkt__c lp = TestDataFactory.buildLadepunkt('Straße 4', Date.today().addYears(-3));
        insert lp;
        Ladepunkt__c geladen = [SELECT Name FROM Ladepunkt__c WHERE Id = :lp.Id LIMIT 1];

        PruefeEichfristen.Anfrage a = new PruefeEichfristen.Anfrage();
        a.ladepunktNummer = geladen.Name;

        Test.startTest();
        List<PruefeEichfristen.Antwort> antworten =
            PruefeEichfristen.pruefe(new List<PruefeEichfristen.Anfrage>{a});
        String serialisiert = JSON.serialize(antworten);
        Test.stopTest();

        // End to end: corpus text through the engine's sentences into the action's output, with
        // nothing along the way flattening a German character.
        System.assert(antworten[0].zusammenfassung.contains('gültig geeicht'),
            'Die Zusammenfassung traegt den Umlaut: ' + antworten[0].zusammenfassung);
        System.assert(antworten[0].rechtsgrundlagen.contains('§'),
            'Die Rechtsgrundlagen tragen das Paragraphenzeichen: '
            + antworten[0].rechtsgrundlagen);
        for (String entitaet : ZERSTOERT_DURCH_ESCAPING) {
            System.assert(!serialisiert.contains(entitaet),
                'Auf dem Weg durch die Aktion entstand ' + entitaet + '.');
        }
    }
}
