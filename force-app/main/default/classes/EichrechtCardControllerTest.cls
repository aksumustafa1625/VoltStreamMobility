/**
 * @description  Tests for the card's Apex facade. The legal reasoning is tested where it lives, in
 *               EichrechtServiceTest; what is checked here is the presentation contract the screen
 *               depends on — that a citation arrives with its wording and its source link, that
 *               each event carries a sentence saying what it did, and that a missing record
 *               produces an honest empty card rather than an exception in a user's face.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
@IsTest
private class EichrechtCardControllerTest {

    private static Ladepunkt__c mitEreignissen() {
        Ladepunkt__c lp = TestDataFactory.buildLadepunkt('Karte', Date.today().addYears(-3));
        insert lp;
        insert new List<Eingriff__c>{
            TestDataFactory.buildEingriff(lp.Id, 'Eingriff', Date.today().addYears(-2)),
            TestDataFactory.buildEingriff(lp.Id, 'Nacheichung', Date.today().addYears(-1))
        };
        return lp;
    }

    @IsTest
    static void dieKarteLiefertUrteilFristenUndZitate() {
        Ladepunkt__c lp = mitEreignissen();

        Test.startTest();
        EichrechtCardController.Ansicht sicht = EichrechtCardController.ladeEichrecht(lp.Id);
        Test.stopTest();

        System.assertEquals('GUELTIG', sicht.status);
        System.assertEquals('Gültig geeicht', sicht.statusText,
            'Der Screen zeigt eine deutsche Beschriftung, nicht den Enum-Namen.');
        System.assertEquals('#2e844a', sicht.farbe,
            'Die Farbe kommt als Hexwert, weil das Icon ein Inline-SVG mit currentColor ist.');
        System.assert(sicht.istAussage, 'GUELTIG ist eine Aussage.');
        System.assertNotEquals(null, sicht.fristende);
        System.assert(sicht.tageBisAblauf > 0,
            'Eine laufende Frist hat eine positive Restlaufzeit.');
        System.assert(String.isNotBlank(sicht.begruendung));
    }

    @IsTest
    static void jedesZitatBringtSeinenWortlautUndSeineQuelleMit() {
        Ladepunkt__c lp = mitEreignissen();

        Test.startTest();
        EichrechtCardController.Ansicht sicht = EichrechtCardController.ladeEichrecht(lp.Id);
        Test.stopTest();

        System.assert(!sicht.rechtsgrundlagen.isEmpty(), 'Ein Urteil ohne Zitat waere keines.');
        for (EichrechtCardController.Normbezug b : sicht.rechtsgrundlagen) {
            System.assert(String.isNotBlank(b.norm), 'Jeder Bezug traegt sein amtliches Zitat.');
            System.assert(String.isNotBlank(b.schluessel), 'Und seinen Korpusschluessel.');
            // The point of the panel: a reviewer opens the citation and reads the ordinance
            // itself, then follows the link to the official text. A citation without wording
            // would just be a label.
            System.assert(String.isNotBlank(b.wortlaut),
                b.norm + ' kommt ohne Wortlaut auf die Karte.');
            System.assert(String.isNotBlank(b.url),
                b.norm + ' kommt ohne Quellenlink auf die Karte.');
            System.assertEquals(false, b.aufgehoben,
                'Ein laufendes Urteil darf sich nicht auf aufgehobenes Recht stuetzen.');
        }
    }

    @IsTest
    static void jedesEreignisSagtWasEsMitDerEichfristGemachtHat() {
        Ladepunkt__c lp = TestDataFactory.buildLadepunkt('Verlauf', Date.today().addYears(-4));
        insert lp;
        insert new List<Eingriff__c>{
            TestDataFactory.buildEingriff(lp.Id, 'Eingriff', Date.today().addYears(-3)),
            TestDataFactory.buildEingriff(lp.Id, 'Nacheichung', Date.today().addYears(-2)),
            TestDataFactory.buildInstandsetzung(lp.Id, Date.today().addYears(-1),
                true, false, true, true),
            TestDataFactory.buildEingriff(lp.Id, 'Software-Update', Date.today().addMonths(-2))
        };

        Test.startTest();
        EichrechtCardController.Ansicht sicht = EichrechtCardController.ladeEichrecht(lp.Id);
        Test.stopTest();

        System.assertEquals(4, sicht.verlauf.size(), 'Der Verlauf zeigt jedes erfasste Ereignis.');
        Map<String, EichrechtCardController.Ereignis> jeTyp =
            new Map<String, EichrechtCardController.Ereignis>();
        for (EichrechtCardController.Ereignis e : sicht.verlauf) {
            System.assert(String.isNotBlank(e.wirkung),
                e.typ + ' steht ohne Wirkung im Verlauf - eine Zeitleiste ohne Folgen ist Dekoration.');
            System.assert(String.isNotBlank(e.farbe));
            jeTyp.put(e.typ, e);
        }

        System.assert(jeTyp.get('Eingriff').wirkung.contains('§ 37 Abs. 2 Nr. 2'),
            'Ein Eingriff nennt die Norm, die die Frist beendet.');
        System.assert(jeTyp.get('Nacheichung').wirkung.contains('§ 34 Abs. 1'),
            'Eine Nacheichung nennt die Norm, die die neue Frist in Gang setzt.');
        // Naming which of the four conditions is open is what makes the row actionable. "Not all
        // conditions met" tells an operator nothing; "Nr. 2 is missing" tells them what to do.
        System.assert(jeTyp.get('Instandsetzung').wirkung.contains('(Nr. 2)'),
            'Eine Instandsetzung muss benennen, WELCHE Bedingung fehlt: '
            + jeTyp.get('Instandsetzung').wirkung);
        System.assert(!jeTyp.get('Instandsetzung').wirkung.contains('(Nr. 1)'),
            'Und nur die, die wirklich fehlt - Nr. 1 war hier erfuellt.');
        System.assert(jeTyp.get('Software-Update').sperrt,
            'Ein Update ohne Freigabe sperrt den Betrieb.');
        System.assertEquals('#ba0517', jeTyp.get('Software-Update').farbe);
    }

    @IsTest
    static void eineSperreSchlaegtDieFristfrageUndFaerbtDieKarteEntsprechend() {
        Ladepunkt__c lp = TestDataFactory.buildLadepunkt('Gesperrt', Date.today().addYears(-2));
        insert lp;
        insert TestDataFactory.buildEingriff(lp.Id, 'Software-Update', Date.today().addMonths(-3));

        Test.startTest();
        EichrechtCardController.Ansicht sicht = EichrechtCardController.ladeEichrecht(lp.Id);
        Test.stopTest();

        System.assertEquals('BETRIEB_GESPERRT', sicht.status);
        System.assertEquals('Betrieb gesperrt', sicht.statusText);
        System.assertEquals('#ba0517', sicht.farbe);
        System.assert(sicht.begruendung.contains('unberuehrt'),
            'Die Begruendung muss sagen, dass die Eichfrist trotzdem weiterlaeuft: '
            + sicht.begruendung);
    }

    @IsTest
    static void eineDatenlueckeWirdGrauGezeigtUndNichtGruen() {
        Ladepunkt__c lp = TestDataFactory.buildLadepunkt('Ohne Datum', null);
        insert lp;

        Test.startTest();
        EichrechtCardController.Ansicht sicht = EichrechtCardController.ladeEichrecht(lp.Id);
        Test.stopTest();

        System.assertEquals('UNBEKANNT', sicht.status);
        System.assertEquals('#747474', sicht.farbe,
            'Weder eine Datenluecke noch eine nicht anwendbare Norm darf eine Urteilsfarbe tragen.');
        System.assert(!sicht.istAussage);
        System.assertEquals(null, sicht.fristende,
            'Ohne Fristende blendet die Karte den Fristenblock aus, statt Striche zu zeigen.');
        System.assertEquals(null, sicht.tageBisAblauf);
        System.assert(sicht.rechtsgrundlagen.isEmpty(), 'Ohne Aussage gibt es nichts zu zitieren.');
    }

    @IsTest
    static void eineFehlendeOderLeereIdErgibtEineLeereKarteUndKeineAusnahme() {
        // The card sits on a record page, so a caller with a stale or missing Id is a user
        // navigating, not a bug. It has to render something honest rather than throw.
        Id erfunden = Ladepunkt__c.SObjectType.getDescribe().getKeyPrefix() + '000000000000';

        Test.startTest();
        EichrechtCardController.Ansicht ohneId = EichrechtCardController.ladeEichrecht(null);
        EichrechtCardController.Ansicht unbekannteId = EichrechtCardController.ladeEichrecht(erfunden);
        Test.stopTest();

        System.assertEquals('UNBEKANNT', ohneId.status);
        System.assertEquals('#747474', ohneId.farbe);
        System.assertEquals('UNBEKANNT', unbekannteId.status);
        System.assert(unbekannteId.verlauf.isEmpty());
    }
}
