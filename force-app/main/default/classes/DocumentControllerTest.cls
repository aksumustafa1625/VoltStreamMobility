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

    // uploadDocument with base64 content creates both Document__c and ContentVersion.
    @IsTest
    static void uploadDocument_withContent_createsBothRecords() {
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Hello world'));

        Test.startTest();
        Id docId = DocumentController.uploadDocument(
            'unit-test.pdf', 'Reports', 'PDF', 12, base64
        );
        Test.stopTest();

        Document__c doc = [
            SELECT Id, Name, Category__c, File_Type__c, File_Size_KB__c
            FROM Document__c WHERE Id = :docId
        ];
        System.assertEquals('unit-test.pdf', doc.Name);
        System.assertEquals('Reports', doc.Category__c);
        System.assertEquals(12, doc.File_Size_KB__c);

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :docId
        ];
        System.assertEquals(1, links.size(),
            'ContentDocumentLink should be auto-created via FirstPublishLocation.');
    }

    // uploadDocument without base64 content creates only the metadata row.
    @IsTest
    static void uploadDocument_noContent_createsMetadataOnly() {
        Id docId = DocumentController.uploadDocument(
            'meta-only.pdf', 'Statements', 'PDF', 50, null
        );

        Document__c doc = [SELECT Name FROM Document__c WHERE Id = :docId];
        System.assertEquals('meta-only.pdf', doc.Name);

        List<ContentDocumentLink> links = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :docId
        ];
        System.assertEquals(0, links.size(),
            'No ContentVersion -> no linked ContentDocument when content is blank.');
    }
}
