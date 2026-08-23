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

    /**
     * @description  Build an unsaved Task tied to a parent record via WhatId.
     *               Used by the Task rollup tests.
     * @param  subject  Task subject.
     * @param  whatId   Parent record Id (Opportunity for the rollup tests).
     * @param  status   Status value (e.g. 'Completed', 'Not Started').
     * @return  Unsaved Task record.
     */
    public static Task buildTask(String subject, Id whatId, String status) {
        return new Task(
            Subject = subject,
            WhatId = whatId,
            Status = status
        );
    }

    /**
     * @description  Build an unsaved Completed Task on the given parent.
     * @param  whatId  Parent record Id.
     * @return  Unsaved Task with Status = 'Completed'.
     */
    public static Task buildCompletedTask(Id whatId) {
        return buildTask('Completed task', whatId, 'Completed');
    }

    /**
     * @description  Build an unsaved open (Not Started) Task on the given parent.
     * @param  whatId  Parent record Id.
     * @return  Unsaved Task with Status = 'Not Started'.
     */
    public static Task buildOpenTask(Id whatId) {
        return buildTask('Open task', whatId, 'Not Started');
    }

    /**
     * @description  Build an unsaved operator account — the Ladepunktbetreiber the LSV notification
     *               duty and the THG claim attach to.
     * @param  name  Company name.
     * @return  Unsaved Account.
     */
    public static Account buildBetreiber(String name) {
        return new Account(Name = name);
    }

    /**
     * @description  Build an unsaved charge point. Name is an auto-number, so the location string
     *               is what a test uses to identify the record it built.
     * @param  standort           Free-text location, used as the test's own label.
     * @param  inverkehrbringen   Date placed on the market; null to model the unknown case.
     * @return  Unsaved Ladepunkt__c.
     */
    public static Ladepunkt__c buildLadepunkt(String standort, Date inverkehrbringen) {
        return new Ladepunkt__c(
            Standort_Adresse__c = standort,
            Inverkehrbringen__c = inverkehrbringen,
            Ladeleistung_kW__c = 11,
            Stromart__c = 'AC'
        );
    }

    /**
     * @description  Build an unsaved event on a charge point.
     * @param  ladepunktId  Parent charge point; required, the relationship is master-detail.
     * @param  typ          Eingriff, Instandsetzung, Software-Update or Nacheichung.
     * @param  datum        When it happened.
     * @return  Unsaved Eingriff__c.
     */
    public static Eingriff__c buildEingriff(Id ladepunktId, String typ, Date datum) {
        return new Eingriff__c(
            Ladepunkt__c = ladepunktId,
            Typ__c = typ,
            Datum__c = datum
        );
    }

    /**
     * @description  Build an unsaved repair with the four § 37 Abs. 5 MessEG conditions set
     *               individually. All four together are what exempts a repair from ending the
     *               Eichfrist early, so a builder that took a single "compliant" flag would hide
     *               the only interesting cases.
     * @param  ladepunktId    Parent charge point.
     * @param  datum          When the repair happened.
     * @param  befugt         Nr. 1 — carried out by an authorised repairer.
     * @param  beantragt      Nr. 2 — re-calibration applied for immediately.
     * @param  kennzeichnung  Nr. 3 — marked as required by § 41 MessEV.
     * @param  behoerde       Nr. 4 — authority notified immediately.
     * @return  Unsaved Eingriff__c of type Instandsetzung.
     */
    public static Eingriff__c buildInstandsetzung(Id ladepunktId, Date datum, Boolean befugt,
                                                  Boolean beantragt, Boolean kennzeichnung,
                                                  Boolean behoerde) {
        Eingriff__c e = buildEingriff(ladepunktId, 'Instandsetzung', datum);
        e.Instandsetzer_befugt__c = befugt;
        e.Nacheichung_beantragt__c = beantragt;
        e.Kennzeichnung_41__c = kennzeichnung;
        e.Behoerde_informiert__c = behoerde;
        return e;
    }
}
