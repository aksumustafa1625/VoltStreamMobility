/**
 * @description  Dispatches Reseller__c trigger events to ResellerTriggerHelper.
 *               Extends Kevin O'Hara's TriggerHandler. Only beforeInsert and
 *               beforeUpdate are overridden — field mutation only works in the
 *               BEFORE phase.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class ResellerTriggerHandler extends TriggerHandler {

    /** @description  Normalize Reseller fields on insert. */
    public override void beforeInsert() {
        ResellerTriggerHelper.normalizeFields((List<Reseller__c>) Trigger.new);
    }

    /** @description  Normalize Reseller fields on update (UI / API / mass update). */
    public override void beforeUpdate() {
        ResellerTriggerHelper.normalizeFields((List<Reseller__c>) Trigger.new);
    }
}
