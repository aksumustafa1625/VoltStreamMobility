/**
 * @description  Unit tests for ResellerSelector. Verifies query contracts:
 *               Active__c filter, missing record returns empty, empty input
 *               short-circuits, External ID case-sensitive match. Uses
 *               TestDataFactory for record construction.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
@IsTest
private class ResellerSelectorTest {

    private static final String EMAIL_ACTIVE   = 'active@selector-test.de';
    private static final String EMAIL_INACTIVE = 'inactive@selector-test.de';

    /**
     * @description  Seed one active and one inactive Reseller so each test
     *               can assert on the Active__c filter without re-creating data.
     */
    @TestSetup
    static void setupResellers() {
        insert new List<Reseller__c>{
            TestDataFactory.buildReseller('Active Selector Reseller', EMAIL_ACTIVE, 'Hotel Chain'),
            TestDataFactory.buildInactiveReseller('Inactive Selector Reseller', EMAIL_INACTIVE, 'Auto Dealer')
        };
    }

    // Active reseller with matching email -> single record returned.
    @IsTest
    static void findActiveByEmails_activeMatch_returnsRecord() {
        Set<String> emails = new Set<String>{ EMAIL_ACTIVE };

        List<Reseller__c> results = ResellerSelector.findActiveByEmails(emails);

        System.assertEquals(1, results.size(),
            'Active reseller with matching email should be returned.');
        System.assertEquals(EMAIL_ACTIVE, results[0].Company_Email__c,
            'Returned record should have the matching email.');
    }

    // Inactive reseller -> filtered out at the SOQL level.
    @IsTest
    static void findActiveByEmails_inactiveMatch_excluded() {
        Set<String> emails = new Set<String>{ EMAIL_INACTIVE };

        List<Reseller__c> results = ResellerSelector.findActiveByEmails(emails);

        System.assertEquals(0, results.size(),
            'Inactive resellers must never appear in Selector results.');
    }

    // Unknown email -> empty list (never an exception).
    @IsTest
    static void findActiveByEmails_unknownEmail_returnsEmpty() {
        Set<String> emails = new Set<String>{ 'nobody@nowhere.de' };

        List<Reseller__c> results = ResellerSelector.findActiveByEmails(emails);

        System.assertEquals(0, results.size(),
            'Unknown emails should produce an empty list, not throw.');
    }

    // Empty input set -> empty list (Selector never refuses an empty query).
    @IsTest
    static void findActiveByEmails_emptySet_returnsEmpty() {
        Set<String> emails = new Set<String>();

        List<Reseller__c> results = ResellerSelector.findActiveByEmails(emails);

        System.assertEquals(0, results.size(),
            'Empty input set must return an empty list cleanly.');
    }

    // External ID + SOQL IN = case-SENSITIVE match. This test pins down the
    // contract so any future code that relies on case-insensitive matching
    // (and forgets to normalize first) gets a loud failure here. The Helper
    // is the canonical "normalize then call" caller — see the Helper test
    // 'assignResellerLookup_caseInsensitive_setsLookup' for the end-to-end
    // case-insensitive guarantee at the application layer.
    @IsTest
    static void findActiveByEmails_caseMismatchVsStorage_returnsEmpty() {
        // Stored email (via @TestSetup) is lowercase. Query passes uppercase.
        // External ID storage layer compares case-sensitively, so no match.
        Set<String> emails = new Set<String>{ EMAIL_ACTIVE.toUpperCase() };

        List<Reseller__c> results = ResellerSelector.findActiveByEmails(emails);

        System.assertEquals(0, results.size(),
            'External ID lookup is case-sensitive — callers must normalize input emails to match stored case.');
    }
}
