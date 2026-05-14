/**
 * @description  Apex backing class for the documentManager Lightning Web
 *               Component. Exposes @AuraEnabled methods the LWC calls via
 *               wire/imperative to fetch documents per folder and the
 *               category-count summary for the folder cards.
 *
 *               SOQL is delegated to DocumentSelector; this controller is
 *               a thin facade over the Selector so the LWC only sees Apex
 *               types it can serialize.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class DocumentController {

    /**
     * @description  Wire-friendly query for the documents table. The LWC
     *               passes the selected folder's category; an empty/null
     *               value returns every document (Recent view).
     *
     *               cacheable=true so the LWC's @wire decorator can rely
     *               on Lightning Data Service caching for repeat calls.
     *
     * @param  category  Category__c picklist value, or null/blank for all.
     * @return  Document__c records ordered by CreatedDate DESC.
     */
    @AuraEnabled(cacheable=true)
    public static List<Document__c> getDocuments(String category) {
        return DocumentSelector.findByCategory(category);
    }

    /**
     * @description  Wire-friendly summary for the four folder cards at the
     *               top of the LWC. Always returns all four canonical
     *               category keys with zero defaults so the UI can iterate
     *               without null-checks.
     *
     * @return  Map<categoryLabel, count>.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getCategoryCounts() {
        return DocumentSelector.getCategoryCounts();
    }

    /**
     * @description  Upload a real file: creates the Document__c metadata
     *               record AND the matching ContentVersion (so Salesforce
     *               stores the actual binary). ContentVersion's
     *               FirstPublishLocation links the file to Document__c, so
     *               a ContentDocumentLink is auto-created — that's what the
     *               LWC reads to open the file preview from the View action.
     *
     * @param  fileName       Display name on the Document__c row.
     * @param  category       Category__c picklist value.
     * @param  fileType       Short type tag (e.g. 'PDF').
     * @param  fileSizeKB     File size for the SIZE column.
     * @param  base64Content  Base64-encoded file binary; pass null to create
     *                        a metadata-only record without real content.
     * @return  Id of the new Document__c.
     */
    @AuraEnabled
    public static Id uploadDocument(
        String fileName,
        String category,
        String fileType,
        Decimal fileSizeKB,
        String base64Content
    ) {
        Document__c doc = new Document__c(
            Name = fileName,
            Category__c = category,
            File_Type__c = fileType,
            File_Size_KB__c = fileSizeKB
        );
        insert doc;

        if (String.isNotBlank(base64Content)) {
            // Two-step file linkage (FirstPublishLocation is no longer writeable):
            //   1. Insert ContentVersion -> Salesforce creates a ContentDocument behind it.
            //   2. Query the new ContentDocumentId, then create a ContentDocumentLink
            //      pointing at our Document__c so the file shows up under that record.
            ContentVersion cv = new ContentVersion(
                Title = fileName,
                PathOnClient = fileName,
                VersionData = EncodingUtil.base64Decode(base64Content)
            );
            insert cv;

            Id contentDocId = [
                SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1
            ].ContentDocumentId;

            insert new ContentDocumentLink(
                ContentDocumentId = contentDocId,
                LinkedEntityId = doc.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
        }

        return doc.Id;
    }
}
