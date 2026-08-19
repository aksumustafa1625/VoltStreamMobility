/**
 * @description  Single home for every SOQL query against Document__c. The
 *               DocumentController (LWC controller) calls here instead of
 *               inlining SOQL — keeps query logic isolated.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class DocumentSelector {

    /**
     * @description  Fetch all documents, optionally filtered by category.
     *               Pass null/blank category to return everything. Ordered by
     *               CreatedDate DESC so the most recently uploaded files show
     *               first in the documents table.
     * @param  category  Category__c picklist value, or null for all.
     * @return  Documents matching the filter; empty list if none.
     */
    public static List<Document__c> findByCategory(String category) {
        if (String.isBlank(category)) {
            return [
                SELECT Id, Name, Category__c, File_Type__c, File_Size_KB__c,
                       CreatedDate, CreatedBy.Name,
                       (SELECT ContentDocumentId FROM ContentDocumentLinks LIMIT 1)
                FROM Document__c
                WITH USER_MODE
                ORDER BY CreatedDate DESC
                LIMIT 1000
            ];
        }
        return [
            SELECT Id, Name, Category__c, File_Type__c, File_Size_KB__c,
                   CreatedDate, CreatedBy.Name,
                   (SELECT ContentDocumentId FROM ContentDocumentLinks LIMIT 1)
            FROM Document__c
            WHERE Category__c = :category
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 1000
        ];
    }

    /**
     * @description  Return the most recently created documents for the
     *               Recent Activity strip at the bottom of the LWC. Five
     *               rows is the design-mockup default; tweak the LIMIT
     *               here if the section gets resized.
     * @return  Latest 5 Document__c records by CreatedDate DESC.
     */
    public static List<Document__c> getRecentActivity() {
        return [
            SELECT Id, Name, Category__c, CreatedDate, CreatedBy.Name
            FROM Document__c
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];
    }

    /**
     * @description  Find the latest ContentVersion linked to a given record
     *               via ContentDocumentLink, so the LWC's Share action can
     *               attach the actual file binary to its Chatter post
     *               (FeedItem ContentPost) instead of posting plain text.
     *               Returns null if the record has no linked file.
     * @param  recordId  Id of the LinkedEntity (typically a Document__c).
     * @return  Latest ContentVersion.Id for the record, or null if none.
     */
    public static Id getLatestContentVersionId(Id recordId) {
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            WITH USER_MODE
            LIMIT 1
        ];
        if (links.isEmpty()) {
            return null;
        }
        List<ContentVersion> versions = [
            SELECT Id
            FROM ContentVersion
            WHERE ContentDocumentId = :links[0].ContentDocumentId
              AND IsLatest = true
            WITH USER_MODE
            LIMIT 1
        ];
        return versions.isEmpty() ? null : versions[0].Id;
    }

    /**
     * @description  Resolve the ContentDocument that Salesforce created behind
     *               a freshly inserted ContentVersion. The upload path needs
     *               it to build the ContentDocumentLink to Document__c
     *               (FirstPublishLocation is no longer writeable, so the link
     *               has to be created by hand). Returns null if the version
     *               is not visible to the running user — it always is for the
     *               user who just inserted it.
     * @param  contentVersionId  Id of the ContentVersion just inserted.
     * @return  ContentDocumentId of that version, or null if not found.
     */
    public static Id getContentDocumentIdForVersion(Id contentVersionId) {
        List<ContentVersion> versions = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentVersionId
            WITH USER_MODE
            LIMIT 1
        ];
        return versions.isEmpty() ? null : versions[0].ContentDocumentId;
    }

    /**
     * @description  Aggregate row count per Category__c value, used to render
     *               the folder cards at the top of the LWC. Returns a map
     *               keyed by category label, pre-seeded with 0 for the four
     *               canonical categories so the UI never has to null-check;
     *               any further picklist value that has documents is added on
     *               top.
     * @return  Map<categoryLabel, count>.
     */
    public static Map<String, Integer> getCategoryCounts() {
        Map<String, Integer> counts = new Map<String, Integer>{
            'Application Forms' => 0,
            'Statements'        => 0,
            'Reports'           => 0,
            'Uncategorized'     => 0
        };
        for (AggregateResult ar : [
            SELECT Category__c category, COUNT(Id) cnt
            FROM Document__c
            WHERE Category__c != null
            WITH USER_MODE
            GROUP BY Category__c
        ]) {
            counts.put((String) ar.get('category'), (Integer) ar.get('cnt'));
        }
        return counts;
    }
}
