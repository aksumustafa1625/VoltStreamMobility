/**
 * @description  Dispatches Task trigger events to TaskTriggerHelper. Extends
 *               the Kevin O'Hara TriggerHandler base class.
 *               Trigger -> Handler (this) -> Helper (logic) -> Selector.
 *
 *               Replaces the DLRS managed-package rollup that maintained
 *               Opportunity.Score__c (total Tasks) and
 *               Opportunity.completed_task__c (Completed Tasks). On every
 *               relevant context it recomputes both counts for the affected
 *               Opportunities in one aggregate query plus one DML update.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-20
 */
public with sharing class TaskTriggerHandler extends TriggerHandler {

    /** @description  New Tasks: roll up their parent Opportunities. */
    public override void afterInsert() {
        TaskTriggerHelper.rollupTaskCounts(
            TaskTriggerHelper.collectOpportunityIds((List<Task>) Trigger.new)
        );
    }

    /**
     * @description  Updated Tasks: a status change or a re-parent (WhatId
     *               change) can affect both the old and the new Opportunity,
     *               so recompute the union of both.
     */
    public override void afterUpdate() {
        Set<Id> affected = TaskTriggerHelper.collectOpportunityIds((List<Task>) Trigger.new);
        affected.addAll(TaskTriggerHelper.collectOpportunityIds((List<Task>) Trigger.old));
        TaskTriggerHelper.rollupTaskCounts(affected);
    }

    /** @description  Deleted Tasks: roll up the Opportunities they belonged to. */
    public override void afterDelete() {
        TaskTriggerHelper.rollupTaskCounts(
            TaskTriggerHelper.collectOpportunityIds((List<Task>) Trigger.old)
        );
    }

    /** @description  Restored Tasks: recompute so undelete restores the counts. */
    public override void afterUndelete() {
        TaskTriggerHelper.rollupTaskCounts(
            TaskTriggerHelper.collectOpportunityIds((List<Task>) Trigger.new)
        );
    }
}
