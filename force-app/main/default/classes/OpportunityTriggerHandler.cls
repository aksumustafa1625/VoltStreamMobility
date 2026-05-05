/**
 * @description  Thin dispatcher for Opportunity trigger events. Extends Kevin
 *               O'Hara's TriggerHandler base class and overrides the framework
 *               methods, then delegates to OpportunityTriggerHelper for the
 *               actual business logic.
 *
 *               Three-layer Kevin O'Hara pattern:
 *                 Trigger -> Handler (this — dispatches by context) -> Helper (logic)
 *
 *               Why this class is intentionally tiny:
 *                 - Each layer has ONE responsibility, easier to read and review.
 *                 - The Helper's static methods can be unit-tested without a
 *                   trigger context.
 *                 - Adding new contexts (e.g. afterInsert) is a one-line override
 *                   that points at a Helper method, with no business logic to
 *                   re-read or merge.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    /**
     * @description  Delegate before-insert events to the Helper for reseller
     *               matching. Passes null as oldMap because there is no prior
     *               record state on insert.
     */
    public override void beforeInsert() {
        OpportunityTriggerHelper.assignResellerLookup(
            (List<Opportunity>) Trigger.new,
            null
        );
    }

    /**
     * @description  Delegate before-update events to the Helper for reseller
     *               re-matching. Passes Trigger.oldMap so the Helper can skip
     *               records whose Reseller_Email__c value did not change,
     *               saving a SOQL when unrelated fields are touched.
     */
    public override void beforeUpdate() {
        OpportunityTriggerHelper.assignResellerLookup(
            (List<Opportunity>) Trigger.new,
            (Map<Id, Opportunity>) Trigger.oldMap
        );
    }
}
