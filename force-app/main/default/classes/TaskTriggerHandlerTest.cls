/**
 * @description  Integration tests for TaskTrigger + Handler + Helper + Selector.
 *               Fires real DML so the trigger runs end-to-end and the rollup
 *               fields (Opportunity.Score__c, Opportunity.completed_task__c)
 *               are actually written. Proves the Apex replacement for the DLRS
 *               package across insert, update, complete, delete, undelete,
 *               re-parent, bulk, and non-Opportunity scenarios.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-20
 */
@IsTest
private class TaskTriggerHandlerTest {

    @TestSetup
    static void setup() {
        insert new List<Opportunity>{
            TestDataFactory.buildOpportunity('Opp A', null),
            TestDataFactory.buildOpportunity('Opp B', null)
        };
    }

    private static Id oppA() {
        return [SELECT Id FROM Opportunity WHERE Name = 'Opp A' LIMIT 1].Id;
    }
    private static Id oppB() {
        return [SELECT Id FROM Opportunity WHERE Name = 'Opp B' LIMIT 1].Id;
    }
    private static Opportunity reload(Id oppId) {
        return [SELECT Score__c, completed_task__c FROM Opportunity WHERE Id = :oppId];
    }

    // Inserting a Completed Task bumps both the total and the completed count.
    @IsTest
    static void insert_completedTask_incrementsBothCounts() {
        Id opp = oppA();
        Test.startTest();
        insert TestDataFactory.buildCompletedTask(opp);
        Test.stopTest();

        Opportunity result = reload(opp);
        System.assertEquals(1, result.Score__c, 'Total task count should be 1.');
        System.assertEquals(1, result.completed_task__c, 'Completed task count should be 1.');
    }

    // An open Task counts toward the total but not the completed subtotal.
    @IsTest
    static void insert_openTask_incrementsTotalOnly() {
        Id opp = oppA();
        Test.startTest();
        insert TestDataFactory.buildOpenTask(opp);
        Test.stopTest();

        Opportunity result = reload(opp);
        System.assertEquals(1, result.Score__c, 'Total includes open tasks.');
        System.assertEquals(0, result.completed_task__c, 'Open task is not Completed.');
    }

    // Mixed batch in one insert: total = all, completed = Completed only.
    @IsTest
    static void insert_mixedTasks_countsCorrectly() {
        Id opp = oppA();
        Test.startTest();
        insert new List<Task>{
            TestDataFactory.buildCompletedTask(opp),
            TestDataFactory.buildCompletedTask(opp),
            TestDataFactory.buildOpenTask(opp)
        };
        Test.stopTest();

        Opportunity result = reload(opp);
        System.assertEquals(3, result.Score__c);
        System.assertEquals(2, result.completed_task__c);
    }

    // Completing an existing open Task moves it into the completed subtotal.
    @IsTest
    static void update_completeOpenTask_incrementsCompleted() {
        Id opp = oppA();
        Task t = TestDataFactory.buildOpenTask(opp);
        insert t;

        Test.startTest();
        t.Status = 'Completed';
        update t;
        Test.stopTest();

        Opportunity result = reload(opp);
        System.assertEquals(1, result.Score__c);
        System.assertEquals(1, result.completed_task__c, 'Completing the task bumps the completed count.');
    }

    // Deleting the only Task resets both counts to zero (not stale).
    @IsTest
    static void delete_completedTask_resetsCounts() {
        Id opp = oppA();
        Task t = TestDataFactory.buildCompletedTask(opp);
        insert t;

        Test.startTest();
        delete t;
        Test.stopTest();

        Opportunity result = reload(opp);
        System.assertEquals(0, result.Score__c, 'Deleting the last task resets total to 0.');
        System.assertEquals(0, result.completed_task__c);
    }

    // Undelete restores the counts the delete removed.
    @IsTest
    static void undelete_restoresCounts() {
        Id opp = oppA();
        Task t = TestDataFactory.buildCompletedTask(opp);
        insert t;
        delete t;

        Test.startTest();
        undelete t;
        Test.stopTest();

        Opportunity result = reload(opp);
        System.assertEquals(1, result.Score__c);
        System.assertEquals(1, result.completed_task__c);
    }

    // Re-parenting a Task recomputes BOTH the old and the new Opportunity.
    @IsTest
    static void reparent_task_recomputesBothOpportunities() {
        Id a = oppA();
        Id b = oppB();
        Task t = TestDataFactory.buildCompletedTask(a);
        insert t;

        Test.startTest();
        t.WhatId = b;
        update t;
        Test.stopTest();

        Opportunity afterA = reload(a);
        Opportunity afterB = reload(b);
        System.assertEquals(0, afterA.Score__c, 'Old parent loses the task.');
        System.assertEquals(0, afterA.completed_task__c);
        System.assertEquals(1, afterB.Score__c, 'New parent gains the task.');
        System.assertEquals(1, afterB.completed_task__c);
    }

    // A Task on a non-Opportunity parent must not error or touch the rollup.
    @IsTest
    static void nonOpportunityTask_doesNotAffectRollup() {
        Account acc = new Account(Name = 'Acme GmbH');
        insert acc;

        Test.startTest();
        insert TestDataFactory.buildCompletedTask(acc.Id); // WhatId = Account
        Test.stopTest();

        // The Opportunity was never touched by the rollup, so its count stays
        // null (unwritten) rather than 0 — proving the WhatId filter works.
        System.assertEquals(null, reload(oppA()).Score__c, 'Account task must not affect Opportunity rollup.');
    }

    // 200 Tasks in one batch prove bulkification (1 aggregate SOQL + 1 DML).
    @IsTest
    static void bulk_tasks_areBulkified() {
        Id opp = oppA();
        List<Task> tasks = new List<Task>();
        for (Integer i = 0; i < 200; i++) {
            tasks.add(i < 120
                ? TestDataFactory.buildCompletedTask(opp)
                : TestDataFactory.buildOpenTask(opp));
        }

        Test.startTest();
        insert tasks;
        Test.stopTest();

        Opportunity result = reload(opp);
        System.assertEquals(200, result.Score__c, 'All 200 tasks counted in the total.');
        System.assertEquals(120, result.completed_task__c, '120 of them are Completed.');
    }
}
