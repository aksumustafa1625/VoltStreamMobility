/**
 * @description  Business logic for Opportunity trigger events. Pure static
 *               utility methods — the OpportunityTriggerHandler delegates to
 *               this class so that:
 *                 1. The Handler stays a thin dispatcher (one method per
 *                    trigger context).
 *                 2. The logic is unit-testable WITHOUT a trigger context
 *                    (tests can call these statics directly with synthetic
 *                    lists, no DML required).
 *                 3. Multiple Handler methods (beforeInsert + beforeUpdate)
 *                    share the same matching code path without duplication.
 *
 *               Email normalization is delegated to StringUtils so that the
 *               case-insensitive matching contract lives in ONE place — when
 *               normalization rules change (e.g. strip plus-addressing),
 *               only StringUtils changes.
 *
 *               Three-layer Kevin O'Hara pattern:
 *                 Trigger -> Handler (extends TriggerHandler) -> Helper (this)
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class OpportunityTriggerHelper {

    /**
     * @description  Look up the matching Reseller__c for each Opportunity by
     *               company email (case-insensitive via StringUtils, active
     *               resellers only) and populate the Reseller__c lookup
     *               field. Bulkified — one SOQL per call regardless of
     *               batch size.
     *
     *               Behavior:
     *                 - On insert (oldMap == null): process every record with
     *                   a non-blank email.
     *                 - On update (oldMap != null): only re-match records
     *                   whose normalized Reseller_Email__c changed (so a
     *                   pure case change like 'A@x.de' -> 'a@x.de' does not
     *                   trigger a SOQL).
     *                 - Cleared email -> also clear the Reseller lookup.
     *                 - No match found -> leave the lookup null silently
     *                   (never block the save).
     *                 - Inactive resellers (Active__c = false) are excluded
     *                   from matching at the SOQL level.
     *
     * @param  opps    Trigger.new list of Opportunity records (mutated
     *                 in-place — the Reseller__c field is set on records
     *                 that match).
     * @param  oldMap  Trigger.oldMap on update; pass null on insert.
     */
    public static void assignResellerLookup(List<Opportunity> opps, Map<Id, Opportunity> oldMap) {
        // Step 1: collect normalized emails for records that need matching.
        Set<String> emailsToMatch = new Set<String>();
        List<Opportunity> oppsNeedingMatch = new List<Opportunity>();

        for (Opportunity opp : opps) {
            String normalizedEmail = StringUtils.normalizeEmail(opp.Reseller_Email__c);

            // On update: skip records whose normalized email did not change.
            // Comparing normalized values means a pure case change is treated
            // as a no-op — saves a SOQL on irrelevant edits.
            if (oldMap != null) {
                String normalizedOldEmail = StringUtils.normalizeEmail(
                    oldMap.get(opp.Id).Reseller_Email__c
                );
                if (normalizedEmail == normalizedOldEmail) {
                    continue;
                }
            }

            // Email was cleared (or was never set) -> clear the lookup too.
            if (normalizedEmail == null) {
                opp.Reseller__c = null;
                continue;
            }

            emailsToMatch.add(normalizedEmail);
            oppsNeedingMatch.add(opp);
        }

        // Short-circuit when no records need a SOQL — protects governor limits on no-op updates.
        if (emailsToMatch.isEmpty()) {
            return;
        }

        // Step 2: single bulkified SOQL — only ACTIVE resellers whose email
        // is in the candidate set. Two scalability wins over a fetch-all-active
        // approach:
        //   1. The Company_Email__c index (it's marked External ID) turns this
        //      into an index seek even at hundreds of thousands of resellers.
        //   2. The defensive LIMIT 50000 caps the worst case at the platform
        //      ceiling — never silently fan out beyond that.
        // Salesforce SOQL '=' and 'IN' on text fields are case-insensitive, so
        // a stored 'Partner@x.de' still matches a normalized 'partner@x.de' in
        // the candidate set.
        Map<String, Id> emailToResellerId = new Map<String, Id>();
        for (Reseller__c r : [
            SELECT Id, Company_Email__c
            FROM Reseller__c
            WHERE Company_Email__c IN :emailsToMatch
            AND Active__c = true
            LIMIT 50000
        ]) {
            emailToResellerId.put(StringUtils.normalizeEmail(r.Company_Email__c), r.Id);
        }

        // Step 3: assign matches; leave null when no match (silent failure by design).
        for (Opportunity opp : oppsNeedingMatch) {
            Id matchedId = emailToResellerId.get(StringUtils.normalizeEmail(opp.Reseller_Email__c));
            opp.Reseller__c = matchedId; // null is acceptable — direct deal or unknown reseller.
        }
    }
}
