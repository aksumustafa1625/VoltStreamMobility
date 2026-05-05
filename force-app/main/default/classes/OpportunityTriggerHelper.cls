/**
 * @description  Channel-partner matching logic for Opportunity. SOQL goes
 *               through ResellerSelector, normalization through StringUtils,
 *               so this class stays focused on the algorithm.
 *               Trigger -> Handler -> Helper (this) -> Selector / StringUtils.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class OpportunityTriggerHelper {

    /**
     * @description  Look up the matching Reseller__c by company email and
     *               populate the lookup field. Bulkified — at most one SOQL
     *               per call. Insert: process records with non-blank email.
     *               Update: only re-match when normalized email changed. No
     *               match -> leave lookup null silently.
     *
     * @param  opps    Trigger.new (mutated in place).
     * @param  oldMap  Trigger.oldMap on update; null on insert.
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
