/**
 * @description  Unit tests for ResellerSelector. Verifies the contract of
 *               every query method: the Active__c filter actually excludes
 *               inactive records, missing emails return an empty list, and
 *               an empty input set short-circuits without errors.
 *
 *               These tests use TestDataFactory for record construction so
 *               schema changes don't ripple here. Each test inserts the
 *               minimum data it needs via @TestSetup, then exercises one
 *               Selector method.
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

    // Salesforce SOQL string equality is case-insensitive — Selector relies on this.
    // Stored email is lowercase; query passes uppercase; result still matches.
    @IsTest
    static void findActiveByEmails_caseInsensitiveMatch_returnsRecord() {
        Set<String> emails = new Set<String>{ EMAIL_ACTIVE.toUpperCase() };

        List<Reseller__c> results = ResellerSelector.findActiveByEmails(emails);

        System.assertEquals(1, results.size(),
            'SOQL is case-insensitive; uppercase input should still match the lowercase stored email.');
    }
}
