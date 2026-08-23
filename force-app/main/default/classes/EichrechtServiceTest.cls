/**
 * @description  The Eichrecht engine against sixteen fact patterns, through real DML.
 *
 *               No mocks, deliberately. Half of what the engine reads are formula fields on the
 *               event — whether a repair met all four § 37 Abs. 5 conditions, whether a software
 *               update is still waiting on approval — and those only carry a value once the
 *               platform has computed them. A mocked event would be asserting against a value the
 *               test itself invented.
 *
 *               The matrix mirrors the one seeded into the live org by
 *               `scripts/apex/seedEichrechtMatrix.apex`, so the same facts are checked against the
 *               declarative layer there and against the engine here. Case E is where they
 *               deliberately differ: the formula reports an expiry a year later than the statute
 *               allows, is recorded as DEFERRED in the live matrix, and is answered correctly here.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
@IsTest
private class EichrechtServiceTest {

    /** Fixed, not TODAY(). An expiry test that drifts with the calendar tests the calendar. */
    private static final Date STICHTAG = Date.newInstance(2026, 8, 23);

    private static Map<String, Ladepunkt__c> baueMatrix() {
        Map<String, Ladepunkt__c> lp = new Map<String, Ladepunkt__c>();
        lp.put('A', TestDataFactory.buildLadepunkt('A', Date.newInstance(2019, 3, 15)));
        lp.put('B', TestDataFactory.buildLadepunkt('B', Date.newInstance(2015, 6, 1)));
        lp.put('C', TestDataFactory.buildLadepunkt('C', Date.newInstance(2015, 6, 1)));
        lp.put('D', TestDataFactory.buildLadepunkt('D', Date.newInstance(2015, 6, 1)));
        lp.put('E', TestDataFactory.buildLadepunkt('E', Date.newInstance(2015, 6, 1)));
        lp.put('F', TestDataFactory.buildLadepunkt('F', Date.newInstance(2019, 3, 15)));
        lp.put('G', TestDataFactory.buildLadepunkt('G', Date.newInstance(2019, 3, 15)));
        lp.put('H', TestDataFactory.buildLadepunkt('H', Date.newInstance(2019, 3, 15)));
        lp.put('I', TestDataFactory.buildLadepunkt('I', null));
        lp.put('J', TestDataFactory.buildLadepunkt('J', Date.newInstance(2019, 3, 15)));
        lp.put('K', TestDataFactory.buildLadepunkt('K', Date.newInstance(2019, 3, 15)));
        lp.put('P', TestDataFactory.buildLadepunkt('P', Date.newInstance(2015, 6, 1)));
        lp.put('Q', TestDataFactory.buildLadepunkt('Q', Date.newInstance(2019, 3, 15)));
        lp.put('R', TestDataFactory.buildLadepunkt('R', null));

        lp.get('C').Nacheichung_beantragt_am__c = Date.newInstance(2023, 9, 1);
        lp.get('D').Nacheichung_beantragt_am__c = Date.newInstance(2023, 12, 15);
        for (String k : lp.keySet()) {
            lp.get(k).Standort_Adresse__c = k;
        }
        insert lp.values();

        Eingriff__c stillgelegt = TestDataFactory.buildEingriff(
            lp.get('P').Id, 'Nacheichung', Date.newInstance(2024, 3, 10));
        stillgelegt.Stilllegung_nachgewiesen__c = true;

        insert new List<Eingriff__c>{
            TestDataFactory.buildEingriff(lp.get('E').Id, 'Nacheichung', Date.newInstance(2024, 3, 10)),
            TestDataFactory.buildEingriff(lp.get('F').Id, 'Software-Update', Date.newInstance(2025, 2, 1)),
            TestDataFactory.buildEingriff(lp.get('G').Id, 'Eingriff', Date.newInstance(2022, 5, 1)),
            TestDataFactory.buildEingriff(lp.get('H').Id, 'Eingriff', Date.newInstance(2022, 5, 1)),
            TestDataFactory.buildEingriff(lp.get('H').Id, 'Nacheichung', Date.newInstance(2023, 1, 20)),
            TestDataFactory.buildInstandsetzung(lp.get('J').Id, Date.newInstance(2023, 4, 4),
                true, true, true, false),
            TestDataFactory.buildInstandsetzung(lp.get('K').Id, Date.newInstance(2023, 4, 4),
                true, true, true, true),
            stillgelegt,
            // Q: an intervention and a re-calibration recorded on the SAME day.
            TestDataFactory.buildEingriff(lp.get('Q').Id, 'Eingriff', Date.newInstance(2023, 5, 1)),
            TestDataFactory.buildEingriff(lp.get('Q').Id, 'Nacheichung', Date.newInstance(2023, 5, 1)),
            // R: no market-entry date, but a calibration - computable from § 34 Abs. 1 Satz 2 alone.
            TestDataFactory.buildEingriff(lp.get('R').Id, 'Nacheichung', Date.newInstance(2021, 7, 9))
        };
        return lp;
    }

    private static Map<String, DecisionResult> bewerteMatrix(Map<String, Ladepunkt__c> lp) {
        Map<Id, Ladepunkt__c> nachId = new Map<Id, Ladepunkt__c>(lp.values());
        Map<Id, DecisionResult> jeId = EichrechtService.bewerteEichfrist(nachId.keySet(), STICHTAG);
        Map<String, DecisionResult> jeSchluessel = new Map<String, DecisionResult>();
        for (String k : lp.keySet()) {
            jeSchluessel.put(k, jeId.get(lp.get(k).Id));
        }
        return jeSchluessel;
    }

    @IsTest
    static void matrix_liefertDasErgebnisDesGesetzes() {
        Map<String, DecisionResult.Status> erwartet = new Map<String, DecisionResult.Status>{
            'A' => DecisionResult.Status.GUELTIG,
            'B' => DecisionResult.Status.ABGELAUFEN,
            'C' => DecisionResult.Status.GESCHUETZT,
            'D' => DecisionResult.Status.ERMESSEN,
            'E' => DecisionResult.Status.GUELTIG,
            'F' => DecisionResult.Status.BETRIEB_GESPERRT,
            'G' => DecisionResult.Status.VORZEITIG_BEENDET,
            'H' => DecisionResult.Status.GUELTIG,
            'I' => DecisionResult.Status.UNBEKANNT,
            'J' => DecisionResult.Status.VORZEITIG_BEENDET,
            'K' => DecisionResult.Status.GUELTIG,
            'P' => DecisionResult.Status.GUELTIG,
            'Q' => DecisionResult.Status.GUELTIG,
            'R' => DecisionResult.Status.GUELTIG
        };

        Map<String, Ladepunkt__c> gebaut = baueMatrix();

        Test.startTest();
        Map<String, DecisionResult> ist = bewerteMatrix(gebaut);
        Test.stopTest();

        for (String k : erwartet.keySet()) {
            System.assertEquals(erwartet.get(k), ist.get(k).ergebnis,
                'Fall ' + k + ' — Begruendung: ' + ist.get(k).begruendung);
        }
    }

    @IsTest
    static void matrix_liefertDieFristenden() {
        Map<String, Date> erwartet = new Map<String, Date>{
            'A' => Date.newInstance(2027, 12, 31),
            'B' => Date.newInstance(2023, 12, 31),
            // Calibrated 2024-03-10, after the old period ended 2023-12-31: § 34 Abs. 1 Satz 3
            // backdates the new period to that end. The formula field says 2032 and is wrong by a
            // year in the operator's favour - this is the case the live matrix defers to here.
            'E' => Date.newInstance(2031, 12, 31),
            // Same facts, dormancy proven, so Satz 4 restores the calibration day.
            'P' => Date.newInstance(2032, 12, 31),
            'H' => Date.newInstance(2031, 12, 31),
            'Q' => Date.newInstance(2031, 12, 31),
            'R' => Date.newInstance(2029, 12, 31),
            'I' => null
        };

        Map<String, Ladepunkt__c> gebaut = baueMatrix();

        Test.startTest();
        Map<String, DecisionResult> ist = bewerteMatrix(gebaut);
        Test.stopTest();

        for (String k : erwartet.keySet()) {
            System.assertEquals(erwartet.get(k), ist.get(k).fristende, 'Fristende im Fall ' + k);
        }
    }

    @IsTest
    static void spaeteNacheichungZitiertSatz3UndDieRueckdatierungStimmtMitDemZitatUeberein() {
        Map<String, Ladepunkt__c> gebaut = baueMatrix();

        Test.startTest();
        Map<String, DecisionResult> ist = bewerteMatrix(gebaut);
        Test.stopTest();

        DecisionResult e = ist.get('E');
        System.assert(e.rechtsgrundlagen.contains('§ 34 Abs. 1 Satz 3 MessEV'),
            'Eine verspaetete Nacheichung muss Satz 3 zitieren. Zitiert: ' + e.rechtsgrundlagen);
        System.assert(!e.rechtsgrundlagen.contains('§ 34 Abs. 1 Satz 4 MessEV'),
            'Ohne nachgewiesene Stilllegung darf Satz 4 nicht zitiert werden.');
        // The citation and the arithmetic are produced by two different pieces of code, and this
        // is what binds them: Satz 3 backdates to the END of the previous period, so if it is
        // cited the new start must be exactly that date. Anything else means one of the two drifted.
        System.assertEquals(Date.newInstance(2023, 12, 31), e.fristbeginn,
            'Wer Satz 3 zitiert, muss auch auf das Ende der vorherigen Frist zurueckdatiert haben.');

        DecisionResult p = ist.get('P');
        System.assert(p.rechtsgrundlagen.contains('§ 34 Abs. 1 Satz 4 MessEV'),
            'Mit nachgewiesener Stilllegung greift Satz 4. Zitiert: ' + p.rechtsgrundlagen);
        System.assertEquals(Date.newInstance(2024, 3, 10), p.fristbeginn,
            'Satz 4 stellt auf den Tag der Eichung ab.');
    }

    @IsTest
    static void jedesErgebnisZitiertNurWasTatsaechlichGegriffenHat() {
        Map<String, Ladepunkt__c> gebaut = baueMatrix();

        Test.startTest();
        Map<String, DecisionResult> ist = bewerteMatrix(gebaut);
        Test.stopTest();

        System.assert(ist.get('A').rechtsgrundlagen.contains('§ 37 Abs. 1 Satz 2 MessEG'),
            'Die erste Frist beginnt mit dem Inverkehrbringen und muss das zitieren.');
        System.assert(!ist.get('A').rechtsgrundlagen.contains('§ 38 Satz 1 MessEG'),
            'Ein Ladepunkt in laufender Frist darf § 38 nicht zitieren - die Norm hat nicht '
            + 'gegriffen. Zitiert: ' + ist.get('A').rechtsgrundlagen);
        System.assert(ist.get('C').rechtsgrundlagen.contains('§ 38 Satz 1 MessEG'),
            'Der Schutz kommt aus § 38 Satz 1.');
        System.assert(ist.get('D').rechtsgrundlagen.contains('§ 38 Satz 2 MessEG'),
            'Das Ermessen kommt aus § 38 Satz 2.');
        System.assert(ist.get('F').rechtsgrundlagen.contains('§ 37 Abs. 6 MessEG'),
            'Die Betriebssperre kommt aus § 37 Abs. 6.');
        System.assert(ist.get('G').rechtsgrundlagen.contains('§ 37 Abs. 2 Nr. 2 MessEG'),
            'Die vorzeitige Beendigung kommt aus § 37 Abs. 2 Nr. 2.');
        System.assert(ist.get('I').rechtsgrundlagen.isEmpty(),
            'Ohne Aussage gibt es nichts zu zitieren. Zitiert: ' + ist.get('I').rechtsgrundlagen);
    }

    @IsTest
    static void jederParagraphInDerBegruendungStehtAuchInDenRechtsgrundlagen() {
        Map<String, Ladepunkt__c> gebaut = baueMatrix();

        Test.startTest();
        Map<String, DecisionResult> ist = bewerteMatrix(gebaut);
        Test.stopTest();

        // The invariant the transcript gate depends on. If the engine writes a sentence naming a
        // paragraph that its own citation list omits, then an agent repeating that sentence word
        // for word fails the gate - for the engine's mistake, not its own. So the engine may only
        // utter what it cites, and it is cheaper to enforce here than to debug there.
        Pattern paragraph = Pattern.compile('\u00a7\\s*(\\d+[a-z]?)');
        for (String k : ist.keySet()) {
            DecisionResult d = ist.get(k);
            if (String.isBlank(d.begruendung)) {
                continue;
            }
            Set<String> zitiert = new Set<String>();
            for (String norm : d.rechtsgrundlagen) {
                Matcher m = paragraph.matcher(norm);
                while (m.find()) {
                    zitiert.add(m.group(1));
                }
            }
            Matcher gesagt = paragraph.matcher(d.begruendung);
            while (gesagt.find()) {
                System.assert(zitiert.contains(gesagt.group(1)),
                    'Fall ' + k + ': die Begruendung nennt \u00a7 ' + gesagt.group(1)
                    + ', die Rechtsgrundlagen fuehren ihn aber nicht. Entweder gehoert die Norm '
                    + 'in die Liste oder der Paragraph aus dem Satz. Begruendung: ' + d.begruendung);
            }
        }
    }

    @IsTest
    static void eineNacheichungHeiltEinenFruererenEingriffAuchAmSelbenTag() {
        Map<String, Ladepunkt__c> gebaut = baueMatrix();

        Test.startTest();
        Map<String, DecisionResult> ist = bewerteMatrix(gebaut);
        Test.stopTest();

        System.assertEquals(DecisionResult.Status.GUELTIG, ist.get('H').ergebnis,
            'Fall H: der Eingriff von 2022 wird durch die Nacheichung von 2023 geheilt.');
        // Q is the ambiguous one: both events carry 2023-05-01 and the query returns them in no
        // guaranteed order. The service sorts a Nacheichung last on a tied date, so a device
        // calibrated the same day it was worked on reads as cured rather than as terminated.
        System.assertEquals(DecisionResult.Status.GUELTIG, ist.get('Q').ergebnis,
            'Fall Q: am selben Tag sortiert die Nacheichung nach dem Eingriff. Begruendung: '
            + ist.get('Q').begruendung);
    }

    @IsTest
    static void fehlendesInverkehrbringenIstEineLueckeUndKeineUnbedenklichkeit() {
        Map<String, Ladepunkt__c> gebaut = baueMatrix();

        Test.startTest();
        Map<String, DecisionResult> ist = bewerteMatrix(gebaut);
        Test.stopTest();

        DecisionResult i = ist.get('I');
        System.assertEquals(DecisionResult.Status.UNBEKANNT, i.ergebnis);
        System.assert(!i.hatAussage(), 'UNBEKANNT ist keine Aussage ueber den Ladepunkt.');
        System.assertEquals(null, i.fristende, 'Ohne Fristbeginn gibt es kein Fristende.');

        // R has no market-entry date either, but it has a calibration - so § 34 Abs. 1 Satz 2 can
        // open a period on its own. The answer is computable and the reasoning says openly that
        // lateness could not be tested, because there was no previous period to be late against.
        DecisionResult r = ist.get('R');
        System.assertEquals(DecisionResult.Status.GUELTIG, r.ergebnis);
        System.assert(r.begruendung.contains('Inverkehrbringen ist nicht erfasst'),
            'Die Begruendung muss offenlegen, dass die erste Frist unbestimmt blieb: '
            + r.begruendung);
    }

    @IsTest
    static void derselbeLadepunktAendertSeineAntwortMitDemStichtag() {
        Map<String, Ladepunkt__c> lp = baueMatrix();
        Ladepunkt__c a = [SELECT Id, Inverkehrbringen__c, Nacheichung_beantragt_am__c
                          FROM Ladepunkt__c WHERE Id = :lp.get('A').Id LIMIT 1];

        Test.startTest();
        DecisionResult vorher = EichrechtService.bewerteEichfrist(
            a, new List<Eingriff__c>(), Date.newInstance(2027, 12, 31));
        DecisionResult nachher = EichrechtService.bewerteEichfrist(
            a, new List<Eingriff__c>(), Date.newInstance(2028, 1, 1));
        Test.stopTest();

        // The last lawful day and the first unlawful one, on identical facts. This is what the
        // Stichtag parameter buys: the answer is a function of the day, and both days are testable.
        System.assertEquals(DecisionResult.Status.GUELTIG, vorher.ergebnis,
            'Am 31.12.2027 laeuft die Frist noch.');
        System.assertEquals(DecisionResult.Status.ABGELAUFEN, nachher.ergebnis,
            'Einen Tag spaeter ist sie abgelaufen.');
        System.assertEquals(Date.newInstance(2028, 1, 1), nachher.stichtag,
            'Ein Fristergebnis ohne seinen Stichtag ist keines.');
    }

    @IsTest
    static void paragraph38IstAufLaufendeFristenNichtAnwendbar() {
        Map<String, Ladepunkt__c> lp = baueMatrix();
        Ladepunkt__c a = [SELECT Id, Inverkehrbringen__c, Nacheichung_beantragt_am__c
                          FROM Ladepunkt__c WHERE Id = :lp.get('A').Id LIMIT 1];
        Ladepunkt__c c = [SELECT Id, Inverkehrbringen__c, Nacheichung_beantragt_am__c
                          FROM Ladepunkt__c WHERE Id = :lp.get('C').Id LIMIT 1];
        Ladepunkt__c i = [SELECT Id, Inverkehrbringen__c, Nacheichung_beantragt_am__c
                          FROM Ladepunkt__c WHERE Id = :lp.get('I').Id LIMIT 1];

        Test.startTest();
        DecisionResult laufend = EichrechtService.pruefeVerspaeteteEichung(
            a, new List<Eingriff__c>(), STICHTAG);
        DecisionResult abgelaufen = EichrechtService.pruefeVerspaeteteEichung(
            c, new List<Eingriff__c>(), STICHTAG);
        DecisionResult ohneDaten = EichrechtService.pruefeVerspaeteteEichung(
            i, new List<Eingriff__c>(), STICHTAG);
        Test.stopTest();

        // The distinction the whole class exists for. Neither of these is "not protected".
        System.assertEquals(DecisionResult.Status.NICHT_ANWENDBAR, laufend.ergebnis,
            '§ 38 regelt verspaetete Eichungen und sagt ueber eine laufende Frist nichts.');
        System.assert(laufend.rechtsgrundlagen.contains('§ 38 Satz 1 MessEG'),
            'Auch die Feststellung der Nichtanwendbarkeit stuetzt sich auf die Norm selbst.');
        System.assertEquals(DecisionResult.Status.UNBEKANNT, ohneDaten.ergebnis,
            'Fehlende Daten sind etwas anderes als eine nicht anwendbare Norm.');
        System.assert(!laufend.hatAussage() && !ohneDaten.hatAussage(),
            'Beide sind Nicht-Antworten und duerfen nicht als Ergebnis gelesen werden.');
        System.assertEquals(DecisionResult.Status.GESCHUETZT, abgelaufen.ergebnis,
            'Nach Ablauf beantwortet dieselbe Methode die Schutzfrage.');
    }

    @IsTest
    static void ohneLadepunktUndOhneIdsBleibtDieAntwortLeerStattFalsch() {
        Test.startTest();
        DecisionResult ohne = EichrechtService.bewerteEichfrist(null, null, STICHTAG);
        DecisionResult ohne38 = EichrechtService.pruefeVerspaeteteEichung(null, null, STICHTAG);
        Map<Id, DecisionResult> leer = EichrechtService.bewerteEichfrist(new Set<Id>(), STICHTAG);
        Test.stopTest();

        System.assertEquals(DecisionResult.Status.UNBEKANNT, ohne.ergebnis);
        System.assertEquals(DecisionResult.Status.UNBEKANNT, ohne38.ergebnis);
        System.assert(leer.isEmpty(), 'Keine Ids, keine Ergebnisse - und keine Ausnahme.');
    }

    @IsTest
    static void ohneStichtagGiltHeute() {
        Map<String, Ladepunkt__c> lp = baueMatrix();
        Ladepunkt__c b = [SELECT Id, Inverkehrbringen__c, Nacheichung_beantragt_am__c
                          FROM Ladepunkt__c WHERE Id = :lp.get('B').Id LIMIT 1];

        Test.startTest();
        DecisionResult r = EichrechtService.bewerteEichfrist(b, new List<Eingriff__c>());
        Test.stopTest();

        System.assertEquals(Date.today(), r.stichtag,
            'Die Kurzform beantwortet die Frage fuer heute.');
    }

    @IsTest
    static void undatierteEreignisseVerschiebenNichtsStattFalschEinsortiertZuWerden() {
        Ladepunkt__c lp = TestDataFactory.buildLadepunkt('S', Date.newInstance(2019, 3, 15));
        insert lp;
        // An event without a date cannot be placed in a chronology. Dropping it is honest;
        // guessing a position for it would silently change the answer.
        Eingriff__c ohneDatum = TestDataFactory.buildEingriff(lp.Id, 'Eingriff', null);
        insert ohneDatum;

        Ladepunkt__c geladen = [SELECT Id, Inverkehrbringen__c, Nacheichung_beantragt_am__c
                                FROM Ladepunkt__c WHERE Id = :lp.Id LIMIT 1];
        List<Eingriff__c> ereignisse = LadepunktSelector.eingriffeByLadepunkt(new Set<Id>{lp.Id});

        Test.startTest();
        DecisionResult r = EichrechtService.bewerteEichfrist(geladen, ereignisse, STICHTAG);
        Test.stopTest();

        System.assertEquals(DecisionResult.Status.GUELTIG, r.ergebnis,
            'Ein undatierter Eingriff darf die Frist nicht vorzeitig beenden.');
        System.assertEquals(Date.newInstance(2027, 12, 31), r.fristende);
    }
}
