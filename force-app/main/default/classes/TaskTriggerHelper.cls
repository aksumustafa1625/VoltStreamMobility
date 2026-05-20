/**
 * @description  Stateless rollup logic for the Task -> Opportunity counts that
 *               replace the DLRS package. SOQL goes through TaskSelector; this
 *               class only collects affected parents and writes the counts.
 *               Trigger -> Handler -> Helper (this) -> Selector.
 *
 *               SHARING: `without sharing` so the rollup update runs in system
 *               context and never fails because the Task-editing user lacks
 *               edit access to the parent Opportunity — same behaviour as the
 *               DLRS package it replaces. The rollup fields are system-owned.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-20
 */
public without sharing class TaskTriggerHelper {

    private static final String COMPLETED_STATUS = 'Completed';

    // Opportunity key prefix ('006') — used to keep only Opportunity parents
    // out of Task.WhatId, which is polymorphic (Account, Case, custom, ...).
    private static final String OPPORTUNITY_PREFIX =
        Opportunity.SObjectType.getDescribe().getKeyPrefix();

    /**
     * @description  Pull the Opportunity Ids out of a list of Tasks, skipping
     *               nulls and any WhatId that points at a non-Opportunity
     *               object. Pure and DML-free — unit-testable in isolation.
     *
     * @param  tasks  Trigger.new or Trigger.old.
     * @return  Distinct Opportunity Ids referenced by the Tasks; never null.
     */
    public static Set<Id> collectOpportunityIds(List<Task> tasks) {
        Set<Id> opportunityIds = new Set<Id>();
        if (tasks == null) {
            return opportunityIds;
        }
        for (Task t : tasks) {
            if (t.WhatId != null && String.valueOf(t.WhatId).startsWith(OPPORTUNITY_PREFIX)) {
                opportunityIds.add(t.WhatId);
            }
        }
        return opportunityIds;
    }

    /**
     * @description  Recompute Score__c (total Tasks) and completed_task__c
     *               (Completed Tasks) for the given Opportunities, then update
     *               them. One aggregate SOQL plus one DML update regardless of
     *               how many Opportunities or Tasks are involved — the
     *               efficiency win over the per-record DLRS rollup.
     *
     * @param  opportunityIds  Opportunities to recompute; no-op if empty.
     */
    public static void rollupTaskCounts(Set<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return;
        }

        // Seed every affected Opportunity with zeros so one whose last Task was
        // just deleted is reset to 0 instead of keeping a stale count.
        Map<Id, Integer> totalByOpp = new Map<Id, Integer>();
        Map<Id, Integer> completedByOpp = new Map<Id, Integer>();
        for (Id oppId : opportunityIds) {
            totalByOpp.put(oppId, 0);
            completedByOpp.put(oppId, 0);
        }

        // Fold the per-status aggregate rows into a total and a Completed subtotal.
        for (AggregateResult ar : TaskSelector.countTasksByOpportunity(opportunityIds)) {
            Id oppId = (Id) ar.get('wid');
            String status = (String) ar.get('stat');
            Integer count = (Integer) ar.get('cnt');

            totalByOpp.put(oppId, totalByOpp.get(oppId) + count);
            if (COMPLETED_STATUS.equalsIgnoreCase(status)) {
                completedByOpp.put(oppId, completedByOpp.get(oppId) + count);
            }
        }

        List<Opportunity> toUpdate = new List<Opportunity>();
        for (Id oppId : opportunityIds) {
            toUpdate.add(new Opportunity(
                Id = oppId,
                Score__c = totalByOpp.get(oppId),
                completed_task__c = completedByOpp.get(oppId)
            ));
        }
        update toUpdate;
    }
}
