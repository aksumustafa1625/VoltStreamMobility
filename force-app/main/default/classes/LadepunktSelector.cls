/**
 * @description  Every query against Ladepunkt__c and its Eingriff__c children. Handlers, helpers
 *               and services do not inline SOQL, so when a field is added to the compliance
 *               calculation exactly one file changes.
 *
 *               Events come back ordered by date because EichrechtService walks them as a
 *               chronology. The service sorts defensively anyway — it also accepts lists that
 *               never passed through here — but a Selector that hands back an arbitrary order for
 *               data whose meaning is its order would be setting a trap.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
public with sharing class LadepunktSelector {

    /**
     * @description  Charge points by Id, with every field the Eichrecht calculation reads.
     * @param  ladepunktIds  Ids to load; null or empty yields an empty list.
     * @return  Matching charge points.
     */
    public static List<Ladepunkt__c> byIds(Set<Id> ladepunktIds) {
        if (ladepunktIds == null || ladepunktIds.isEmpty()) {
            return new List<Ladepunkt__c>();
        }
        return [
            SELECT Id, Name, Inverkehrbringen__c, Nacheichung_beantragt_am__c,
                   Ladeleistung_kW__c, Oeffentlich_zugaenglich__c, Standort_Adresse__c,
                   Eichstatus__c, Fristbeginn__c, Eichfrist_Ende__c
            FROM Ladepunkt__c
            WHERE Id IN :ladepunktIds
            WITH USER_MODE
            LIMIT 50000
        ];
    }

    /**
     * @description  Every event belonging to the given charge points, oldest first.
     * @param  ladepunktIds  Parent Ids; null or empty yields an empty list.
     * @return  Events ordered by date, then by type so a calibration sorts after an intervention
     *          that shares its date — see EichrechtService for why that order is the safe one.
     */
    public static List<Eingriff__c> eingriffeByLadepunkt(Set<Id> ladepunktIds) {
        if (ladepunktIds == null || ladepunktIds.isEmpty()) {
            return new List<Eingriff__c>();
        }
        return [
            SELECT Id, Ladepunkt__c, Typ__c, Datum__c, Beschreibung__c,
                   Beendet_Eichfrist__c, Sperrt_Betrieb__c, Nacheichungsantrag_offen__c,
                   Stilllegung_nachgewiesen__c, Behoerdliche_Freigabe_am__c,
                   Instandsetzer_befugt__c, Nacheichung_beantragt__c,
                   Kennzeichnung_41__c, Behoerde_informiert__c
            FROM Eingriff__c
            WHERE Ladepunkt__c IN :ladepunktIds
            WITH USER_MODE
            ORDER BY Datum__c ASC NULLS LAST
            LIMIT 50000
        ];
    }
}
