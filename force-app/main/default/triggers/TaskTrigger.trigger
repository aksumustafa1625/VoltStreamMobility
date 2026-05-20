/**
 * @description  Routes Task events to TaskTriggerHandler. Only the after-
 *               contexts are registered because the rollup writes to a
 *               different object (Opportunity) and needs committed Ids.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-20
 */
trigger TaskTrigger on Task (
    after insert, after update,
    after delete, after undelete
) {
    new TaskTriggerHandler().run();
}
