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
}
