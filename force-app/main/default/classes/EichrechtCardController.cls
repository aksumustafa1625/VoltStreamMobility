/**
 * @description  What the Eichrecht card on a Ladepunkt__c record page reads.
 *
 *               A facade and nothing more: it validates the Id, asks EichrechtService for the
 *               decision, asks LadepunktSelector for the events, and shapes both for the screen.
 *               No SOQL and no legal reasoning live here. The one thing it does own is
 *               presentation — the display label, the badge colour, and the plain sentence saying
 *               what each event did to the calibration period.
 *
 *               Citations arrive from the engine as strings and leave here enriched with the
 *               wording and the source link, so a reviewer can open the card, read what the
 *               ordinance actually says, and follow it to gesetze-im-internet.de without leaving
 *               the record. That is the difference between a status badge and evidence.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
public with sharing class EichrechtCardController {

    /**
     * @description  The full card payload for one charge point.
     * @param  ladepunktId  Record the card sits on.
     * @return  The view model; never null, and never an exception for a merely unknown record.
     */
    @AuraEnabled(cacheable=true)
    public static Ansicht ladeEichrecht(Id ladepunktId) {
        Ansicht sicht = new Ansicht();
        if (ladepunktId == null) {
            sicht.status = 'UNBEKANNT';
            sicht.statusText = 'Unbekannt';
            sicht.farbe = FARBEN.get('UNBEKANNT');
            sicht.begruendung = 'Es wurde kein Ladepunkt uebergeben.';
            return sicht;
        }

        Set<Id> eine = new Set<Id>{ladepunktId};
        List<Ladepunkt__c> gefunden = LadepunktSelector.byIds(eine);
        List<Eingriff__c> ereignisse = LadepunktSelector.eingriffeByLadepunkt(eine);
        DecisionResult d = EichrechtService.bewerteEichfrist(
            gefunden.isEmpty() ? null : gefunden[0], ereignisse, Date.today());

        sicht.status = String.valueOf(d.ergebnis);
        sicht.statusText = BESCHRIFTUNG.get(sicht.status);
        sicht.farbe = FARBEN.get(sicht.status);
        sicht.istAussage = d.hatAussage();
        sicht.begruendung = d.begruendung;
        sicht.fristbeginn = d.fristbeginn;
        sicht.fristende = d.fristende;
        sicht.stichtag = d.stichtag;
        if (d.fristende != null) {
            sicht.tageBisAblauf = d.stichtag.daysBetween(d.fristende);
        }
        sicht.rechtsgrundlagen = zuNormbezuegen(d.normSchluessel);
        sicht.verlauf = zuVerlauf(ereignisse);
        return sicht;
    }

    private static List<Normbezug> zuNormbezuegen(List<String> schluessel) {
        List<Normbezug> bezuege = new List<Normbezug>();
        for (String s : schluessel) {
            Rechtsnorm__mdt norm = Rechtsnorm__mdt.getInstance(s);
            if (norm == null) {
                continue;
            }
            Normbezug b = new Normbezug();
            b.schluessel = s;
            b.norm = norm.Norm__c;
            b.wortlaut = norm.Wortlaut__c;
            b.hinweis = norm.Hinweis__c;
            b.url = norm.Quelle_URL__c;
            b.aufgehoben = norm.Gueltig_bis__c != null;
            bezuege.add(b);
        }
        return bezuege;
    }

    /**
     * The timeline reads each event's own formula fields rather than re-deriving the chronology.
     * The card shows what an event did on its own terms; what the sequence of events adds up to is
     * the engine's answer and is shown once, at the top, instead of being guessed at per row.
     */
    private static List<Ereignis> zuVerlauf(List<Eingriff__c> ereignisse) {
        List<Ereignis> verlauf = new List<Ereignis>();
        for (Eingriff__c e : ereignisse) {
            Ereignis v = new Ereignis();
            v.id = e.Id;
            v.typ = e.Typ__c;
            v.datum = e.Datum__c;
            v.beschreibung = e.Beschreibung__c;
            v.sperrt = (e.Sperrt_Betrieb__c == true);
            v.wirkung = wirkung(e);
            v.farbe = v.sperrt ? FARBEN.get('BETRIEB_GESPERRT')
                    : (e.Beendet_Eichfrist__c == true ? FARBEN.get('ABGELAUFEN')
                    : (e.Typ__c == 'Nacheichung' ? FARBEN.get('GUELTIG') : FARBEN.get('UNBEKANNT')));
            verlauf.add(v);
        }
        return verlauf;
    }

    private static String wirkung(Eingriff__c e) {
        if (e.Sperrt_Betrieb__c == true) {
            return 'Sperrt den Betrieb bis zur behoerdlichen Freigabe. Die Eichfrist bleibt '
                 + 'unberuehrt (§ 37 Abs. 6 MessEG).';
        }
        if (e.Typ__c == 'Instandsetzung') {
            return wirkungInstandsetzung(e);
        }
        if (e.Beendet_Eichfrist__c == true) {
            return 'Beendet die Eichfrist vorzeitig (§ 37 Abs. 2 Nr. 2 MessEG).';
        }
        if (e.Typ__c == 'Nacheichung') {
            return 'Setzt eine neue Eichfrist in Gang (§ 34 Abs. 1 MessEV).';
        }
        return 'Behoerdlich freigegeben - der Betrieb ist wieder zulaessig.';
    }

    /**
     * The repair exemption fails as a whole if any one of its four conditions is missing, so the
     * card names the missing ones rather than reporting that "the conditions were not met". Which
     * Nummer is open is the difference between a status and something an operator can act on —
     * and Nr. 2 in particular is a duty that outlives the exemption: exempt from early termination
     * still means an application falls due immediately.
     */
    private static String wirkungInstandsetzung(Eingriff__c e) {
        List<String> fehlend = new List<String>();
        if (e.Instandsetzer_befugt__c != true)  { fehlend.add('befugter Instandsetzer (Nr. 1)'); }
        if (e.Nacheichung_beantragt__c != true) { fehlend.add('unverzueglich beantragte erneute Eichung (Nr. 2)'); }
        if (e.Kennzeichnung_41__c != true)      { fehlend.add('Kennzeichnung nach § 41 MessEV (Nr. 3)'); }
        if (e.Behoerde_informiert__c != true)   { fehlend.add('unverzuegliche Information der Behoerde (Nr. 4)'); }

        if (fehlend.isEmpty()) {
            return 'Instandsetzung nach § 37 Abs. 5 MessEG - alle vier Bedingungen erfuellt, die '
                 + 'Eichfrist laeuft weiter.';
        }
        return 'Instandsetzung ohne alle vier Bedingungen des § 37 Abs. 5 MessEG. Es fehlt: '
             + String.join(fehlend, '; ') + '. Damit faellt sie auf Abs. 2 Nr. 2 zurueck und '
             + 'beendet die Eichfrist vorzeitig.';
    }

    private static final Map<String, String> BESCHRIFTUNG = new Map<String, String>{
        'GUELTIG'           => 'Gültig geeicht',
        'GESCHUETZT'        => 'Geschützt nach § 38',
        'ERMESSEN'          => 'Behördliches Ermessen',
        'ABGELAUFEN'        => 'Eichfrist abgelaufen',
        'VORZEITIG_BEENDET' => 'Eichfrist vorzeitig beendet',
        'BETRIEB_GESPERRT'  => 'Betrieb gesperrt',
        'UNBEKANNT'         => 'Unbekannt',
        'NICHT_ANWENDBAR'   => 'Nicht anwendbar'
    };

    /**
     * Hex values rather than SLDS variables, because the card paints an inline SVG through
     * `fill="currentColor"` — the one icon technique that survives shadow DOM reliably. Grey for
     * both non-answers on purpose: neither a data gap nor an inapplicable provision may be painted
     * in a colour that reads as a verdict.
     */
    private static final Map<String, String> FARBEN = new Map<String, String>{
        'GUELTIG'           => '#2e844a',
        'GESCHUETZT'        => '#0176d3',
        'ERMESSEN'          => '#fe9339',
        'ABGELAUFEN'        => '#ea001e',
        'VORZEITIG_BEENDET' => '#ea001e',
        'BETRIEB_GESPERRT'  => '#ba0517',
        'UNBEKANNT'         => '#747474',
        'NICHT_ANWENDBAR'   => '#747474'
    };

    public class Ansicht {
        @AuraEnabled public String status;
        @AuraEnabled public String statusText;
        @AuraEnabled public String farbe;
        @AuraEnabled public Boolean istAussage = false;
        @AuraEnabled public String begruendung;
        @AuraEnabled public Date fristbeginn;
        @AuraEnabled public Date fristende;
        @AuraEnabled public Date stichtag;
        @AuraEnabled public Integer tageBisAblauf;
        @AuraEnabled public List<Normbezug> rechtsgrundlagen = new List<Normbezug>();
        @AuraEnabled public List<Ereignis> verlauf = new List<Ereignis>();
    }

    public class Normbezug {
        @AuraEnabled public String schluessel;
        @AuraEnabled public String norm;
        @AuraEnabled public String wortlaut;
        @AuraEnabled public String hinweis;
        @AuraEnabled public String url;
        @AuraEnabled public Boolean aufgehoben = false;
    }

    public class Ereignis {
        @AuraEnabled public String id;
        @AuraEnabled public String typ;
        @AuraEnabled public Date datum;
        @AuraEnabled public String beschreibung;
        @AuraEnabled public String wirkung;
        @AuraEnabled public String farbe;
        @AuraEnabled public Boolean sperrt = false;
    }
}
