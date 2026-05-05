/**
 * Handles Opportunity trigger events for the VoltStream channel-partner workflow.
 * Extends Kevin O'Hara's TriggerHandler base class so we inherit recursion control,
 * bypass API, and max-loop protection (see TriggerHandler.cls).
 *
 * Responsibility: when an Opportunity is inserted or updated with a Reseller_Email__c,
 * find the matching Reseller__c by Company_Email__c (case-insensitive) and populate
 * the Reseller__c lookup. If no match is found, leave the lookup null silently —
 * a missing reseller must never block the Opportunity from saving.
 */
public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        assignResellerLookup((List<Opportunity>) Trigger.new, null);
    }

    public override void beforeUpdate() {
        assignResellerLookup(
            (List<Opportunity>) Trigger.new,
            (Map<Id, Opportunity>) Trigger.oldMap
        );
    }

    /**
     * Core matching logic. Bulkified to handle 200-record trigger batches in a
     * single SOQL query. Pass a non-null oldMap on update to skip records whose
     * Reseller_Email__c didn't change (no need to re-query).
     */
    private void assignResellerLookup(List<Opportunity> opps, Map<Id, Opportunity> oldMap) {
        // Step 1: collect lowercase emails from records whose email changed (or all on insert)
        Set<String> emailsToMatch = new Set<String>();
        List<Opportunity> oppsNeedingMatch = new List<Opportunity>();

        for (Opportunity opp : opps) {
            String newEmail = opp.Reseller_Email__c;

            // On update: skip if email didn't change
            if (oldMap != null) {
                String oldEmail = oldMap.get(opp.Id).Reseller_Email__c;
                if (newEmail == oldEmail) {
                    continue;
                }
            }

            // If the email was cleared, also clear the lookup
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

        // Step 2: single bulkified SOQL — fetch every active reseller whose lowercase
        // email is in the set. We compare lowercase on both sides to honor the
        // case-insensitive matching rule.
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
