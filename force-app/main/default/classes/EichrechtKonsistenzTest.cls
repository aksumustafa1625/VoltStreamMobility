/**
 * @description  Holds the two compliance layers against each other: the formula field a reviewer
 *               reads in a list view, and the Apex engine that walks the event history.
 *
 *               Ten fact patterns where they must agree, and two where they knowingly do not. The
 *               divergences are named in DIVERGENZEN, so a third one appearing is a decision
 *               somebody makes on purpose rather than a number quietly changing in a document. The
 *               same test asserts that the two named divergences are *still there* — otherwise
 *               fixing the formula would leave a stale exemption behind, passing forever and
 *               testing nothing.
 *
 *               Every date here is relative to today, because the formula is built on TODAY() and
 *               fixed dates would make this test rot: a case that is GUELTIG in 2026 is ABGELAUFEN
 *               in 2033, and a suite that starts failing on a calendar boundary teaches nobody
 *               anything. Relative fixtures mean both layers are always asked the same question.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
@IsTest
private class EichrechtKonsistenzTest {

    private static final Date HEUTE = Date.today();

    /**
     * The cases where the declarative layer is knowingly wrong, both for the same reason: a
     * formula cannot see that a Nacheichung was already late, so it takes the favourable branch
     * of § 34 Abs. 1 and skips the backdating Satz 3 imposes.
     */
    private static final Set<String> DIVERGENZEN = new Set<String>{'SPAET_DATUM', 'SPAET_STATUS'};

    private static Map<String, Id> baueFaelle() {
        Map<String, Ladepunkt__c> lp = new Map<String, Ladepunkt__c>();

        lp.put('LAUFEND',          TestDataFactory.buildLadepunkt('LAUFEND', HEUTE.addYears(-3)));
        lp.put('ABGELAUFEN',       TestDataFactory.buildLadepunkt('ABGELAUFEN', Date.newInstance(HEUTE.year() - 10, 3, 1)));
        lp.put('GESCHUETZT',       TestDataFactory.buildLadepunkt('GESCHUETZT', Date.newInstance(HEUTE.year() - 10, 3, 1)));
        lp.put('ERMESSEN',         TestDataFactory.buildLadepunkt('ERMESSEN', Date.newInstance(HEUTE.year() - 10, 3, 1)));
        lp.put('GESPERRT',         TestDataFactory.buildLadepunkt('GESPERRT', HEUTE.addYears(-3)));
        lp.put('BEENDET',          TestDataFactory.buildLadepunkt('BEENDET', HEUTE.addYears(-3)));
        lp.put('GEHEILT',          TestDataFactory.buildLadepunkt('GEHEILT', HEUTE.addYears(-3)));
        lp.put('UNBEKANNT',        TestDataFactory.buildLadepunkt('UNBEKANNT', null));
        lp.put('REPARIERT_OK',     TestDataFactory.buildLadepunkt('REPARIERT_OK', HEUTE.addYears(-3)));
        lp.put('REPARIERT_MANGEL', TestDataFactory.buildLadepunkt('REPARIERT_MANGEL', HEUTE.addYears(-3)));

        // Placed on the market ten years ago, so the first period ended two calendar years back;
        // re-calibrated last year, i.e. after that end. Both layers still say the period runs —
        // they disagree only about when it ends, by exactly the lateness Satz 3 deducts.
        lp.put('SPAET_DATUM',      TestDataFactory.buildLadepunkt('SPAET_DATUM', Date.newInstance(HEUTE.year() - 10, 6, 1)));

        // The same defect pushed until it changes the answer rather than only the date. Seventeen
        // years on the market puts the first period's end nine years back; the re-calibration a
        // year later gives the engine a period that ran out last year, while the formula counts
        // eight years from the calibration day and lands at the end of this one.
        lp.put('SPAET_STATUS',     TestDataFactory.buildLadepunkt('SPAET_STATUS', Date.newInstance(HEUTE.year() - 17, 3, 1)));

        Date ersteFristEnde = Date.newInstance(HEUTE.year() - 2, 12, 31);
        lp.get('GESCHUETZT').Nacheichung_beantragt_am__c = ersteFristEnde.addDays(-100);
        lp.get('ERMESSEN').Nacheichung_beantragt_am__c = ersteFristEnde.addDays(-10);

        for (String k : lp.keySet()) {
            lp.get(k).Standort_Adresse__c = k;
        }
        insert lp.values();

        insert new List<Eingriff__c>{
            TestDataFactory.buildEingriff(lp.get('GESPERRT').Id, 'Software-Update', HEUTE.addYears(-1)),
            TestDataFactory.buildEingriff(lp.get('BEENDET').Id, 'Eingriff', HEUTE.addYears(-2)),
            TestDataFactory.buildEingriff(lp.get('GEHEILT').Id, 'Eingriff', HEUTE.addYears(-2)),
            TestDataFactory.buildEingriff(lp.get('GEHEILT').Id, 'Nacheichung', HEUTE.addYears(-1)),
            TestDataFactory.buildInstandsetzung(lp.get('REPARIERT_OK').Id, HEUTE.addYears(-1),
                true, true, true, true),
            TestDataFactory.buildInstandsetzung(lp.get('REPARIERT_MANGEL').Id, HEUTE.addYears(-1),
                true, true, true, false),
            TestDataFactory.buildEingriff(lp.get('SPAET_DATUM').Id, 'Nacheichung',
                Date.newInstance(HEUTE.year() - 1, 3, 10)),
            TestDataFactory.buildEingriff(lp.get('SPAET_STATUS').Id, 'Nacheichung',
                Date.newInstance(HEUTE.year() - 8, 6, 15))
        };

        Map<String, Id> ids = new Map<String, Id>();
        for (String k : lp.keySet()) {
            ids.put(k, lp.get(k).Id);
        }
        return ids;
    }

    @IsTest
    static void beideSchichtenStimmenUeberall_ausserWoEsSoEntschiedenIst() {
        Map<String, Id> ids = baueFaelle();

        Test.startTest();
        Map<Id, DecisionResult> motor = EichrechtService.bewerteEichfrist(
            new Set<Id>(ids.values()), HEUTE);
        Map<Id, Ladepunkt__c> geladen = new Map<Id, Ladepunkt__c>(
            LadepunktSelector.byIds(new Set<Id>(ids.values())));
        Test.stopTest();

        for (String k : ids.keySet()) {
            Ladepunkt__c lp = geladen.get(ids.get(k));
            DecisionResult.Status formel = DecisionResult.ausEichstatusFormel(lp.Eichstatus__c);
            DecisionResult.Status apex = motor.get(ids.get(k)).ergebnis;

            System.assertNotEquals(null, formel,
                'Die Formel liefert "' + lp.Eichstatus__c + '", und DecisionResult kann das nicht '
                + 'zuordnen. Entweder wurde die Formel geaendert oder die Zuordnung - beides muss '
                + 'gemeinsam passieren.');

            if (DIVERGENZEN.contains(k)) {
                continue;
            }
            System.assertEquals(apex, formel,
                'Fall ' + k + ': die Listenansicht sagt ' + formel + ', der Motor sagt ' + apex
                + '. Wenn das gewollt ist, gehoert der Fall nach DIVERGENZEN - mit einer '
                + 'Begruendung. Motor: ' + motor.get(ids.get(k)).begruendung);
        }
    }

    @IsTest
    static void dieFormelIstBeiVerspaeteterNacheichungGenauEinJahrZuGrosszuegig() {
        Map<String, Id> ids = baueFaelle();

        Test.startTest();
        Map<Id, DecisionResult> motor = EichrechtService.bewerteEichfrist(
            new Set<Id>(ids.values()), HEUTE);
        Map<Id, Ladepunkt__c> geladen = new Map<Id, Ladepunkt__c>(
            LadepunktSelector.byIds(new Set<Id>(ids.values())));
        Test.stopTest();

        Ladepunkt__c lp = geladen.get(ids.get('SPAET_DATUM'));
        DecisionResult r = motor.get(ids.get('SPAET_DATUM'));

        // Not merely "they differ" - the size and the direction of the difference are the finding,
        // and asserting them is what would catch a formula change that made things worse.
        System.assertEquals(r.fristende.year() + 1, lp.Eichfrist_Ende__c.year(),
            'Die Formel muss genau ein Jahr spaeter enden als der Motor: sie rechnet ab dem Tag '
            + 'der Eichung statt ab dem Ende der abgelaufenen Frist.');
        System.assert(lp.Eichfrist_Ende__c > r.fristende,
            'Die Abweichung geht immer zugunsten des Betreibers - das ist die gefaehrliche '
            + 'Richtung und der Grund, warum der Motor hier entscheidet.');
        System.assertEquals(DecisionResult.Status.GUELTIG, r.ergebnis,
            'Beide Schichten halten die Frist hier noch fuer laufend; nur das Ende unterscheidet sich.');
    }

    @IsTest
    static void beiGrossemVerzugSagtDieListeGueltigUndDerMotorAbgelaufen() {
        Map<String, Id> ids = baueFaelle();

        Test.startTest();
        Map<Id, DecisionResult> motor = EichrechtService.bewerteEichfrist(
            new Set<Id>(ids.values()), HEUTE);
        Map<Id, Ladepunkt__c> geladen = new Map<Id, Ladepunkt__c>(
            LadepunktSelector.byIds(new Set<Id>(ids.values())));
        Test.stopTest();

        Ladepunkt__c lp = geladen.get(ids.get('SPAET_STATUS'));
        DecisionResult r = motor.get(ids.get('SPAET_STATUS'));

        // The whole argument for the engine, in one assertion. The list view reports a charge
        // point as calibrated that the ordinance says has been out of calibration since last year.
        System.assertEquals(DecisionResult.Status.GUELTIG,
            DecisionResult.ausEichstatusFormel(lp.Eichstatus__c),
            'Die Listenansicht haelt diesen Ladepunkt fuer gueltig geeicht.');
        System.assertEquals(DecisionResult.Status.ABGELAUFEN, r.ergebnis,
            'Der Motor rechnet die Rueckdatierung nach § 34 Abs. 1 Satz 3 und kommt auf abgelaufen. '
            + 'Begruendung: ' + r.begruendung);
        System.assert(r.rechtsgrundlagen.contains('§ 34 Abs. 1 Satz 3 MessEV'),
            'Und er nennt die Norm, die den Unterschied macht. Zitiert: ' + r.rechtsgrundlagen);
    }

    @IsTest
    static void dieAusnahmelisteEnthaeltNurFaelleDieWirklichAbweichen() {
        Map<String, Id> ids = baueFaelle();

        Test.startTest();
        Map<Id, DecisionResult> motor = EichrechtService.bewerteEichfrist(
            new Set<Id>(ids.values()), HEUTE);
        Map<Id, Ladepunkt__c> geladen = new Map<Id, Ladepunkt__c>(
            LadepunktSelector.byIds(new Set<Id>(ids.values())));
        Test.stopTest();

        // Without this, repairing the formula would leave the exemption standing: the suite would
        // stay green while silently excusing a case that no longer needs excusing.
        for (String k : DIVERGENZEN) {
            Ladepunkt__c lp = geladen.get(ids.get(k));
            DecisionResult r = motor.get(ids.get(k));
            Boolean weichtAb = DecisionResult.ausEichstatusFormel(lp.Eichstatus__c) != r.ergebnis
                            || lp.Eichfrist_Ende__c != r.fristende;
            System.assert(weichtAb,
                'Fall ' + k + ' steht in DIVERGENZEN, stimmt aber inzwischen ueberein. Wenn die '
                + 'Formel repariert wurde, gehoert der Fall aus der Liste heraus - sonst deckt '
                + 'die Ausnahme kuenftig echte Fehler zu.');
        }
    }
}
