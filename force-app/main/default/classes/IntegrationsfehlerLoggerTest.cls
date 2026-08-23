/**
 * @description  Tests for the integration error log.
 *
 *               The behaviour worth guarding is the one that looks like a corner case and is not:
 *               logging must never throw. A logger that can fail turns a recoverable integration
 *               problem into an unrecoverable one, and takes down the transaction it was supposed
 *               to explain.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-24
 */
@IsTest
private class IntegrationsfehlerLoggerTest {

    @IsTest
    static void einFehlerWirdMitAllenAngabenFestgehalten() {
        Test.startTest();
        IntegrationsfehlerLogger.protokolliere('OCPI', 'GET /locations', 503,
            'Der CPO hat mit Service Unavailable geantwortet.', 'DE*VSM*E00000001', '{"a":1}');
        Test.stopTest();

        Integrationsfehler__c f = [SELECT System__c, Vorgang__c, Statuscode__c, Nachricht__c,
                                          Kennung__c, Nutzlast__c
                                   FROM Integrationsfehler__c LIMIT 1];
        System.assertEquals('OCPI', f.System__c);
        System.assertEquals('GET /locations', f.Vorgang__c);
        System.assertEquals(503, f.Statuscode__c);
        System.assertEquals('DE*VSM*E00000001', f.Kennung__c,
            'Ein Lauf, der bei einer von achthundert Zeilen scheitert, muss sagen, bei welcher.');
        System.assertEquals('{"a":1}', f.Nutzlast__c);
    }

    @IsTest
    static void vieleFehlerKostenEineAnweisung() {
        List<Integrationsfehler__c> viele = new List<Integrationsfehler__c>();
        for (Integer i = 0; i < 200; i++) {
            viele.add(IntegrationsfehlerLogger.baue('OCPI', 'Upsert Ladepunkt__c', null,
                'Feldlaenge ueberschritten', 'DE*VSM*E' + i, null));
        }

        Test.startTest();
        Integer vorher = Limits.getDmlStatements();
        IntegrationsfehlerLogger.protokolliere(viele);
        Integer nachher = Limits.getDmlStatements();
        Test.stopTest();

        System.assertEquals(200, [SELECT COUNT() FROM Integrationsfehler__c]);
        System.assertEquals(1, nachher - vorher,
            'Ein Batch, der bei achthundert Zeilen scheitert, darf nicht achthundert Anweisungen '
            + 'dafuer ausgeben, das zu sagen.');
    }

    @IsTest
    static void eineUeberlangeNutzlastWirdGekuerztStattDieZeileZuVerlieren() {
        String riesig = 'x'.repeat(40000);

        Test.startTest();
        IntegrationsfehlerLogger.protokolliere('OCPI', 'GET /locations', 200,
            'Antwort zu gross', null, riesig);
        Test.stopTest();

        // A log row is diagnosis, not an archive. Truncating keeps the row; not truncating loses it
        // to a field-length error - and losing the record of a failure is worse than losing its tail.
        Integrationsfehler__c f = [SELECT Nutzlast__c FROM Integrationsfehler__c LIMIT 1];
        System.assert(f.Nutzlast__c.length() <= 32768);
        System.assert(f.Nutzlast__c.length() < riesig.length());
    }

    @IsTest
    static void leereUndFehlerhafteEingabenWerfenNichts() {
        Test.startTest();
        // Nothing here may throw. The caller is already handling a failure; a logger that adds a
        // second one has made the situation worse rather than clearer.
        IntegrationsfehlerLogger.protokolliere(null);
        IntegrationsfehlerLogger.protokolliere(new List<Integrationsfehler__c>());
        IntegrationsfehlerLogger.protokolliere(null, null, null, null, null, null);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Integrationsfehler__c],
            'Auch ein Aufruf ohne jede Angabe hinterlaesst eine Zeile - dass etwas schiefging, ist '
            + 'die Information, nicht das Detail.');
    }
}
