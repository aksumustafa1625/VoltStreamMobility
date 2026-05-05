/**
 * @description  Routes Opportunity events to OpportunityTriggerHandler. All
 *               seven contexts registered so future logic can be added via a
 *               one-line override on the Handler.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
trigger OpportunityTrigger on Opportunity (
    before insert, before update,
    after insert, after update,
    before delete, after delete,
    after undelete
) {
    // Single dispatch point — the framework routes to the correct override on the handler.
    new OpportunityTriggerHandler().run();
}
