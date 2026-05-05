/**
 * @description  Boundary-level normalization for Reseller__c on every insert
 *               and update. Lowercases email (closes External ID case-
 *               sensitivity loophole), formats phones to '(NNN) NNN NN-NN',
 *               and trims whitespace from name + country. Pairs with
 *               OpportunityTriggerHelper for end-to-end clean data.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class ResellerTriggerHelper {

    /**
     * @description  Normalize the four user-input fields on every Reseller in
     *               the supplied list. Mutates each record in place. Idempotent
     *               and null-safe — calling on already-clean records is a no-op.
     *
     * @param  resellers  Trigger.new list of Reseller__c records.
     */
    public static void normalizeFields(List<Reseller__c> resellers) {
        for (Reseller__c r : resellers) {
            // Email -> lowercase + trimmed (External ID matching depends on this).
            r.Company_Email__c = StringUtils.normalizeEmail(r.Company_Email__c);

            // Phone -> '(NNN) NNN NN-NN' (locale-independent canonical format).
            r.Phone__c = StringUtils.normalizePhone(r.Phone__c);

            // Free-text fields -> trim + collapse internal whitespace.
            r.Name = StringUtils.normalizeWhitespace(r.Name);
            r.Country__c = StringUtils.normalizeWhitespace(r.Country__c);
        }
    }
}
