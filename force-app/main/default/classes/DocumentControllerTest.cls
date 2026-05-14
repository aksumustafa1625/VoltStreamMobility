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

    // getRecentActivity returns the latest documents.
    @IsTest
    static void getRecentActivity_returnsLatestDocuments() {
        List<Document__c> recent = DocumentController.getRecentActivity();
        System.assertEquals(3, recent.size(),
            'All 3 seeded documents should appear in the recent activity list.');
    }

    // shareToChatter on a metadata-only record falls back to a TextPost.
    @IsTest
    static void shareToChatter_noFile_createsTextPost() {
        Document__c doc = [SELECT Id FROM Document__c LIMIT 1];

        Test.startTest();
        Id postId = DocumentController.shareToChatter(doc.Id, 'Please review this file.');
        Test.stopTest();

        FeedItem post = [SELECT ParentId, Body, Type, RelatedRecordId FROM FeedItem WHERE Id = :postId];
        System.assertEquals(doc.Id, post.ParentId, 'Post must be attached to the Document.');
        System.assertEquals('Please review this file.', post.Body);
        System.assertEquals('TextPost', post.Type);
        System.assertEquals(null, post.RelatedRecordId, 'Metadata-only record has no file to attach.');
    }

    // shareToChatter on a record with a linked file creates a ContentPost
    // pointing at the latest ContentVersion so the file shows up in the feed.
    @IsTest
    static void shareToChatter_withFile_createsContentPost() {
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Share me'));
        Id docId = DocumentController.uploadDocument(
            'share-test.pdf', 'Reports', 'PDF', 8, base64
        );

        Test.startTest();
        Id postId = DocumentController.shareToChatter(docId, 'Sharing the latest version.');
        Test.stopTest();

        FeedItem post = [SELECT ParentId, Body, Type, RelatedRecordId FROM FeedItem WHERE Id = :postId];
        System.assertEquals(docId, post.ParentId);
        System.assertEquals('ContentPost', post.Type, 'Linked file should produce a ContentPost.');
        System.assertNotEquals(null, post.RelatedRecordId, 'ContentPost must reference a ContentVersion.');

        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Id = :post.RelatedRecordId LIMIT 1];
        System.assertNotEquals(null, cv.Id, 'RelatedRecordId must resolve to a real ContentVersion.');
    }

    // shareToChatter with blank message throws.
    @IsTest
    static void shareToChatter_blankMessage_throws() {
        Document__c doc = [SELECT Id FROM Document__c LIMIT 1];
        try {
            DocumentController.shareToChatter(doc.Id, '   ');
            System.assert(false, 'Should have thrown AuraHandledException on blank message.');
        } catch (AuraHandledException e) {
            // expected
        }
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
