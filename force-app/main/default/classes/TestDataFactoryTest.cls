/**
 * @description  Unit tests for TestDataFactory. Verifies that each builder
 *               returns an unsaved record with the documented defaults so
 *               other test classes can rely on those defaults without
 *               re-asserting them everywhere.
 *
 *               No DML is performed — the factory itself does no DML, and
 *               these tests don't need any to verify field assignment.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
@IsTest
private class TestDataFactoryTest {

    // buildReseller must apply the documented defaults: Active=true, Country='Germany'.
    @IsTest
    static void buildReseller_setsExpectedDefaults() {
        Reseller__c r = TestDataFactory.buildReseller(
            'Acme GmbH', 'kontakt@acme.de', 'Hotel Chain'
        );
        System.assertEquals('Acme GmbH',          r.Name);
        System.assertEquals('kontakt@acme.de',    r.Company_Email__c);
        System.assertEquals('Hotel Chain',        r.Reseller_Type__c);
        System.assertEquals('Germany',            r.Country__c);
        System.assertEquals(true,                 r.Active__c,
            'buildReseller must default Active__c to true.');
    }

    // buildInactiveReseller is a deliberate variant — same defaults except Active=false.
    @IsTest
    static void buildInactiveReseller_setsActiveFalse() {
        Reseller__c r = TestDataFactory.buildInactiveReseller(
            'Churned GmbH', 'old@churned.de', 'Energy Company'
        );
        System.assertEquals('Churned GmbH', r.Name);
        System.assertEquals(false, r.Active__c,
            'buildInactiveReseller must default Active__c to false.');
        System.assertEquals('Germany', r.Country__c,
            'Country default should still apply on the inactive variant.');
    }

    // buildOpportunity must satisfy required-field constraints with sensible defaults.
    @IsTest
    static void buildOpportunity_setsExpectedDefaults() {
        Opportunity o = TestDataFactory.buildOpportunity('Big deal', 'partner@x.de');
        System.assertEquals('Big deal',          o.Name);
        System.assertEquals('Prospecting',       o.StageName);
        System.assertEquals('partner@x.de',      o.Reseller_Email__c);
        System.assertEquals(Date.today().addDays(30), o.CloseDate,
            'CloseDate default should be 30 days from today.');
    }

    // Null email is a valid input — the factory must not coerce it to anything else.
    @IsTest
    static void buildOpportunity_nullEmail_preserved() {
        Opportunity o = TestDataFactory.buildOpportunity('Direct deal', null);
        System.assertEquals(null, o.Reseller_Email__c,
            'Null reseller email must pass through unchanged for direct-deal scenarios.');
    }
}
