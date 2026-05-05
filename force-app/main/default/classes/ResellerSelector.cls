/**
 * @description  Single home for every SOQL query against Reseller__c. Helpers,
 *               handlers, batches, and any other business-logic class call
 *               into this Selector instead of writing SOQL inline.
 *
 *               Why a Selector class:
 *                 - One file per SObject means index changes, new field
 *                   selections, and WHERE-clause tuning happen in one place.
 *                 - The Helper stays focused on transformation and dispatch —
 *                   no SOQL clutter mixing with the matching algorithm.
 *                 - Selector methods are independently testable; the
 *                   ResellerSelectorTest class verifies each query's contract
 *                   (active filter, empty input, missing record, etc.) without
 *                   exercising the calling Helper.
 *
 *               This is the de-facto enterprise convention — see FFLib's
 *               Apex Common Selector pattern for the canonical reference.
 *               Methods are public static (stateless), all queries include
 *               a defensive `LIMIT 50000`, and the class respects the
 *               running user's record visibility via `with sharing`.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class ResellerSelector {

    /**
     * @description  Find every ACTIVE Reseller__c whose Company_Email__c is
     *               in the candidate set.
     *
     *               IMPORTANT contract — case sensitivity:
     *                 Company_Email__c is marked External ID, which makes
     *                 SOQL `IN` comparison CASE-SENSITIVE at the indexed
     *                 storage layer (this is intentional Salesforce behavior
     *                 for External ID fields, traded off for index-seek
     *                 performance). Callers MUST normalize their input
     *                 emails (use StringUtils.normalizeEmail) and the
     *                 stored Company_Email__c values must also be normalized
     *                 to the same case. Our project enforces this by:
     *                   - The Helper always normalizes Reseller_Email__c
     *                     before calling this method.
     *                   - Seed data (scripts/apex/seedData.apex) inserts
     *                     resellers with lowercase emails.
     *                 A future ResellerTrigger will normalize Company_Email__c
     *                 on insert/update so manually-entered values from the
     *                 UI also conform automatically.
     *
     * @param  emails  Set of candidate company emails. MUST already be
     *                 normalized (lowercase, trimmed) — pass through
     *                 StringUtils.normalizeEmail before calling.
     * @return  Active Reseller__c records that match exactly (case-sensitive).
     *          Empty list if none match or if the input set is empty.
     */
    public static List<Reseller__c> findActiveByEmails(Set<String> emails) {
        return [
            SELECT Id, Company_Email__c
            FROM Reseller__c
            WHERE Company_Email__c IN :emails
            AND Active__c = true
            LIMIT 50000
        ];
    }
}
