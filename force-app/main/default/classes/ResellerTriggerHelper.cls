/**
 * @description  Business logic for Reseller__c trigger events. Pure static
 *               utility — normalizes user-input fields on every insert and
 *               update so that data stored in the database is always in the
 *               project's canonical format. Solves three concrete problems:
 *
 *               1. External ID case-sensitivity. Company_Email__c is marked
 *                  External ID, which makes SOQL `IN` comparison case-
 *                  sensitive at the storage layer. Without this Helper, a
 *                  user typing 'Partner@Hotel.DE' (mixed case) would store
 *                  mixed case and the OpportunityTriggerHelper's IN-clause
 *                  lookup would silently fail to match it. Lowercasing on
 *                  insert eliminates the trade-off entirely.
 *
 *               2. Locale-dependent phone format. Without normalization
 *                  Salesforce's Phone field renders using the running
 *                  user's locale, so '030 12345678' and '(030) 1234-5678'
 *                  end up stored in different shapes. This Helper forces
 *                  every phone into the project's '(NNN) NNN NN-NN'
 *                  canonical format via StringUtils.normalizePhone().
 *
 *               3. Whitespace bleed in free-text fields. 'Acme   GmbH'
 *                  (extra spaces) and ' Germany ' (padded) cause subtle
 *                  string-matching bugs downstream. The Helper trims and
 *                  collapses internal whitespace via
 *                  StringUtils.normalizeWhitespace().
 *
 *               This is the boundary-level normalization that pairs with
 *               the OpportunityTriggerHelper's read-side normalization to
 *               give the system end-to-end clean data.
 *
 *               Three-layer Kevin O'Hara pattern:
 *                 Trigger -> Handler (dispatch) -> Helper (this — logic)
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class ResellerTriggerHelper {

    /**
     * @description  Normalize the four user-input fields on every Reseller
     *               in the supplied list. Mutates each record in place so
     *               that what gets written to the database is the canonical
     *               form, not the raw user input.
     *
     *               Idempotent: calling this on already-normalized records
     *               is a no-op. Every StringUtils.* method preserves clean
     *               input unchanged.
     *
     *               Null-safe: any field that is null or blank stays null;
     *               Salesforce's required-field validation handles the
     *               'required field is empty' case downstream of this
     *               Helper.
     *
     * @param  resellers  Trigger.new list of Reseller__c records to normalize.
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
