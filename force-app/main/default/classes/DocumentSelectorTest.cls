/**
 * @description  Unit tests for DocumentSelector. Verifies query contracts:
 *               category filter, null/blank category returns everything,
 *               category counts include zero defaults.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
@IsTest
private class DocumentSelectorTest {

    @TestSetup
    static void setup() {
        insert new List<Document__c>{
            new Document__c(Name = 'Application1.pdf', Category__c = 'Application Forms', File_Type__c = 'PDF', File_Size_KB__c = 59),
            new Document__c(Name = 'Application2.pdf', Category__c = 'Application Forms', File_Type__c = 'PDF', File_Size_KB__c = 74),
            new Document__c(Name = 'Statement1.pdf',   Category__c = 'Statements',        File_Type__c = 'PDF', File_Size_KB__c = 120),
            new Document__c(Name = 'Report1.pdf',      Category__c = 'Reports',           File_Type__c = 'PDF', File_Size_KB__c = 200)
        };
    }

    // findByCategory filtered: returns only matching records.
    @IsTest
    static void findByCategory_matching_returnsThoseRecords() {
        List<Document__c> docs = DocumentSelector.findByCategory('Application Forms');
        System.assertEquals(2, docs.size(),
            'Application Forms should have 2 docs.');
    }

    // findByCategory with null returns everything.
    @IsTest
    static void findByCategory_null_returnsAll() {
        List<Document__c> docs = DocumentSelector.findByCategory(null);
        System.assertEquals(4, docs.size(),
            'Null category should return every document.');
    }

    // findByCategory with blank returns everything.
    @IsTest
    static void findByCategory_blank_returnsAll() {
        List<Document__c> docs = DocumentSelector.findByCategory('   ');
        System.assertEquals(4, docs.size(),
            'Blank category should be treated as null and return all docs.');
    }

    // findByCategory with unknown category returns empty list.
    @IsTest
    static void findByCategory_unknown_returnsEmpty() {
        List<Document__c> docs = DocumentSelector.findByCategory('Does Not Exist');
        System.assertEquals(0, docs.size(),
            'Unknown category must return an empty list, not an exception.');
    }

    // getRecentActivity returns the latest 5 documents, newest first.
    @IsTest
    static void getRecentActivity_returnsLatestFiveDescending() {
        // The @TestSetup inserted 4 records, so we should get all 4 back,
        // ordered with the latest CreatedDate at the top of the list.
        List<Document__c> recent = DocumentSelector.getRecentActivity();

        System.assert(recent.size() <= 5,
            'getRecentActivity must never return more than 5 rows.');
        System.assertEquals(4, recent.size(),
            'All 4 seeded documents should appear in the recent list.');

        // Order: each next record's CreatedDate must be <= the previous one.
        for (Integer i = 1; i < recent.size(); i++) {
            System.assert(
                recent[i - 1].CreatedDate >= recent[i].CreatedDate,
                'Recent activity must be ordered DESC by CreatedDate.'
            );
        }
    }

    // getCategoryCounts populates all four buckets, even empty ones.
    @IsTest
    static void getCategoryCounts_returnsAllFourBuckets() {
        Map<String, Integer> counts = DocumentSelector.getCategoryCounts();

        System.assertEquals(4, counts.size(),
            'Result map must always contain all four canonical category keys.');
        System.assertEquals(2, counts.get('Application Forms'));
        System.assertEquals(1, counts.get('Statements'));
        System.assertEquals(1, counts.get('Reports'));
        System.assertEquals(0, counts.get('Uncategorized'),
            'Empty categories must default to 0 so the UI always has 4 cards.');
    }
}
