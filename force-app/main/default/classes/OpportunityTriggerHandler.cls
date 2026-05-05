/**
 * @description  Dispatches Opportunity trigger events to OpportunityTriggerHelper.
 *               Extends the Kevin O'Hara TriggerHandler base class.
 *               Trigger -> Handler (this) -> Helper (logic).
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    /** @description  Match Reseller on insert (no oldMap available). */
    public override void beforeInsert() {
        OpportunityTriggerHelper.assignResellerLookup(
            (List<Opportunity>) Trigger.new,
            null
        );
    }

    /** @description  Re-match Reseller on update; oldMap lets the Helper skip unchanged emails. */
    public override void beforeUpdate() {
        OpportunityTriggerHelper.assignResellerLookup(
            (List<Opportunity>) Trigger.new,
            (Map<Id, Opportunity>) Trigger.oldMap
        );
    }
}
