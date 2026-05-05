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
     *               in the candidate set. Salesforce SOQL string equality
     *               is case-insensitive, so callers can pass normalized
     *               (lowercase) emails and still match resellers stored
     *               with mixed case.
     *
     *               The Company_Email__c field is marked External ID, so
     *               this WHERE clause hits an index regardless of how many
     *               total resellers exist in the org.
     *
     * @param  emails  Set of candidate company emails (typically already
     *                 normalized via StringUtils.normalizeEmail).
     * @return  Active Reseller__c records that match. Empty list if none
     *          match or if the input set is empty.
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
