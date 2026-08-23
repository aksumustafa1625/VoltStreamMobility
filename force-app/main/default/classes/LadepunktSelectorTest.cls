/**
 * @description  Tests for the Ladepunkt__c queries. Two things are worth guarding here: that an
 *               empty input never becomes an unfiltered query, and that events come back in the
 *               order the engine reads them as meaning.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
@IsTest
private class LadepunktSelectorTest {

    @IsTest
    static void leereUndNullEingabenFragenDieDatenbankNichtAb() {
        Test.startTest();
        Integer vorher = Limits.getQueries();
        List<Ladepunkt__c> a = LadepunktSelector.byIds(null);
        List<Ladepunkt__c> b = LadepunktSelector.byIds(new Set<Id>());
        List<Eingriff__c> c = LadepunktSelector.eingriffeByLadepunkt(null);
        List<Eingriff__c> d = LadepunktSelector.eingriffeByLadepunkt(new Set<Id>());
        Integer nachher = Limits.getQueries();
        Test.stopTest();

        System.assert(a.isEmpty() && b.isEmpty() && c.isEmpty() && d.isEmpty());
        // Guarding the count, not just the result: an empty set that reaches a WHERE Id IN clause
        // still costs a query, and in a bulk path that is a governor limit spent on nothing.
        System.assertEquals(vorher, nachher, 'Eine leere Eingabe darf keine Abfrage kosten.');
    }

    @IsTest
    static void ladepunkteKommenMitDenBerechnetenFeldernZurueck() {
        Ladepunkt__c lp = TestDataFactory.buildLadepunkt('Selector', Date.newInstance(2019, 3, 15));
        insert lp;

        Test.startTest();
        List<Ladepunkt__c> geladen = LadepunktSelector.byIds(new Set<Id>{lp.Id});
        Test.stopTest();

        System.assertEquals(1, geladen.size());
        System.assertEquals(Date.newInstance(2019, 3, 15), geladen[0].Inverkehrbringen__c);
        // The declarative answer travels with the record so a caller can compare it against the
        // engine's without a second query - which is what the consistency test will do.
        System.assertNotEquals(null, geladen[0].Eichstatus__c,
            'Der Selector laedt auch die Formelantwort der deklarativen Schicht.');
    }

    @IsTest
    static void ereignisseKommenChronologischZurueck() {
        Ladepunkt__c lp = TestDataFactory.buildLadepunkt('Reihenfolge', Date.newInstance(2019, 3, 15));
        insert lp;
        insert new List<Eingriff__c>{
            TestDataFactory.buildEingriff(lp.Id, 'Nacheichung', Date.newInstance(2024, 1, 5)),
            TestDataFactory.buildEingriff(lp.Id, 'Eingriff', Date.newInstance(2021, 6, 2)),
            TestDataFactory.buildEingriff(lp.Id, 'Software-Update', Date.newInstance(2022, 9, 30))
        };

        Test.startTest();
        List<Eingriff__c> geladen = LadepunktSelector.eingriffeByLadepunkt(new Set<Id>{lp.Id});
        Test.stopTest();

        System.assertEquals(3, geladen.size());
        System.assertEquals(Date.newInstance(2021, 6, 2), geladen[0].Datum__c);
        System.assertEquals(Date.newInstance(2022, 9, 30), geladen[1].Datum__c);
        System.assertEquals(Date.newInstance(2024, 1, 5), geladen[2].Datum__c);
        System.assertEquals(true, geladen[1].Sperrt_Betrieb__c,
            'Die Formelfelder des Ereignisses muessen mitgeladen werden - der Service liest sie.');
    }
}
