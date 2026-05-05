/**
 * Direct unit tests for OpportunityTriggerHelper.
 *
 * These tests call the static Helper methods in isolation — Opportunity
 * records are constructed in memory and passed in as method arguments
 * rather than inserted via DML. That means the Opportunity trigger does
 * NOT fire during these tests; we are exercising the algorithm itself,
 * not the Trigger -> Handler -> Helper plumbing.
 *
 * Why a Helper test class on top of OpportunityTriggerHandlerTest:
 *   - Faster feedback when the algorithm changes (no Opportunity DML cost).
 *   - Clearer failure messages — a broken assertion here points straight
 *     at the algorithm; a broken assertion in the Handler test could mean
 *     the algorithm OR the dispatch wiring.
 *   - Documents that the Helper is callable from non-trigger contexts
 *     (e.g. a future batch job or scheduled class could call
 *     OpportunityTriggerHelper.assignResellerLookup() directly).
 *
 * Resellers ARE inserted via DML in @TestSetup because the Helper's SOQL
 * needs them to exist; that one DML is unavoidable.
 */
@IsTest
private class OpportunityTriggerHelperTest {

    private static final String EMAIL_HOTEL    = 'partner@helper-test-hotel.de';
    private static final String EMAIL_AUTO     = 'fleet@helper-test-auto.de';
    private static final String EMAIL_INACTIVE = 'old@helper-test-inactive.de';

    @TestSetup
    static void setupResellers() {
        insert new List<Reseller__c>{
            new Reseller__c(
                Name = 'Helper Test Hotel',
                Company_Email__c = EMAIL_HOTEL,
                Reseller_Type__c = 'Hotel Chain',
                Country__c = 'Germany',
                Active__c = true
            ),
            new Reseller__c(
                Name = 'Helper Test Auto',
                Company_Email__c = EMAIL_AUTO,
                Reseller_Type__c = 'Auto Dealer',
                Country__c = 'Germany',
                Active__c = true
            ),
            new Reseller__c(
                Name = 'Helper Test Inactive',
                Company_Email__c = EMAIL_INACTIVE,
                Reseller_Type__c = 'Energy Company',
                Country__c = 'Germany',
                Active__c = false
            )
        };
    }

    /** Build an unsaved Opportunity. The trigger does NOT fire because we never insert. */
    private static Opportunity buildOpp(String name, String resellerEmail) {
        return new Opportunity(
            Name = name,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Reseller_Email__c = resellerEmail
        );
    }

    @IsTest
    static void assignResellerLookup_emailMatch_setsLookup() {
        List<Opportunity> opps = new List<Opportunity>{
            buildOpp('Direct call match', EMAIL_HOTEL)
        };

        Test.startTest();
        OpportunityTriggerHelper.assignResellerLookup(opps, null);
        Test.stopTest();

        Reseller__c expected = [SELECT Id FROM Reseller__c WHERE Company_Email__c = :EMAIL_HOTEL];
        System.assertEquals(expected.Id, opps[0].Reseller__c,
            'Direct Helper call with matching email should set the lookup.');
    }

    @IsTest
    static void assignResellerLookup_caseInsensitive_setsLookup() {
        List<Opportunity> opps = new List<Opportunity>{
            buildOpp('Uppercase email', 'PARTNER@HELPER-TEST-HOTEL.DE')
        };

        OpportunityTriggerHelper.assignResellerLookup(opps, null);

        System.assertNotEquals(null, opps[0].Reseller__c,
            'Uppercase input should match the lowercase reseller email.');
    }

    @IsTest
    static void assignResellerLookup_inactiveReseller_lookupStaysNull() {
        List<Opportunity> opps = new List<Opportunity>{
            buildOpp('Inactive partner', EMAIL_INACTIVE)
        };

        OpportunityTriggerHelper.assignResellerLookup(opps, null);

        System.assertEquals(null, opps[0].Reseller__c,
            'Inactive resellers must be excluded from matching.');
    }

    @IsTest
    static void assignResellerLookup_unknownEmail_lookupStaysNull() {
        List<Opportunity> opps = new List<Opportunity>{
            buildOpp('Unknown reseller', 'nobody@nowhere-' + System.now().getTime() + '.de')
        };

        OpportunityTriggerHelper.assignResellerLookup(opps, null);

        System.assertEquals(null, opps[0].Reseller__c,
            'Unknown emails must result in a null lookup, not an exception.');
    }

    @IsTest
    static void assignResellerLookup_nullEmail_skipsCleanly() {
        List<Opportunity> opps = new List<Opportunity>{
            buildOpp('Direct deal', null)
        };

        OpportunityTriggerHelper.assignResellerLookup(opps, null);

        System.assertEquals(null, opps[0].Reseller__c,
            'Null email must not trigger any lookup assignment.');
    }

    @IsTest
    static void assignResellerLookup_emptyList_returnsCleanly() {
        // Empty input must not throw, must not query, must not crash.
        List<Opportunity> opps = new List<Opportunity>();

        Integer queriesBefore = Limits.getQueries();
        OpportunityTriggerHelper.assignResellerLookup(opps, null);
        Integer queriesAfter = Limits.getQueries();

        System.assertEquals(0, opps.size(), 'Input list must remain empty.');
        System.assertEquals(queriesBefore, queriesAfter,
            'Empty input must short-circuit before issuing any SOQL.');
    }

    @IsTest
    static void assignResellerLookup_mixedBatch_matchesEachIndependently() {
        // One match, one no-match, one null email — all in a single call.
        List<Opportunity> opps = new List<Opportunity>{
            buildOpp('Match',     EMAIL_HOTEL),
            buildOpp('No match',  'unknown@nowhere.de'),
            buildOpp('Direct',    null)
        };

        OpportunityTriggerHelper.assignResellerLookup(opps, null);

        System.assertNotEquals(null, opps[0].Reseller__c, 'First record should match.');
        System.assertEquals(null, opps[1].Reseller__c,    'Second record should not match.');
        System.assertEquals(null, opps[2].Reseller__c,    'Third record (null email) should be skipped.');
    }

    @IsTest
    static void assignResellerLookup_bulkInput_singleSoql() {
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            opps.add(buildOpp('Bulk ' + i, Math.mod(i, 2) == 0 ? EMAIL_HOTEL : EMAIL_AUTO));
        }

        Integer queriesBefore = Limits.getQueries();
        OpportunityTriggerHelper.assignResellerLookup(opps, null);
        Integer queriesAfter = Limits.getQueries();

        System.assertEquals(1, queriesAfter - queriesBefore,
            'Bulkified Helper must issue exactly ONE SOQL regardless of input size.');
        for (Opportunity o : opps) {
            System.assertNotEquals(null, o.Reseller__c,
                'Every bulk record with a known email should have its lookup set.');
        }
    }
}
