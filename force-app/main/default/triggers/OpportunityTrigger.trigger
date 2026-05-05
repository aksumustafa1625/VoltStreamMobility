trigger OpportunityTrigger on Opportunity (
    before insert, before update,
    after insert, after update,
    before delete, after delete,
    after undelete
) {
    new OpportunityTriggerHandler().run();
}
