/**
 * @description  Unit tests for TaskTriggerHelper's DML-free logic. Focuses on
 *               collectOpportunityIds (pure filtering) and the empty-input
 *               guards on rollupTaskCounts. The end-to-end rollup is proven in
 *               TaskTriggerHandlerTest (DML-based).
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-20
 */
@IsTest
private class TaskTriggerHelperTest {

    // Only Opportunity WhatIds survive; nulls and other objects are dropped.
    @IsTest
    static void collectOpportunityIds_filtersNullsAndNonOpportunities() {
        Account acc = new Account(Name = 'Acme GmbH');
        insert acc;
        Opportunity opp = TestDataFactory.buildOpportunity('Opp', null);
        insert opp;

        List<Task> tasks = new List<Task>{
            TestDataFactory.buildCompletedTask(opp.Id),    // Opportunity -> kept
            TestDataFactory.buildOpenTask(opp.Id),         // same Opp -> deduped
            TestDataFactory.buildCompletedTask(acc.Id),    // Account -> skipped
            TestDataFactory.buildTask('Orphan', null, 'Completed') // null WhatId -> skipped
        };

        Set<Id> result = TaskTriggerHelper.collectOpportunityIds(tasks);

        System.assertEquals(1, result.size(), 'Only the Opportunity WhatId should be collected.');
        System.assert(result.contains(opp.Id), 'The Opportunity Id must be present.');
    }

    // Null input must not throw — defensive contract for the Handler.
    @IsTest
    static void collectOpportunityIds_nullList_returnsEmpty() {
        System.assertEquals(0, TaskTriggerHelper.collectOpportunityIds(null).size());
    }

    // Empty / null Id sets short-circuit cleanly with no DML.
    @IsTest
    static void rollupTaskCounts_emptyInput_isNoOp() {
        Test.startTest();
        TaskTriggerHelper.rollupTaskCounts(new Set<Id>());
        TaskTriggerHelper.rollupTaskCounts(null);
        Test.stopTest();
        System.assertEquals(0, Limits.getDmlStatements(), 'Empty input must not issue DML.');
    }
}
