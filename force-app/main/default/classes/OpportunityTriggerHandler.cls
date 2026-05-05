/**
 * Thin dispatcher for Opportunity trigger events. Extends Kevin O'Hara's
 * TriggerHandler base class and overrides the framework methods, then
 * delegates to OpportunityTriggerHelper for the actual business logic.
 *
 * Three-layer Kevin O'Hara pattern:
 *   Trigger  ->  Handler (this — dispatches by context)  ->  Helper (logic)
 *
 * Why this class is intentionally tiny:
 *   - Each layer has ONE responsibility — easier to read, review, and extend.
 *   - The Helper's static methods can be unit-tested without a trigger context.
 *   - Adding new contexts (e.g. afterInsert) is a one-line override that
 *     points at a Helper method, with no business logic to re-read or merge.
 */
public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        OpportunityTriggerHelper.assignResellerLookup(
            (List<Opportunity>) Trigger.new,
            null
        );
    }

    public override void beforeUpdate() {
        OpportunityTriggerHelper.assignResellerLookup(
            (List<Opportunity>) Trigger.new,
            (Map<Id, Opportunity>) Trigger.oldMap
        );
    }
}
