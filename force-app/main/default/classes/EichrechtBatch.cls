/**
 * @description  The nightly compliance sweep. Evaluates every charge point with the engine and
 *               writes the verdict onto the record.
 *
 *               Persisting the answer rather than recomputing it on read is the point. The engine
 *               walks an event history, which a formula field cannot do, so its verdict has nowhere
 *               to live unless something puts it there — and a verdict nobody can report on is a
 *               verdict nobody will act on.
 *
 *               The second field it writes is the one worth having. `Abweichung__c` marks every
 *               charge point where the engine and the formula disagree, which turns a question
 *               twelve fixtures answer in `EichrechtKonsistenzTest` into a column somebody can sort
 *               a fleet by. Each checked row is either the case the declarative layer cannot
 *               express — a late Nacheichung the ordinance backdates — or a defect. Both are worth
 *               a list view.
 *
 *               It exists because of the OCPI import. A fleet arriving from a CPO backend carries
 *               no calibration data at all, so the sweep is not a nicety over a handful of records:
 *               it is how an estate of imported charge points gets a legal status in the first
 *               place.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-24
 */
public with sharing class EichrechtBatch implements Database.Batchable<SObject>, Schedulable {

    /** Fixed for the whole run, so a job crossing midnight does not answer two different days. */
    private final Date stichtag;

    public EichrechtBatch() {
        this(Date.today());
    }

    /**
     * @description  Run the sweep for a chosen day.
     * @param  stichtag  The day every verdict is asserted for; null means today.
     */
    public EichrechtBatch(Date stichtag) {
        this.stichtag = (stichtag == null) ? Date.today() : stichtag;
    }

    /**
     * @description  Entry point for the scheduler.
     * @param  kontext  Supplied by the platform.
     */
    public void execute(SchedulableContext kontext) {
        // 200 rather than the default: each chunk costs two queries through the Selector and one
        // engine pass per record, and the engine holds an event list per charge point in memory.
        Database.executeBatch(new EichrechtBatch(stichtag), 200);
    }

    /**
     * @description  Every charge point, oldest first.
     * @param  kontext  Supplied by the platform.
     * @return  The locator the Selector owns, so this class still writes no SOQL.
     */
    public Database.QueryLocator start(Database.BatchableContext kontext) {
        return LadepunktSelector.alleFuerPruefung();
    }

    /**
     * @description  Evaluate one chunk and record what the engine found.
     * @param  kontext    Supplied by the platform.
     * @param  ladepunkte The chunk.
     */
    public void execute(Database.BatchableContext kontext, List<Ladepunkt__c> ladepunkte) {
        Map<Id, Ladepunkt__c> jeId = new Map<Id, Ladepunkt__c>(ladepunkte);
        Map<Id, DecisionResult> urteile = EichrechtService.bewerteEichfrist(jeId.keySet(), stichtag);

        List<Ladepunkt__c> zuSpeichern = new List<Ladepunkt__c>();
        for (Ladepunkt__c lp : ladepunkte) {
            DecisionResult d = urteile.get(lp.Id);
            if (d == null) {
                continue;
            }
            String motor = String.valueOf(d.ergebnis);
            zuSpeichern.add(new Ladepunkt__c(
                Id = lp.Id,
                Pruefergebnis__c = motor,
                Letzte_Pruefung_am__c = System.now(),
                Abweichung__c = weichtAb(lp.Eichstatus__c, motor)
            ));
        }

        if (zuSpeichern.isEmpty()) {
            return;
        }
        // Partial success: one record the org rejects must not discard the chunk, and the ones it
        // rejected are recorded with their identifier rather than lost to a rolled-back statement.
        List<Database.SaveResult> ergebnisse = Database.update(zuSpeichern, false);
        List<Integrationsfehler__c> fehler = new List<Integrationsfehler__c>();
        for (Integer i = 0; i < ergebnisse.size(); i++) {
            if (ergebnisse[i].isSuccess()) {
                continue;
            }
            List<String> meldungen = new List<String>();
            for (Database.Error e : ergebnisse[i].getErrors()) {
                meldungen.add(e.getStatusCode() + ': ' + e.getMessage());
            }
            fehler.add(IntegrationsfehlerLogger.baue('Eichrecht-Batch', 'Update Ladepunkt__c', null,
                String.join(meldungen, ' | '), String.valueOf(zuSpeichern[i].Id), null));
        }
        IntegrationsfehlerLogger.protokolliere(fehler);
    }

    /**
     * @description  Nothing to finish. Deliberately empty rather than absent, so the absence of a
     *               summary email is a decision somebody made and not something forgotten: the
     *               findings live on the records, where a report can reach them, and a mail nobody
     *               reads is not a compliance control.
     * @param  kontext  Supplied by the platform.
     */
    public void finish(Database.BatchableContext kontext) {
    }

    /**
     * The two layers speak different vocabularies - the formula writes GÜLTIG with an umlaut and a
     * paragraph in brackets, the engine returns the enum name GUELTIG - so the comparison folds
     * both to the same shape before deciding. A blank formula value is not a disagreement; it is a
     * record the declarative layer has not computed yet.
     */
    @TestVisible
    private static Boolean weichtAb(String formeltext, String motorergebnis) {
        if (String.isBlank(formeltext)) {
            return false;
        }
        DecisionResult.Status ausFormel = DecisionResult.ausEichstatusFormel(formeltext);
        // An unmappable formula value is a disagreement worth flagging: either the formula changed
        // without the mapping, or it produced something nobody planned for.
        return ausFormel == null || String.valueOf(ausFormel) != motorergebnis;
    }
}
