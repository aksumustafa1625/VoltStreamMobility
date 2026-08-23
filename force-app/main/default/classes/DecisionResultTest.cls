/**
 * @description  Tests for the carrier the engine returns. Small class, but two of its behaviours
 *               are load-bearing: an unknown citation key has to fail loudly, and the two
 *               non-answers have to stay distinguishable from the six answers.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
@IsTest
private class DecisionResultTest {

    private static final Date STICHTAG = Date.newInstance(2026, 8, 23);

    @IsTest
    static void zitiereLoestDenKorpusSchluesselInDasAmtlicheZitatAuf() {
        DecisionResult r = new DecisionResult(DecisionResult.Status.GUELTIG, STICHTAG)
            .zitiere('MessEV_34_1_3');

        System.assertEquals(1, r.rechtsgrundlagen.size());
        System.assertEquals('§ 34 Abs. 1 Satz 3 MessEV', r.rechtsgrundlagen[0],
            'Zitiert wird der Norm__c-String aus dem Korpus, nicht der Entwicklername.');
    }

    @IsTest
    static void zitiereZaehltDieselbeNormNichtDoppelt() {
        // A chronology walk can reach the same provision more than once - two late calibrations
        // both land on Satz 3. The source list is what the transcript gate reads, so a doubled
        // entry there is noise in the one place noise is expensive.
        DecisionResult r = new DecisionResult(DecisionResult.Status.GUELTIG, STICHTAG)
            .zitiere('MessEV_34_1_3')
            .zitiere('MessEV_34_1_3')
            .zitiere('MessEV_34_2');

        System.assertEquals(2, r.rechtsgrundlagen.size(), 'Zitiert: ' + r.rechtsgrundlagen);
    }

    @IsTest
    static void einUnbekannterSchluesselScheitertLautStattStillZuFehlen() {
        // Skipping an unresolvable key would let the gate pass on an empty source list, which is
        // exactly the failure the gate exists to catch. Loud beats silent here.
        try {
            new DecisionResult(DecisionResult.Status.GUELTIG, STICHTAG).zitiere('GibtEsNicht');
            System.assert(false, 'Ein unbekannter Normschluessel haette scheitern muessen.');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('GibtEsNicht'),
                'Die Meldung soll den fehlenden Schluessel nennen: ' + e.getMessage());
        }
    }

    @IsTest
    static void nurSechsDerAchtErgebnisseSindEineAussage() {
        Map<DecisionResult.Status, Boolean> erwartet = new Map<DecisionResult.Status, Boolean>{
            DecisionResult.Status.GUELTIG           => true,
            DecisionResult.Status.GESCHUETZT        => true,
            DecisionResult.Status.ERMESSEN          => true,
            DecisionResult.Status.ABGELAUFEN        => true,
            DecisionResult.Status.VORZEITIG_BEENDET => true,
            DecisionResult.Status.BETRIEB_GESPERRT  => true,
            DecisionResult.Status.UNBEKANNT         => false,
            DecisionResult.Status.NICHT_ANWENDBAR   => false
        };

        for (DecisionResult.Status e : erwartet.keySet()) {
            System.assertEquals(erwartet.get(e),
                new DecisionResult(e, STICHTAG).hatAussage(),
                e + ': eine nicht anwendbare Norm und eine Datenluecke sind keine Ergebnisse.');
        }
    }

    @IsTest
    static void begruendeReihtSaetzeAneinander() {
        DecisionResult r = new DecisionResult(DecisionResult.Status.ABGELAUFEN, STICHTAG)
            .begruende('Erster Satz.')
            .begruende('Zweiter Satz.');

        System.assertEquals('Erster Satz. Zweiter Satz.', r.begruendung);
    }
}
