/**
 * @description  Integration tests for OpportunityTrigger + OpportunityTriggerHandler.
 *               Tests fire DML on Opportunity to exercise the full
 *               Trigger -> Handler -> Helper chain end-to-end in real org
 *               transactions. This complements OpportunityTriggerHelperTest,
 *               which exercises the algorithm in isolation without DML.
 *
 *               Test data construction is delegated to TestDataFactory so
 *               that schema changes (e.g. adding a required field to
 *               Reseller__c) only need to update the factory — never each
 *               test method.
 *
 *               Each test method isolates one scenario from the channel-partner
 *               matching flow: insert paths, update paths, bulk behavior, and
 *               the TriggerHandler bypass API inherited from Kevin O'Hara's
 *               framework. Coverage target: 100%.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
@IsTest
private class OpportunityTriggerHandlerTest {

    private static final String EMAIL_HOTEL    = 'partner@steigenberger.de';
    private static final String EMAIL_AUTO     = 'fleet@mercedes-berlin.de';
    private static final String EMAIL_INACTIVE = 'old@churned-partner.de';

    /**
     * @description  Seed three Reseller__c records (two active, one inactive)
     *               that every test method shares. Runs once per test class.
     */
    @TestSetup
    static void setupResellers() {
        insert new List<Reseller__c>{
            TestDataFactory.buildReseller('Steigenberger Hotels', EMAIL_HOTEL, 'Hotel Chain'),
            TestDataFactory.buildReseller('Mercedes-Benz Berlin', EMAIL_AUTO, 'Auto Dealer'),
            TestDataFactory.buildInactiveReseller('Churned Partner GmbH', EMAIL_INACTIVE, 'Electrical Contractor')
        };
    }

    // Insert with a matching email -> the Reseller lookup must be populated.
    @IsTest
    static void insert_emailMatches_populatesLookup() {
        Opportunity opp = TestDataFactory.buildOpportunity('Hotel deal', EMAIL_HOTEL);

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity result = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id];
        Reseller__c expected = [SELECT Id FROM Reseller__c WHERE Company_Email__c = :EMAIL_HOTEL];
        System.assertEquals(expected.Id, result.Reseller__c,
            'Matching email should populate the Reseller lookup.');
    }

    // Uppercase input must match a lowercase reseller email — case-insensitive contract.
    @IsTest
    static void insert_caseInsensitiveMatch_populatesLookup() {
        Opportunity opp = TestDataFactory.buildOpportunity('Case test', 'PARTNER@STEIGENBERGER.DE');

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity result = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertNotEquals(null, result.Reseller__c,
            'Uppercase input should still match the lowercase reseller email.');
    }

    // Inactive resellers must be excluded from matching at SOQL level.
    @IsTest
    static void insert_resellerInactive_lookupStaysNull() {
        Opportunity opp = TestDataFactory.buildOpportunity('Inactive reseller deal', EMAIL_INACTIVE);

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity result = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, result.Reseller__c,
            'Inactive resellers must be excluded from matching.');
    }

    // Unknown email -> silent null. Never throw an exception that blocks the save.
    @IsTest
    static void insert_noMatch_lookupStaysNull() {
        Opportunity opp = TestDataFactory.buildOpportunity('Unknown reseller', 'nobody@unknown-co.de');

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity result = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, result.Reseller__c,
            'No match must leave the lookup null silently — no exception.');
    }

    // Direct deal (no reseller email) must save cleanly with no lookup assignment.
    @IsTest
    static void insert_nullEmail_skipsAndSavesCleanly() {
        Opportunity opp = TestDataFactory.buildOpportunity('Direct deal', null);

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity result = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, result.Reseller__c,
            'Null Reseller_Email__c must not assign any lookup.');
    }

    // 200-record insert proves bulkification — would hit 100-SOQL governor limit otherwise.
    @IsTest
    static void insert_bulk200_allMatchedNoGovernorLimit() {
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            String email = (Math.mod(i, 2) == 0) ? EMAIL_HOTEL : EMAIL_AUTO;
            opps.add(TestDataFactory.buildOpportunity('Bulk deal ' + i, email));
        }

        Test.startTest();
        insert opps;
        Test.stopTest();

        List<Opportunity> results = [
            SELECT Reseller__c FROM Opportunity WHERE Id IN :opps
        ];
        System.assertEquals(200, results.size(), 'All 200 Opportunities should insert.');
        for (Opportunity o : results) {
            System.assertNotEquals(null, o.Reseller__c,
                'Every bulk record should have its Reseller lookup populated.');
        }
    }

    // Update with changed email -> trigger re-runs the match against the new value.
    @IsTest
    static void update_emailChanged_reMatchesToNewReseller() {
        Opportunity opp = TestDataFactory.buildOpportunity('Switching partner', EMAIL_HOTEL);
        insert opp;
        Reseller__c hotel = [SELECT Id FROM Reseller__c WHERE Company_Email__c = :EMAIL_HOTEL];
        System.assertEquals(hotel.Id,
            [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id].Reseller__c,
            'Pre-update lookup should match the hotel reseller.');

        opp.Reseller_Email__c = EMAIL_AUTO;

        Test.startTest();
        update opp;
        Test.stopTest();

        Reseller__c auto = [SELECT Id FROM Reseller__c WHERE Company_Email__c = :EMAIL_AUTO];
        System.assertEquals(auto.Id,
            [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id].Reseller__c,
            'Updating the email should re-match to the new reseller.');
    }

    // Update that clears the email must also clear the Reseller lookup (data integrity).
    @IsTest
    static void update_emailCleared_clearsLookup() {
        Opportunity opp = TestDataFactory.buildOpportunity('To be cleared', EMAIL_HOTEL);
        insert opp;
        System.assertNotEquals(null,
            [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id].Reseller__c);

        opp.Reseller_Email__c = null;

        Test.startTest();
        update opp;
        Test.stopTest();

        System.assertEquals(null,
            [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id].Reseller__c,
            'Clearing the email must also clear the Reseller lookup.');
    }

    // Update that doesn't touch the email must leave the lookup unchanged.
    @IsTest
    static void update_emailUnchanged_lookupStaysSame() {
        Opportunity opp = TestDataFactory.buildOpportunity('Stable lookup test', EMAIL_HOTEL);
        insert opp;
        Id originalLookup = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id].Reseller__c;
        System.assertNotEquals(null, originalLookup, 'Pre-update lookup should be set.');

        // Touch a different field; Reseller_Email__c is unchanged.
        opp.Description = 'Updated description only';

        Test.startTest();
        update opp;
        Test.stopTest();

        System.assertEquals(originalLookup,
            [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id].Reseller__c,
            'Lookup must remain unchanged when Reseller_Email__c did not change.');
    }

    // Bypass API: when active, the handler must be skipped entirely.
    // Proves the Kevin O'Hara framework's bypass mechanism is wired up.
    @IsTest
    static void bypass_handlerSkipped_lookupNotPopulated() {
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Opportunity opp = TestDataFactory.buildOpportunity('Bypassed deal', EMAIL_HOTEL);

        Test.startTest();
        insert opp;
        Test.stopTest();

        System.assertEquals(null,
            [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id].Reseller__c,
            'When the handler is bypassed, no lookup should be assigned.');

        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
}
