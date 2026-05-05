/**
 * @description  Single home for every SOQL query against Reseller__c. Helpers
 *               and Handlers call here instead of inlining SOQL — index
 *               changes, new field selections, and WHERE-clause tuning all
 *               happen in one place. Methods are public static with `with
 *               sharing` and a defensive LIMIT 50000.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class ResellerSelector {

    /**
     * @description  Find ACTIVE Reseller__c records whose Company_Email__c is
     *               in the candidate set.
     *               IMPORTANT: Company_Email__c is External ID, which makes
     *               SOQL `IN` case-SENSITIVE. Callers MUST normalize input
     *               emails (StringUtils.normalizeEmail). Stored values are
     *               kept lowercase by ResellerTriggerHelper, so case-
     *               insensitive matching works end-to-end.
     *
     * @param  emails  Set of normalized (lowercase, trimmed) candidate emails.
     * @return  Active matching resellers; empty list if none match.
     */
    public static List<Reseller__c> findActiveByEmails(Set<String> emails) {
        // WITH USER_MODE enforces field- and object-level security based on
        // the running user's permissions, on top of the class's `with sharing`
        // record visibility. This is the modern (API 60+) replacement for
        // Schema.sObjectType.X.isAccessible() guards and is what Salesforce
        // recommends for any SOQL that runs in user context.
        return [
            SELECT Id, Company_Email__c
            FROM Reseller__c
            WHERE Company_Email__c IN :emails
            AND Active__c = true
            WITH USER_MODE
            LIMIT 50000
        ];
    }
}
