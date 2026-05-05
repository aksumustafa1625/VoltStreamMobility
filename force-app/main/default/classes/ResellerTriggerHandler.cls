/**
 * @description  Thin dispatcher for Reseller__c trigger events. Extends
 *               Kevin O'Hara's TriggerHandler base class and overrides
 *               beforeInsert and beforeUpdate, both of which delegate to
 *               ResellerTriggerHelper.normalizeFields() so user-input
 *               data is normalized into the project's canonical format
 *               before it reaches the database.
 *
 *               Three-layer Kevin O'Hara pattern:
 *                 Trigger -> Handler (this — dispatches by context) -> Helper (logic)
 *
 *               Why only beforeInsert + beforeUpdate is needed:
 *                 - Field mutation only works in the BEFORE phase. After-
 *                   phase mutations would require an extra DML statement,
 *                   which is wasteful when the same effect is available
 *                   one statement earlier.
 *                 - Delete and undelete don't need normalization (no field
 *                   values are being set), so the corresponding overrides
 *                   stay on the framework's default no-op implementations.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class ResellerTriggerHandler extends TriggerHandler {

    /**
     * @description  Normalize Reseller__c fields on insert. Mutates the
     *               records in Trigger.new before they reach the database.
     */
    public override void beforeInsert() {
        ResellerTriggerHelper.normalizeFields((List<Reseller__c>) Trigger.new);
    }

    /**
     * @description  Re-normalize Reseller__c fields on update. Trigger.new
     *               always contains the new field values, so passing it
     *               straight to the Helper handles every kind of edit
     *               (manual UI edit, API patch, mass update, etc.).
     */
    public override void beforeUpdate() {
        ResellerTriggerHelper.normalizeFields((List<Reseller__c>) Trigger.new);
    }
}
