/**
 * Business logic for Opportunity trigger events. Pure static utility methods —
 * the OpportunityTriggerHandler delegates to this class so that:
 *   1. The Handler stays a thin dispatcher (one method per trigger context).
 *   2. The logic is unit-testable WITHOUT a trigger context (tests can call
 *      these statics directly with synthetic lists, no DML required).
 *   3. Multiple Handler methods (beforeInsert + beforeUpdate) can share the
 *      same matching code path without duplication.
 *
 * Three-layer Kevin O'Hara pattern:
 *   Trigger  ->  Handler (extends TriggerHandler, dispatches)  ->  Helper (this)
 */
public with sharing class OpportunityTriggerHelper {

    /**
     * Look up the matching Reseller__c for each Opportunity by company email
     * (case-insensitive, active resellers only) and populate the Reseller__c
     * lookup field. Bulkified — one SOQL per call regardless of batch size.
     *
     * Behavior:
     *   - On insert (oldMap == null): process every record with a non-null email.
     *   - On update (oldMap != null): only re-match records whose
     *     Reseller_Email__c value actually changed; saves SOQL on unrelated
     *     field updates.
     *   - Cleared email -> also clear the Reseller lookup.
     *   - No match found -> leave the lookup null silently (never block the save).
     *   - Inactive resellers (Active__c = false) are excluded from matching.
     *
     * @param opps    Trigger.new list of Opportunity records (mutated in-place
     *                — the Reseller__c field is set on records that match).
     * @param oldMap  Trigger.oldMap on update; pass null on insert.
     */
    public static void assignResellerLookup(List<Opportunity> opps, Map<Id, Opportunity> oldMap) {
        // Step 1: figure out which records need matching, and collect their lowercase emails
        Set<String> emailsToMatch = new Set<String>();
        List<Opportunity> oppsNeedingMatch = new List<Opportunity>();

        for (Opportunity opp : opps) {
            String newEmail = opp.Reseller_Email__c;

            // On update: skip records whose email did not change
            if (oldMap != null) {
                String oldEmail = oldMap.get(opp.Id).Reseller_Email__c;
                if (newEmail == oldEmail) {
                    continue;
                }
            }

            // Email cleared -> clear the lookup too
            if (String.isBlank(newEmail)) {
                opp.Reseller__c = null;
                continue;
            }

            emailsToMatch.add(newEmail.toLowerCase());
            oppsNeedingMatch.add(opp);
        }

        if (emailsToMatch.isEmpty()) {
            return;
        }

        // Step 2: single bulkified SOQL — only ACTIVE resellers participate.
        // Compare lowercase on both sides to honor case-insensitive matching.
        Map<String, Id> emailToResellerId = new Map<String, Id>();
        for (Reseller__c r : [
            SELECT Id, Company_Email__c
            FROM Reseller__c
            WHERE Company_Email__c != null
            AND Active__c = true
        ]) {
            emailToResellerId.put(r.Company_Email__c.toLowerCase(), r.Id);
        }

        // Step 3: assign matches; leave null when no match (silent failure by design)
        for (Opportunity opp : oppsNeedingMatch) {
            Id matchedId = emailToResellerId.get(opp.Reseller_Email__c.toLowerCase());
            opp.Reseller__c = matchedId; // null is acceptable — direct deal or unknown reseller
        }
    }
}
