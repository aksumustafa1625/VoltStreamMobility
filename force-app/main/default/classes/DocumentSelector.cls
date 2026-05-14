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
     * @description  Aggregate row count per Category__c value, used to render
     *               the four folder cards at the top of the LWC. Returns a
     *               map keyed by category label with 0 defaults for empty
     *               categories so the UI always has 4 entries.
     * @return  Map<categoryLabel, count>.
     */
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
