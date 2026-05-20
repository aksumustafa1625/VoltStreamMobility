/**
 * @description  Single home for every SOQL query against Task that backs the
 *               Opportunity task rollup. Replaces the SOQL the DLRS package
 *               ran per-record with one bulk aggregate query.
 *
 *               SHARING: declared `without sharing` on purpose. A rollup must
 *               count EVERY child Task regardless of the running user's record
 *               visibility — exactly what the DLRS package did in system
 *               context. Enforcing the user's sharing here would under-count
 *               tasks the user can't see and corrupt the rollup. For the same
 *               reason the aggregate query intentionally omits WITH USER_MODE.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-20
 */
public without sharing class TaskSelector {

    /**
     * @description  Count related Tasks per Opportunity, broken down by Status,
     *               in a single aggregate query. The Helper folds the per-status
     *               rows into a total (Score) and a Completed-only subtotal
     *               (completed_task__c). One SOQL for any number of Opportunities.
     *
     * @param  opportunityIds  Opportunity Ids whose Tasks should be counted.
     * @return  AggregateResult rows with aliases: wid (WhatId), stat (Status),
     *          cnt (COUNT(Id)). Empty list if no Tasks exist.
     */
    public static List<AggregateResult> countTasksByOpportunity(Set<Id> opportunityIds) {
        return [
            SELECT WhatId wid, Status stat, COUNT(Id) cnt
            FROM Task
            WHERE WhatId IN :opportunityIds
            GROUP BY WhatId, Status
            LIMIT 50000
        ];
    }
}
