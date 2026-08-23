/**
 * @description  Tests for the nightly sweep.
 *
 *               Two things are checked that nothing else can check. That the engine's verdict lands
 *               on the record, because a verdict nobody can report on is a verdict nobody acts on.
 *               And that the divergence flag is set exactly where the two layers disagree — which
 *               turns the twelve-fixture consistency test into a question you can ask of a whole
 *               fleet.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-24
 */
@IsTest
private class EichrechtBatchTest {

    @IsTest
    static void derBatchSchreibtDasUrteilDerEngineAufDenDatensatz() {
        List<Ladepunkt__c> lp = new List<Ladepunkt__c>{
            TestDataFactory.buildLadepunkt('laufend', Date.today().addYears(-3)),
            TestDataFactory.buildLadepunkt('abgelaufen', Date.newInstance(Date.today().year() - 10, 3, 1)),
            TestDataFactory.buildLadepunkt('ohneDatum', null)
        };
        insert lp;

        Test.startTest();
        Database.executeBatch(new EichrechtBatch(), 200);
        Test.stopTest();

        Map<String, Ladepunkt__c> jeOrt = new Map<String, Ladepunkt__c>();
        for (Ladepunkt__c geladen : [SELECT Standort_Adresse__c, Pruefergebnis__c,
                                            Letzte_Pruefung_am__c, Abweichung__c
                                     FROM Ladepunkt__c]) {
            jeOrt.put(geladen.Standort_Adresse__c, geladen);
        }

        System.assertEquals('GUELTIG', jeOrt.get('laufend').Pruefergebnis__c);
        System.assertEquals('ABGELAUFEN', jeOrt.get('abgelaufen').Pruefergebnis__c);
        System.assertEquals('UNBEKANNT', jeOrt.get('ohneDatum').Pruefergebnis__c,
            'Auch die Datenluecke wird festgeschrieben - sonst sieht ein Bericht sie nicht.');
        for (Ladepunkt__c geladen : jeOrt.values()) {
            System.assertNotEquals(null, geladen.Letzte_Pruefung_am__c,
                'Ein fehlender Zeitstempel ist ein Befund ueber den Job, nicht ueber den Ladepunkt.');
        }
    }

    @IsTest
    static void wodieSchichtenUebereinstimmenBleibtDieAbweichungUngesetzt() {
        insert TestDataFactory.buildLadepunkt('einig', Date.today().addYears(-3));

        Test.startTest();
        Database.executeBatch(new EichrechtBatch(), 200);
        Test.stopTest();

        Ladepunkt__c geladen = [SELECT Eichstatus__c, Pruefergebnis__c, Abweichung__c
                                FROM Ladepunkt__c LIMIT 1];
        System.assertEquals(false, geladen.Abweichung__c,
            'Formel sagt ' + geladen.Eichstatus__c + ', Engine sagt ' + geladen.Pruefergebnis__c
            + ' - das ist dieselbe Aussage in zwei Vokabularen und keine Abweichung.');
    }

    @IsTest
    static void beiVerspaeteterNacheichungMarkiertDerBatchDieAbweichung() {
        // Seventeen years on the market puts the first period's end nine years back; a
        // re-calibration a year after that is late, so § 34 Abs. 1 Satz 3 backdates the new period
        // to the old one's end. The engine sees it; a formula reading only the latest calibration
        // date cannot. This is the row a fleet-wide list view is for.
        Ladepunkt__c lp = TestDataFactory.buildLadepunkt(
            'spaet', Date.newInstance(Date.today().year() - 17, 3, 1));
        insert lp;
        insert TestDataFactory.buildEingriff(lp.Id, 'Nacheichung',
            Date.newInstance(Date.today().year() - 8, 6, 15));

        Test.startTest();
        Database.executeBatch(new EichrechtBatch(), 200);
        Test.stopTest();

        Ladepunkt__c geladen = [SELECT Eichstatus__c, Pruefergebnis__c, Abweichung__c
                                FROM Ladepunkt__c LIMIT 1];
        System.assertEquals('ABGELAUFEN', geladen.Pruefergebnis__c,
            'Die Engine rechnet die Rueckdatierung.');
        System.assertEquals(true, geladen.Abweichung__c,
            'Die Listenansicht haelt den Ladepunkt fuer gueltig geeicht (' + geladen.Eichstatus__c
            + '), die Engine nicht. Genau diese Zeile soll jemand sehen koennen.');
    }

    @IsTest
    static void einStichtagInDerZukunftAendertDasErgebnisDesLaufs() {
        insert TestDataFactory.buildLadepunkt('heute gueltig', Date.today().addYears(-3));

        Test.startTest();
        // Fixed for the whole run, so a job crossing midnight cannot answer two different days.
        Database.executeBatch(new EichrechtBatch(Date.today().addYears(9)), 200);
        Test.stopTest();

        System.assertEquals('ABGELAUFEN',
            [SELECT Pruefergebnis__c FROM Ladepunkt__c LIMIT 1].Pruefergebnis__c,
            'In neun Jahren ist die Frist abgelaufen, und der Batch beantwortet den Tag, den er '
            + 'bekommen hat.');
    }

    @IsTest
    static void derZeitplanerStartetDenBatch() {
        insert TestDataFactory.buildLadepunkt('geplant', Date.today().addYears(-3));

        Test.startTest();
        String jobId = System.schedule('Eichrecht-Sweep Test', '0 0 3 * * ?', new EichrechtBatch());
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE Id = :jobId],
            'Der Batch ist auch der Schedulable - ein Job, keine Huelle drumherum.');
    }

    @IsTest
    static void dieAbweichungsPruefungBehandeltUnbekanntesUndLeeresUnterschiedlich() {
        Test.startTest();
        Boolean leer = EichrechtBatch.weichtAb(null, 'GUELTIG');
        Boolean gleich = EichrechtBatch.weichtAb('GÜLTIG', 'GUELTIG');
        Boolean anders = EichrechtBatch.weichtAb('GÜLTIG', 'ABGELAUFEN');
        Boolean unbekannt = EichrechtBatch.weichtAb('IRGENDWAS NEUES', 'GUELTIG');
        Test.stopTest();

        System.assertEquals(false, leer,
            'Ein leerer Formelwert ist keine Uneinigkeit, sondern ein noch nicht berechneter Wert.');
        System.assertEquals(false, gleich, 'Umlaut hier, Enum-Name dort - dieselbe Aussage.');
        System.assertEquals(true, anders);
        System.assertEquals(true, unbekannt,
            'Ein nicht zuordenbarer Formelwert ist eine Abweichung: entweder wurde die Formel '
            + 'geaendert ohne die Zuordnung, oder sie liefert etwas Ungeplantes.');
    }
}
