/**
 * @description  Opportunity trigger — registers all seven trigger contexts and
 *               delegates execution to OpportunityTriggerHandler via the
 *               Kevin O'Hara framework. No business logic lives in this file
 *               by design: the trigger only routes, the Handler dispatches by
 *               context, and the Helper holds the actual matching algorithm.
 *
 *               All seven contexts are registered up-front so that future logic
 *               additions (e.g. an audit-log feature on afterUpdate) only need
 *               a one-line override in the Handler — never a redeploy of the
 *               trigger header itself.
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
