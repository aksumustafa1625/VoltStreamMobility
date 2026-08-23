/**
 * @description  Writes one row per failed exchange with an external system.
 *
 *               The rule this class exists to enforce: an import that swallows its errors reports
 *               an empty fleet as a clean fleet. That is the same failure the compliance engine
 *               refuses to make — silence is not compliance — and it is easier to make here,
 *               because a callout that returns nothing looks exactly like a callout that returned
 *               nothing to import.
 *
 *               Logging never throws. A logger that can fail turns a recoverable integration
 *               problem into an unrecoverable one, and the row it could not write is worth less
 *               than the transaction it would take down. Failures to log are allowed to be lost;
 *               failures to import are not.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-24
 */
public with sharing class IntegrationsfehlerLogger {

    /** Payloads are kept for diagnosis but a log row is not an archive. */
    private static final Integer NUTZLAST_MAX = 30000;

    /**
     * @description  Record one failure.
     * @param  fremdsystem External system, e.g. OCPI. Not named "system": Apex reserves it.
     * @param  vorgang     Operation that failed, e.g. GET /locations.
     * @param  statuscode  HTTP status, or null when the call never reached the endpoint.
     * @param  nachricht   What went wrong, in one sentence.
     * @param  kennung     EVSE-ID or location id when the failure belongs to one record.
     * @param  nutzlast    What was received; truncated.
     */
    public static void protokolliere(String fremdsystem, String vorgang, Integer statuscode,
                                     String nachricht, String kennung, String nutzlast) {
        protokolliere(new List<Integrationsfehler__c>{
            baue(fremdsystem, vorgang, statuscode, nachricht, kennung, nutzlast)
        });
    }

    /**
     * @description  Record many failures in one DML. A batch that fails on eight hundred rows must
     *               not spend eight hundred statements saying so.
     * @param  fehler  Rows to persist; null or empty is a no-op.
     */
    public static void protokolliere(List<Integrationsfehler__c> fehler) {
        if (fehler == null || fehler.isEmpty()) {
            return;
        }
        try {
            // allOrNone false: one malformed row must not discard the rest of the evidence.
            Database.insert(fehler, false);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'Integrationsfehler konnten nicht protokolliert werden: ' + e.getMessage());
        }
    }

    /**
     * @description  Build a row without saving it, for callers collecting failures across a loop.
     * @param  fremdsystem External system.
     * @param  vorgang     Operation.
     * @param  statuscode  HTTP status or null.
     * @param  nachricht   What went wrong.
     * @param  kennung     Affected identifier, if any.
     * @param  nutzlast    Payload; truncated.
     * @return  An unsaved Integrationsfehler__c.
     */
    public static Integrationsfehler__c baue(String fremdsystem, String vorgang, Integer statuscode,
                                             String nachricht, String kennung, String nutzlast) {
        return new Integrationsfehler__c(
            System__c = fremdsystem,
            Vorgang__c = vorgang,
            Statuscode__c = statuscode,
            Nachricht__c = nachricht,
            Kennung__c = kennung,
            Nutzlast__c = String.isBlank(nutzlast) ? null : nutzlast.abbreviate(NUTZLAST_MAX)
        );
    }
}
