/**
 * @description  Unit tests for TestDataFactory. Verifies each builder returns
 *               an unsaved record with the documented defaults. No DML.
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

    // A well-formed Opportunity Id that is never inserted — the Task builders
    // only copy the value, so no DML is needed to pin their defaults.
    private static Id fakeOpportunityId() {
        return Opportunity.SObjectType.getDescribe().getKeyPrefix() + '000000000001AAA';
    }

    // buildTask passes Subject / WhatId / Status straight through — no hidden defaults.
    @IsTest
    static void buildTask_setsSubjectWhatIdStatus() {
        Id oppId = fakeOpportunityId();
        Task t = TestDataFactory.buildTask('Call partner', oppId, 'In Progress');
        System.assertEquals('Call partner', t.Subject);
        System.assertEquals(oppId,          t.WhatId,
            'buildTask must attach the Task to the parent Id it was given.');
        System.assertEquals('In Progress',  t.Status,
            'buildTask must use the Status it was given, not a default.');
    }

    // buildCompletedTask pins Status='Completed' and the documented subject.
    @IsTest
    static void buildCompletedTask_setsCompletedStatus() {
        Id oppId = fakeOpportunityId();
        Task t = TestDataFactory.buildCompletedTask(oppId);
        System.assertEquals('Completed',      t.Status,
            'buildCompletedTask must default Status to Completed.');
        System.assertEquals('Completed task', t.Subject);
        System.assertEquals(oppId,            t.WhatId);
    }

    // buildOpenTask pins Status='Not Started' and the documented subject.
    @IsTest
    static void buildOpenTask_setsNotStartedStatus() {
        Id oppId = fakeOpportunityId();
        Task t = TestDataFactory.buildOpenTask(oppId);
        System.assertEquals('Not Started', t.Status,
            'buildOpenTask must default Status to Not Started.');
        System.assertEquals('Open task',   t.Subject);
        System.assertEquals(oppId,         t.WhatId);
    }
}
