/**
 * @description  Routes Reseller__c events to ResellerTriggerHandler. All
 *               seven contexts registered so future logic can be added via a
 *               one-line override on the Handler.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
trigger ResellerTrigger on Reseller__c (
    before insert, before update,
    after insert, after update,
    before delete, after delete,
    after undelete
) {
    // Single dispatch point — the framework routes to the correct override on the handler.
    new ResellerTriggerHandler().run();
}
