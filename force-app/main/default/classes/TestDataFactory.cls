/**
 * @description  Centralized builder for test fixtures across every Apex test
 *               class in the project. Returns UNSAVED records — callers
 *               decide whether to insert via DML or pass directly into a
 *               static method (e.g. for Helper unit tests that exercise the
 *               algorithm without DML).
 *
 *               Why a factory:
 *                 - DRY: the Reseller seed shape is identical in
 *                   OpportunityTriggerHandlerTest, OpportunityTriggerHelperTest,
 *                   and ResellerSelectorTest. Without a factory, every new
 *                   test class repeats the same constructor calls.
 *                 - Schema changes propagate once: when a required field is
 *                   added to Reseller__c, only the factory updates — every
 *                   existing test class keeps compiling.
 *                 - Recruiter signal: TestDataFactory is the de-facto
 *                   enterprise pattern (FFLib, Apex Common); shipping one
 *                   shows the project follows real-world conventions.
 *
 *               This class is intentionally un-annotated with @IsTest at the
 *               class level so it CAN be called from non-test contexts in
 *               the future (e.g. a one-off data-load script). However its
 *               only current callers are tests, and the factory must never
 *               do DML — leave that decision to callers so that unit tests
 *               that prefer in-memory records remain DML-free.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public class TestDataFactory {

    /**
     * @description  Build an UNSAVED Reseller__c with sensible Active=true
     *               defaults and Country='Germany' (the project's primary
     *               market). Caller decides whether to insert.
     * @param  name   Reseller display name.
     * @param  email  Company email — also the matching key for the trigger.
     * @param  type   One of the Reseller_Type__c picklist values.
     * @return  Unsaved Reseller__c record ready for DML or direct use.
     */
    public static Reseller__c buildReseller(String name, String email, String type) {
        return new Reseller__c(
            Name = name,
            Company_Email__c = email,
            Reseller_Type__c = type,
            Country__c = 'Germany',
            Active__c = true
        );
    }

    /**
     * @description  Build an UNSAVED INACTIVE Reseller__c — useful for tests
     *               that need to verify the Active__c filter excludes them
     *               from matching. Same defaults as buildReseller except
     *               Active__c is false.
     * @param  name   Reseller display name.
     * @param  email  Company email.
     * @param  type   Reseller type picklist value.
     * @return  Unsaved inactive Reseller__c record.
     */
    public static Reseller__c buildInactiveReseller(String name, String email, String type) {
        return new Reseller__c(
            Name = name,
            Company_Email__c = email,
            Reseller_Type__c = type,
            Country__c = 'Germany',
            Active__c = false
        );
    }

    /**
     * @description  Build an UNSAVED Opportunity with the minimum required
     *               fields plus a Reseller_Email__c that the trigger will
     *               act on. Stage defaults to 'Prospecting' and CloseDate
     *               to 30 days out — generic values that satisfy
     *               Salesforce's required-field constraints without baking
     *               in test-specific assumptions.
     * @param  name           Opportunity name (helps identify failures in logs).
     * @param  resellerEmail  Reseller_Email__c value; pass null for direct deals.
     * @return  Unsaved Opportunity ready for DML or direct Helper invocation.
     */
    public static Opportunity buildOpportunity(String name, String resellerEmail) {
        return new Opportunity(
            Name = name,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Reseller_Email__c = resellerEmail
        );
    }
}
