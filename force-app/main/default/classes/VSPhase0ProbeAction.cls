/**
 * @description  A deliberately worthless agent action, built only to walk the platform
 *               loop end to end before any real domain code exists: publish an agent,
 *               deploy an evaluation, run it, and see whether metric values actually
 *               come back. It returns a constant. That is the point — if a test fails,
 *               the failure is the platform, never this.
 *
 *               Delete once docs/PHASE0_VERIFICATION.md is written.
 *
 * @group        VoltStream Platform Probe
 * @author       Mustafa Aksu
 * @date         2026-08-22
 */
public with sharing class VSPhase0ProbeAction {

    public class Request {
        @InvocableVariable(
            label='Stichwort'
            description='Ein beliebiges Stichwort. Der Wert wird nicht ausgewertet.')
        public String stichwort;
    }

    public class Result {
        @InvocableVariable(label='Antwort') public String antwort;
        @InvocableVariable(label='Status')  public String status;
    }

    /**
     * @description  Returns a fixed German sentence for every request.
     * @param        requests  one per invocation; the content is ignored
     * @return       one Result per Request, in the same order (invocable outputs map
     *               positionally — a lesson borrowed from HanseWatt rather than relearned)
     */
    @InvocableMethod(
        label='VS Phase 0 Probe'
        description='Gibt einen festen Satz zurück. Dient ausschließlich der Plattformprüfung.')
    public static List<Result> run(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Integer i = 0; i < requests.size(); i++) {
            Result r = new Result();
            r.antwort = 'Die Eichfrist endet am 31.12.2027.';
            r.status  = 'OK';
            results.add(r);
        }
        return results;
    }
}
