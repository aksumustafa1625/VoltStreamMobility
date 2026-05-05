/**
 * @description  Centralized builder for unsaved test fixtures. Used by every
 *               test class so schema changes propagate through one file
 *               instead of every @TestSetup. Never does DML — callers decide
 *               whether to insert.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public class TestDataFactory {

    /**
     * @description  Build an unsaved active Reseller (Country=Germany default).
     * @param  name   Reseller display name.
     * @param  email  Company email — also the trigger matching key.
     * @param  type   Reseller_Type__c picklist value.
     * @return  Unsaved Reseller__c record.
     */
    public static Reseller__c buildReseller(String name, String email, String type) {
        return new Reseller__c(
            Name = name,
            Company_Email__c = email,
            Reseller_Type__c = type,
            Country__c = 'Germany',
            Active__c = true
        );
    }

    /**
     * @description  Build an unsaved INACTIVE Reseller (Active__c=false).
     * @param  name   Reseller display name.
     * @param  email  Company email.
     * @param  type   Reseller type picklist value.
     * @return  Unsaved inactive Reseller__c record.
     */
    public static Reseller__c buildInactiveReseller(String name, String email, String type) {
        return new Reseller__c(
            Name = name,
            Company_Email__c = email,
            Reseller_Type__c = type,
            Country__c = 'Germany',
            Active__c = false
        );
    }

    /**
     * @description  Build an unsaved Opportunity with required fields and a
     *               Reseller_Email__c the trigger will match against.
     * @param  name           Opportunity name.
     * @param  resellerEmail  Reseller email; null for direct deals.
     * @return  Unsaved Opportunity record.
     */
    public static Opportunity buildOpportunity(String name, String resellerEmail) {
        return new Opportunity(
            Name = name,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Reseller_Email__c = resellerEmail
        );
    }
}
