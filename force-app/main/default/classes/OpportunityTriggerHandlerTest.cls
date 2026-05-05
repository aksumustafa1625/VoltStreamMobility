/**
 * Test coverage for OpportunityTriggerHandler.
 *
 * Each test isolates one scenario from the channel-partner matching flow:
 * insert paths, update paths, bulk behavior, and the TriggerHandler bypass API
 * inherited from Kevin O'Hara's framework. Coverage target: >90%.
 */
@IsTest
private class OpportunityTriggerHandlerTest {

    private static final String EMAIL_HOTEL    = 'partner@steigenberger.de';
    private static final String EMAIL_AUTO     = 'fleet@mercedes-berlin.de';
    private static final String EMAIL_INACTIVE = 'old@churned-partner.de';

    @TestSetup
    static void setupResellers() {
        insert new List<Reseller__c>{
            new Reseller__c(
                Name = 'Steigenberger Hotels',
                Company_Email__c = EMAIL_HOTEL,
                Reseller_Type__c = 'Hotel Chain',
                Country__c = 'Germany',
                Active__c = true
            ),
            new Reseller__c(
                Name = 'Mercedes-Benz Berlin',
                Company_Email__c = EMAIL_AUTO,
                Reseller_Type__c = 'Auto Dealer',
                Country__c = 'Germany',
                Active__c = true
            ),
            new Reseller__c(
                Name = 'Churned Partner GmbH',
                Company_Email__c = EMAIL_INACTIVE,
                Reseller_Type__c = 'Electrical Contractor',
                Country__c = 'Germany',
                Active__c = false
            )
        };
    }

    private static Opportunity buildOpp(String name, String resellerEmail) {
        return new Opportunity(
            Name = name,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Reseller_Email__c = resellerEmail
        );
    }

    @IsTest
    static void insert_emailMatches_populatesLookup() {
        Opportunity opp = buildOpp('Hotel deal', EMAIL_HOTEL);

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity result = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id];
        Reseller__c expected = [SELECT Id FROM Reseller__c WHERE Company_Email__c = :EMAIL_HOTEL];
        System.assertEquals(expected.Id, result.Reseller__c,
            'Matching email should populate the Reseller lookup.');
    }

    @IsTest
    static void insert_caseInsensitiveMatch_populatesLookup() {
        // The reseller's stored email is lowercase; the input is uppercase.
        Opportunity opp = buildOpp('Case test', 'PARTNER@STEIGENBERGER.DE');

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity result = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertNotEquals(null, result.Reseller__c,
            'Uppercase input should still match the lowercase reseller email.');
    }

    @IsTest
    static void insert_resellerInactive_lookupStaysNull() {
        Opportunity opp = buildOpp('Inactive reseller deal', EMAIL_INACTIVE);

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity result = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, result.Reseller__c,
            'Inactive resellers must be excluded from matching.');
    }

    @IsTest
    static void insert_noMatch_lookupStaysNull() {
        Opportunity opp = buildOpp('Unknown reseller', 'nobody@unknown-co.de');

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity result = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, result.Reseller__c,
            'No match must leave the lookup null silently — no exception.');
    }

    @IsTest
    static void insert_nullEmail_skipsAndSavesCleanly() {
        Opportunity opp = buildOpp('Direct deal', null);

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity result = [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, result.Reseller__c,
            'Null Reseller_Email__c must not assign any lookup.');
    }

    @IsTest
    static void insert_bulk200_allMatchedNoGovernorLimit() {
        // If the trigger were not bulkified (e.g. one SOQL per record), this would
        // hit the 100-query governor limit at record 101 and throw.
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            String email = (Math.mod(i, 2) == 0) ? EMAIL_HOTEL : EMAIL_AUTO;
            opps.add(buildOpp('Bulk deal ' + i, email));
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

    @IsTest
    static void update_emailChanged_reMatchesToNewReseller() {
        Opportunity opp = buildOpp('Switching partner', EMAIL_HOTEL);
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

    @IsTest
    static void update_emailCleared_clearsLookup() {
        Opportunity opp = buildOpp('To be cleared', EMAIL_HOTEL);
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

    @IsTest
    static void update_emailUnchanged_lookupStaysSame() {
        Opportunity opp = buildOpp('Stable lookup test', EMAIL_HOTEL);
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

    @IsTest
    static void bypass_handlerSkipped_lookupNotPopulated() {
        // Using the bypass API inherited from TriggerHandler — proves the framework is wired up.
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Opportunity opp = buildOpp('Bypassed deal', EMAIL_HOTEL);

        Test.startTest();
        insert opp;
        Test.stopTest();

        System.assertEquals(null,
            [SELECT Reseller__c FROM Opportunity WHERE Id = :opp.Id].Reseller__c,
            'When the handler is bypassed, no lookup should be assigned.');

        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
}
