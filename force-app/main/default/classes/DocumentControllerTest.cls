/**
 * @description  Unit tests for DocumentController. The controller is a thin
 *               facade so the tests focus on verifying it delegates to
 *               DocumentSelector and returns the expected shapes for the
 *               LWC to consume.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
@IsTest
private class DocumentControllerTest {

    @TestSetup
    static void setup() {
        insert new List<Document__c>{
            new Document__c(Name = 'A.pdf',       Category__c = 'Application Forms', File_Type__c = 'PDF', File_Size_KB__c = 50),
            new Document__c(Name = 'B.pdf',       Category__c = 'Application Forms', File_Type__c = 'PDF', File_Size_KB__c = 60),
            new Document__c(Name = 'S.pdf',       Category__c = 'Statements',        File_Type__c = 'PDF', File_Size_KB__c = 80)
        };
    }

    // getDocuments with category returns only matching records.
    @IsTest
    static void getDocuments_withCategory_returnsFiltered() {
        List<Document__c> docs = DocumentController.getDocuments('Application Forms');
        System.assertEquals(2, docs.size());
    }

    // getDocuments with null returns everything.
    @IsTest
    static void getDocuments_null_returnsAll() {
        List<Document__c> docs = DocumentController.getDocuments(null);
        System.assertEquals(3, docs.size());
    }

    // getCategoryCounts always returns all four buckets.
    @IsTest
    static void getCategoryCounts_returnsFourBucketsWithZeros() {
        Map<String, Integer> counts = DocumentController.getCategoryCounts();
        System.assertEquals(4, counts.size());
        System.assertEquals(2, counts.get('Application Forms'));
        System.assertEquals(1, counts.get('Statements'));
        System.assertEquals(0, counts.get('Reports'));
        System.assertEquals(0, counts.get('Uncategorized'));
    }
}
