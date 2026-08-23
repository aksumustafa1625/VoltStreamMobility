/**
 * @description  What a compliance check hands back: an answer, the reasoning in German, and the
 *               provisions the answer actually rests on.
 *
 *               Two of the possible results are deliberately not answers, and keeping them apart
 *               is most of the reason this class exists. NICHT_ANWENDBAR means the provision has
 *               nothing to say about this device — § 38 MessEG governs late calibration, so a
 *               device whose period is still running falls outside it entirely, and reporting
 *               that as "not protected" would be a different and wrong statement. UNBEKANNT means
 *               the data does not permit an answer at all. Collapse either into a negative and a
 *               missing date starts reading like a clean bill of health.
 *
 *               `rechtsgrundlagen` is not decoration. Every entry is a `Norm__c` string resolved
 *               from `Rechtsnorm__mdt`, and only the branches that actually fired are cited. It is
 *               what the deterministic transcript gate will check: every § the agent utters must
 *               appear in a list an action returned in that turn.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
public with sharing class DecisionResult {

    /**
     * The eight outcomes. Six are legal states, two are honest admissions — and the enum keeps
     * them in one type so a caller cannot handle the states and forget the admissions.
     */
    public enum Status {
        GUELTIG,
        GESCHUETZT,
        ERMESSEN,
        ABGELAUFEN,
        VORZEITIG_BEENDET,
        BETRIEB_GESPERRT,
        UNBEKANNT,
        NICHT_ANWENDBAR
    }

    public Status ergebnis;

    /** German prose, assembled deterministically. The agent narrates it; it never writes it. */
    public String begruendung;

    /** `Norm__c` strings of the provisions this answer rests on, in the order they applied. */
    public List<String> rechtsgrundlagen = new List<String>();

    public Date fristbeginn;
    public Date fristende;

    /** The day the answer is true for. An expiry answer without its reference date is not one. */
    public Date stichtag;

    /**
     * @description  Build a result for one outcome on one day.
     * @param  ergebnis  The outcome.
     * @param  stichtag  The day the answer is asserted for.
     */
    public DecisionResult(Status ergebnis, Date stichtag) {
        this.ergebnis = ergebnis;
        this.stichtag = stichtag;
    }

    /**
     * @description  Cite a provision by its corpus key, appending its official citation string.
     *               Duplicates are ignored, so a branch that fires twice in a chronology walk
     *               does not produce a doubled source list.
     *
     *               An unknown key throws rather than being skipped. A silently missing citation
     *               is the worse failure by far: the transcript gate would then pass vacuously,
     *               and an agent citing a § no action returned is exactly what the gate exists to
     *               catch. `RechtsnormKorpusTest` guards every key this class uses, so reaching
     *               this exception means the corpus was changed without running the tests.
     * @param  normSchluessel  DeveloperName of a Rechtsnorm__mdt record.
     * @return  This instance, so citations can be chained onto a construction.
     */
    public DecisionResult zitiere(String normSchluessel) {
        Rechtsnorm__mdt norm = Rechtsnorm__mdt.getInstance(normSchluessel);
        if (norm == null) {
            throw new IllegalArgumentException(
                'Der Normenkorpus kennt den Schluessel nicht: ' + normSchluessel);
        }
        if (!rechtsgrundlagen.contains(norm.Norm__c)) {
            rechtsgrundlagen.add(norm.Norm__c);
        }
        return this;
    }

    /**
     * @description  Append to the German reasoning, one sentence at a time.
     * @param  satz  A complete sentence.
     * @return  This instance.
     */
    public DecisionResult begruende(String satz) {
        begruendung = String.isBlank(begruendung) ? satz : begruendung + ' ' + satz;
        return this;
    }

    /**
     * @description  Whether this result actually states something about the device. False for the
     *               two non-answers. A caller that renders a status badge wants this before it
     *               picks a colour, because "the rule does not apply here" and "we could not tell"
     *               are both wrong to paint green and wrong to paint red.
     * @return  True unless the outcome is UNBEKANNT or NICHT_ANWENDBAR.
     */
    public Boolean hatAussage() {
        return ergebnis != Status.UNBEKANNT && ergebnis != Status.NICHT_ANWENDBAR;
    }
}
