/**
 * @description  Tests for the action the agent is allowed to call.
 *
 *               What is checked here is not the legal reasoning — that is tested in
 *               EichrechtServiceTest — but the contract the agent depends on: that a question about
 *               a charge point that does not exist produces a refusal rather than a status, that
 *               the findings arrive with the urgent ones first, and above all that the list of
 *               provisions contains only what the engine actually applied. The last one is the
 *               transcript gate's foundation: a paragraph in that list was handed over, and a
 *               paragraph outside it was invented.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
@IsTest
private class PruefeEichfristenTest {

    private static final String BETREIBER = 'Stadtwerke Musterstadt GmbH';

    private static Map<String, Ladepunkt__c> baueBestand() {
        Account betreiber = TestDataFactory.buildBetreiber(BETREIBER);
        insert betreiber;

        Map<String, Ladepunkt__c> lp = new Map<String, Ladepunkt__c>{
            'laufend'    => TestDataFactory.buildLadepunkt('laufend', Date.today().addYears(-3)),
            'abgelaufen' => TestDataFactory.buildLadepunkt('abgelaufen', Date.newInstance(Date.today().year() - 10, 3, 1)),
            'gesperrt'   => TestDataFactory.buildLadepunkt('gesperrt', Date.today().addYears(-2)),
            'ohneDatum'  => TestDataFactory.buildLadepunkt('ohneDatum', null)
        };
        for (String k : lp.keySet()) {
            lp.get(k).Betreiber__c = betreiber.Id;
        }
        insert lp.values();
        insert TestDataFactory.buildEingriff(lp.get('gesperrt').Id, 'Software-Update', Date.today().addMonths(-4));

        Map<String, Ladepunkt__c> mitNamen = new Map<String, Ladepunkt__c>();
        for (Ladepunkt__c geladen : [SELECT Id, Name, Standort_Adresse__c FROM Ladepunkt__c]) {
            mitNamen.put(geladen.Standort_Adresse__c, geladen);
        }
        return mitNamen;
    }

    private static PruefeEichfristen.Antwort frage(String nummer, String betreiber) {
        PruefeEichfristen.Anfrage a = new PruefeEichfristen.Anfrage();
        a.ladepunktNummer = nummer;
        a.betreiber = betreiber;
        return PruefeEichfristen.pruefe(new List<PruefeEichfristen.Anfrage>{a})[0];
    }

    @IsTest
    static void eineNummerLiefertGenauEinenBefundMitRechtsgrundlagen() {
        Map<String, Ladepunkt__c> bestand = baueBestand();

        Test.startTest();
        PruefeEichfristen.Antwort a = frage(bestand.get('laufend').Name, null);
        Test.stopTest();

        System.assertEquals(1, a.anzahlGeprueft);
        System.assertEquals(0, a.anzahlHandlungsbedarf);
        System.assertEquals(1, a.befunde.size());
        System.assert(a.befunde[0].startsWith(bestand.get('laufend').Name),
            'Ein Befund nennt zuerst den Ladepunkt: ' + a.befunde[0]);
        System.assert(!a.rechtsgrundlagen.isEmpty(),
            'Eine Aussage ohne Rechtsgrundlage waere fuer das Gate unpruefbar.');
        System.assertEquals(Date.today(), a.stichtag);
        System.assertEquals(null, a.hinweis, 'Ein Treffer braucht keinen Hinweis.');
    }

    @IsTest
    static void derBestandEinesBetreibersWirdKomplettGeprueftUndDringendesZuerstGenannt() {
        baueBestand();

        Test.startTest();
        PruefeEichfristen.Antwort a = frage(null, 'Musterstadt');
        Test.stopTest();

        System.assertEquals(4, a.anzahlGeprueft,
            'Ein Namensfragment muss den ganzen Bestand finden - Menschen zitieren selten den '
            + 'vollen Firmennamen.');
        System.assertEquals(3, a.anzahlHandlungsbedarf,
            'Gesperrt, abgelaufen und ohne bestimmbaren Status erfordern eine Massnahme.');
        System.assertEquals(4, a.befunde.size());

        // Order is part of the answer: whoever listens to a list hears the first item best.
        for (Integer i = 0; i < a.anzahlHandlungsbedarf; i++) {
            System.assert(!a.befunde[i].contains('(gültig geeicht)'),
                'Ein unauffaelliger Ladepunkt steht vor einem handlungsbeduerftigen: ' + a.befunde[i]);
        }
        System.assert(a.befunde[3].contains('(gültig geeicht)'),
            'Und der unauffaellige steht am Ende: ' + a.befunde[3]);
    }

    @IsTest
    static void eineDatenlueckeGiltAlsHandlungsbedarfUndNichtAlsRuhe() {
        Map<String, Ladepunkt__c> bestand = baueBestand();

        Test.startTest();
        PruefeEichfristen.Antwort a = frage(bestand.get('ohneDatum').Name, null);
        Test.stopTest();

        // The quiet failure this guards against: a record with a missing date reported as "nothing
        // to report". It is an open question, and an agent filing it under calm has answered wrong.
        System.assertEquals(1, a.anzahlHandlungsbedarf,
            'Ohne bestimmbaren Status ist etwas zu tun: ' + a.zusammenfassung);
        System.assert(a.zusammenfassung.contains('ohne bestimmbaren Status'),
            'Und die Zusammenfassung sagt es beim Namen: ' + a.zusammenfassung);
        System.assert(!a.zusammenfassung.contains('Kein Handlungsbedarf'));
    }

    @IsTest
    static void esWerdenNurDieVorschriftenGenanntDieWirklichGegriffenHaben() {
        Map<String, Ladepunkt__c> bestand = baueBestand();

        Test.startTest();
        PruefeEichfristen.Antwort laufend = frage(bestand.get('laufend').Name, null);
        PruefeEichfristen.Antwort abgelaufen = frage(bestand.get('abgelaufen').Name, null);
        Test.stopTest();

        // The foundation of the transcript gate. A charge point inside its period must not hand the
        // agent § 38 - if it did, the agent could cite the grace rule about a device the rule says
        // nothing about, and the gate would wave it through because the paragraph was on the list.
        System.assert(!laufend.rechtsgrundlagen.contains('§ 38 Satz 1 MessEG'),
            'Eine laufende Frist darf § 38 nicht mitgeben. Mitgegeben: ' + laufend.rechtsgrundlagen);
        System.assert(!laufend.rechtsgrundlagen.contains('§ 38 Satz 2 MessEG'),
            'Auch nicht Satz 2. Mitgegeben: ' + laufend.rechtsgrundlagen);
        System.assert(laufend.rechtsgrundlagen.contains('§ 37 Abs. 1 Satz 2 MessEG'),
            'Aber die Norm, die die Frist eroeffnet hat, gehoert dazu.');
        System.assert(abgelaufen.rechtsgrundlagen.contains('MessEV Anlage 7 Tabelle 1 Nr. 6.7'),
            'Und die Tabelle, aus der die acht Jahre stammen.');
    }

    @IsTest
    static void eineUnbekannteNummerErgibtEineAbsageUndKeinenStatus() {
        baueBestand();

        Test.startTest();
        PruefeEichfristen.Antwort a = frage('LP-99999', null);
        Test.stopTest();

        System.assertEquals(0, a.anzahlGeprueft);
        System.assert(a.befunde.isEmpty(), 'Ohne Treffer gibt es nichts zu berichten.');
        System.assert(a.rechtsgrundlagen.isEmpty(),
            'Und nichts zu zitieren - sonst koennte der Agent einen Paragraphen nennen, der zu '
            + 'keiner Pruefung gehoert.');
        System.assert(a.hinweis.contains('LP-99999'),
            'Der Hinweis nennt, wonach gesucht wurde: ' + a.hinweis);
        System.assert(a.hinweis.contains('kein Status'),
            'Und weist den Agenten ausdruecklich an, keinen Status zu nennen: ' + a.hinweis);
    }

    @IsTest
    static void ohneJedeEingabeWirdNachgefragtStattGeraten() {
        baueBestand();

        Test.startTest();
        PruefeEichfristen.Antwort a = frage(null, null);
        Test.stopTest();

        System.assertEquals(0, a.anzahlGeprueft);
        System.assert(a.hinweis.contains('erfragen'),
            'Bei fehlender Eingabe wird nachgefragt, nicht der gesamte Bestand geprueft: '
            + a.hinweis);
    }

    @IsTest
    static void einStichtagInDerZukunftAendertDieAntwort() {
        Map<String, Ladepunkt__c> bestand = baueBestand();
        PruefeEichfristen.Anfrage heute = new PruefeEichfristen.Anfrage();
        heute.ladepunktNummer = bestand.get('laufend').Name;
        PruefeEichfristen.Anfrage spaeter = new PruefeEichfristen.Anfrage();
        spaeter.ladepunktNummer = bestand.get('laufend').Name;
        spaeter.stichtag = Date.newInstance(Date.today().year() + 9, 1, 1);

        Test.startTest();
        List<PruefeEichfristen.Antwort> antworten = PruefeEichfristen.pruefe(
            new List<PruefeEichfristen.Anfrage>{heute, spaeter});
        Test.stopTest();

        // Two requests, two answers, same order - the platform bulkifies and the contract has to
        // survive it. And the Stichtag is genuinely honoured rather than accepted and ignored.
        System.assertEquals(2, antworten.size());
        System.assertEquals(0, antworten[0].anzahlHandlungsbedarf, 'Heute laeuft die Frist noch.');
        System.assertEquals(1, antworten[1].anzahlHandlungsbedarf,
            'In neun Jahren nicht mehr: ' + antworten[1].zusammenfassung);
        System.assertEquals(spaeter.stichtag, antworten[1].stichtag,
            'Die Antwort traegt den Tag, fuer den sie gilt.');
    }

    @IsTest
    static void eineLeereListeErgibtEineLeereAntwortUndKeineAusnahme() {
        Test.startTest();
        List<PruefeEichfristen.Antwort> leer =
            PruefeEichfristen.pruefe(new List<PruefeEichfristen.Anfrage>());
        List<PruefeEichfristen.Antwort> ohne = PruefeEichfristen.pruefe(null);
        Test.stopTest();

        System.assert(leer.isEmpty());
        System.assert(ohne.isEmpty());
    }
}
