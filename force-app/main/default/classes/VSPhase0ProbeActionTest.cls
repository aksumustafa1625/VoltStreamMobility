/**
 * @description  Pins the probe's only two properties: it answers, and it answers once
 *               per request in the same order. Positional alignment is the bug HanseWatt
 *               shipped and then fixed, so it is asserted here from the start.
 *
 * @group        VoltStream Platform Probe
 * @author       Mustafa Aksu
 * @date         2026-08-22
 */
@IsTest
private class VSPhase0ProbeActionTest {

    @IsTest
    static void returnsOneResultPerRequestInOrder() {
        List<VSPhase0ProbeAction.Request> reqs = new List<VSPhase0ProbeAction.Request>();
        for (Integer i = 0; i < 3; i++) {
            VSPhase0ProbeAction.Request r = new VSPhase0ProbeAction.Request();
            r.stichwort = 'probe-' + i;
            reqs.add(r);
        }

        Test.startTest();
        List<VSPhase0ProbeAction.Result> out = VSPhase0ProbeAction.run(reqs);
        Test.stopTest();

        System.assertEquals(3, out.size(), 'one result per request');
        for (VSPhase0ProbeAction.Result r : out) {
            System.assertEquals('OK', r.status, 'the probe always succeeds');
            System.assertEquals('Die Eichfrist endet am 31.12.2027.', r.antwort,
                'the answer is a constant, so a failing eval is the platform and not this');
        }
    }

    @IsTest
    static void emptyInputReturnsEmptyOutput() {
        Test.startTest();
        List<VSPhase0ProbeAction.Result> out =
            VSPhase0ProbeAction.run(new List<VSPhase0ProbeAction.Request>());
        Test.stopTest();
        System.assertEquals(0, out.size(), 'no requests, no results');
    }
}
