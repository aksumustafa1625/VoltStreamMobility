/**
 * @description  Direct unit tests for OpportunityTriggerHelper. These tests
 *               call the static Helper methods in isolation — Opportunity
 *               records are constructed in memory via TestDataFactory and
 *               passed in as method arguments rather than inserted via DML.
 *               That means the Opportunity trigger does NOT fire during
 *               these tests; we are exercising the algorithm itself, not
 *               the Trigger -> Handler -> Helper plumbing.
 *
 *               Why a Helper test class on top of OpportunityTriggerHandlerTest:
 *                 - Faster feedback when the algorithm changes (no Opportunity
 *                   DML cost).
 *                 - Clearer failure messages — a broken assertion here points
 *                   straight at the algorithm; a broken assertion in the
 *                   Handler test could mean the algorithm OR the dispatch wiring.
 *                 - Documents that the Helper is callable from non-trigger
 *                   contexts (e.g. a future batch job or scheduled class could
 *                   call OpportunityTriggerHelper.assignResellerLookup() directly).
 *
 *               Resellers ARE inserted via DML in @TestSetup because the
 *               Helper's SOQL needs them to exist; that one DML is unavoidable.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
@IsTest
private class OpportunityTriggerHelperTest {

    private static final String EMAIL_HOTEL    = 'partner@helper-test-hotel.de';
    private static final String EMAIL_AUTO     = 'fleet@helper-test-auto.de';
    private static final String EMAIL_INACTIVE = 'old@helper-test-inactive.de';

    /**
     * @description  Seed three Reseller__c records (two active, one inactive)
     *               for the Helper to query against. Shared across all tests
     *               in this class. Resellers MUST be DML-inserted because the
     *               Helper queries them via SOQL — the in-memory shortcut
     *               only applies to the Opportunity records themselves.
     */
    @TestSetup
    static void setupResellers() {
        insert new List<Reseller__c>{
            TestDataFactory.buildReseller('Helper Test Hotel', EMAIL_HOTEL, 'Hotel Chain'),
            TestDataFactory.buildReseller('Helper Test Auto', EMAIL_AUTO, 'Auto Dealer'),
            TestDataFactory.buildInactiveReseller('Helper Test Inactive', EMAIL_INACTIVE, 'Energy Company')
        };
    }

    // Direct call with a matching email -> Helper sets the lookup in memory.
    @IsTest
    static void assignResellerLookup_emailMatch_setsLookup() {
        List<Opportunity> opps = new List<Opportunity>{
            TestDataFactory.buildOpportunity('Direct call match', EMAIL_HOTEL)
        };

        Test.startTest();
        OpportunityTriggerHelper.assignResellerLookup(opps, null);
        Test.stopTest();

        Reseller__c expected = [SELECT Id FROM Reseller__c WHERE Company_Email__c = :EMAIL_HOTEL];
        System.assertEquals(expected.Id, opps[0].Reseller__c,
            'Direct Helper call with matching email should set the lookup.');
    }

    // Uppercase input must match against the lowercase stored email.
    @IsTest
    static void assignResellerLookup_caseInsensitive_setsLookup() {
        List<Opportunity> opps = new List<Opportunity>{
            TestDataFactory.buildOpportunity('Uppercase email', 'PARTNER@HELPER-TEST-HOTEL.DE')
        };

        OpportunityTriggerHelper.assignResellerLookup(opps, null);

        System.assertNotEquals(null, opps[0].Reseller__c,
            'Uppercase input should match the lowercase reseller email.');
    }

    // Helper must respect Active__c = false at the SOQL filter level.
    @IsTest
    static void assignResellerLookup_inactiveReseller_lookupStaysNull() {
        List<Opportunity> opps = new List<Opportunity>{
            TestDataFactory.buildOpportunity('Inactive partner', EMAIL_INACTIVE)
        };

        OpportunityTriggerHelper.assignResellerLookup(opps, null);

        System.assertEquals(null, opps[0].Reseller__c,
            'Inactive resellers must be excluded from matching.');
    }

    // Unknown email -> silent null, never an exception.
    @IsTest
    static void assignResellerLookup_unknownEmail_lookupStaysNull() {
        List<Opportunity> opps = new List<Opportunity>{
            TestDataFactory.buildOpportunity('Unknown reseller', 'nobody@nowhere-' + System.now().getTime() + '.de')
        };

        OpportunityTriggerHelper.assignResellerLookup(opps, null);

        System.assertEquals(null, opps[0].Reseller__c,
            'Unknown emails must result in a null lookup, not an exception.');
    }

    // Null email -> Helper short-circuits without assignment.
    @IsTest
    static void assignResellerLookup_nullEmail_skipsCleanly() {
        List<Opportunity> opps = new List<Opportunity>{
            TestDataFactory.buildOpportunity('Direct deal', null)
        };

        OpportunityTriggerHelper.assignResellerLookup(opps, null);

        System.assertEquals(null, opps[0].Reseller__c,
            'Null email must not trigger any lookup assignment.');
    }

    // Empty input list -> no SOQL issued at all (proven via Limits.getQueries).
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

    // Mixed batch (match + no-match + null) — every record handled independently in one call.
    @IsTest
    static void assignResellerLookup_mixedBatch_matchesEachIndependently() {
        List<Opportunity> opps = new List<Opportunity>{
            TestDataFactory.buildOpportunity('Match',     EMAIL_HOTEL),
            TestDataFactory.buildOpportunity('No match',  'unknown@nowhere.de'),
            TestDataFactory.buildOpportunity('Direct',    null)
        };

        OpportunityTriggerHelper.assignResellerLookup(opps, null);

        System.assertNotEquals(null, opps[0].Reseller__c, 'First record should match.');
        System.assertEquals(null, opps[1].Reseller__c,    'Second record should not match.');
        System.assertEquals(null, opps[2].Reseller__c,    'Third record (null email) should be skipped.');
    }

    // 200 records -> exactly ONE SOQL. Bulkification proven via Limits.getQueries().
    @IsTest
    static void assignResellerLookup_bulkInput_singleSoql() {
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            opps.add(TestDataFactory.buildOpportunity('Bulk ' + i, Math.mod(i, 2) == 0 ? EMAIL_HOTEL : EMAIL_AUTO));
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
