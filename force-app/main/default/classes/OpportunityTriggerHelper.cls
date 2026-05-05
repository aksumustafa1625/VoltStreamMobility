/**
 * @description  Business logic for Opportunity trigger events. Pure static
 *               utility methods — the OpportunityTriggerHandler delegates to
 *               this class so that:
 *                 1. The Handler stays a thin dispatcher (one method per
 *                    trigger context).
 *                 2. The logic is unit-testable WITHOUT a trigger context.
 *                 3. Multiple Handler methods (beforeInsert + beforeUpdate)
 *                    share the same matching code path without duplication.
 *
 *               This Helper holds NO SOQL — every Reseller__c query goes
 *               through ResellerSelector. Email normalization goes through
 *               StringUtils. Both choices keep this class focused on the
 *               matching algorithm itself: collect candidate records,
 *               ask for the matching resellers, assign the lookup.
 *
 *               Five-layer Kevin O'Hara pattern as it stands today:
 *                 Trigger -> Handler (dispatch) -> Helper (this — algorithm)
 *                                                        |
 *                                              ResellerSelector (SOQL)
 *                                              StringUtils (normalization)
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class OpportunityTriggerHelper {

    /**
     * @description  Look up the matching Reseller__c for each Opportunity by
     *               company email (case-insensitive via StringUtils, active
     *               resellers only via ResellerSelector) and populate the
     *               Reseller__c lookup field. Bulkified — at most one SOQL
     *               per call regardless of batch size.
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
     *                   from matching by ResellerSelector.
     *
     * @param  opps    Trigger.new list of Opportunity records (mutated
     *                 in-place — the Reseller__c field is set on records
     *                 that match).
     * @param  oldMap  Trigger.oldMap on update; pass null on insert.
     */
    public static void assignResellerLookup(List<Opportunity> opps, Map<Id, Opportunity> oldMap) {
        // Step 1: figure out which records need a fresh match and what emails to query.
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

        // Short-circuit: nothing to query, nothing to assign.
        if (emailsToMatch.isEmpty()) {
            return;
        }

        // Step 2: ask the Selector for the matching active resellers, then
        // build a lookup map keyed by normalized email.
        Map<String, Id> emailToResellerId = new Map<String, Id>();
        for (Reseller__c r : ResellerSelector.findActiveByEmails(emailsToMatch)) {
            emailToResellerId.put(StringUtils.normalizeEmail(r.Company_Email__c), r.Id);
        }

        // Step 3: assign matches; leave null when no match (silent failure by design).
        for (Opportunity opp : oppsNeedingMatch) {
            Id matchedId = emailToResellerId.get(StringUtils.normalizeEmail(opp.Reseller_Email__c));
            opp.Reseller__c = matchedId; // null is acceptable — direct deal or unknown reseller.
        }
    }
}
