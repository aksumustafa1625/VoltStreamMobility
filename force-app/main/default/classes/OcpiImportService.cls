/**
 * @description  Pulls charge points from a CPO backend over OCPI 2.2.1 and upserts them.
 *
 *               OCPI is the protocol the charging industry actually roams on: a CPO exposes
 *               Locations, each Location holds EVSEs, each EVSE holds Connectors. The eMI3 `evse_id`
 *               is the only identifier a CPO backend and German metrology law have in common, so it
 *               is the upsert key — without it every nightly run would create the fleet again.
 *
 *               **What this integration proves is what OCPI does not carry.** There is no
 *               Inverkehrbringen in OCPI, no Tag der Eichung, no Nacheichung. A CPO can hand over
 *               ten thousand charge points and not one of them carries what MessEG and MessEV
 *               require. So an imported fleet evaluates to UNBEKANNT — and UNBEKANNT already counts
 *               as Handlungsbedarf. That is not a defect in the import; it is the realistic default
 *               state of an imported estate, and the reason the engine was built to distinguish
 *               "we cannot tell" from "nothing to report" in the first place.
 *
 *               The operational status the CPO reports is kept in its own field and deliberately
 *               never mixed into Eichstatus__c. A charge point can be AVAILABLE to a driver and
 *               legally unusable at the same time; conflating the two is the mistake this whole
 *               project exists to avoid.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-24
 */
public with sharing class OcpiImportService {

    private static final String SYSTEM_NAME = 'OCPI';
    private static final String PFAD_LOCATIONS = '/locations';

    /** What one import run did, in numbers a caller can log or show. */
    public class Ergebnis {
        public Integer standorte = 0;
        public Integer gelesen = 0;
        public Integer uebernommen = 0;
        public Integer fehlerhaft = 0;
        public Integer ohneEichdaten = 0;
        public String hinweis;
    }

    /**
     * @description  Import every EVSE the CPO exposes and upsert it as a Ladepunkt__c.
     * @return  Counts for the run; never null, never an exception for a failed call.
     */
    public static Ergebnis importiereLadepunkte() {
        Ergebnis ergebnis = new Ergebnis();
        HttpResponse antwort;
        try {
            antwort = ruf(PFAD_LOCATIONS);
        } catch (Exception e) {
            IntegrationsfehlerLogger.protokolliere(SYSTEM_NAME, 'GET ' + PFAD_LOCATIONS, 0,
                'Der Aufruf hat den Endpunkt nicht erreicht: ' + e.getMessage(), null, null);
            ergebnis.hinweis = 'Der CPO-Endpunkt war nicht erreichbar. Es wurde nichts importiert.';
            return ergebnis;
        }

        if (antwort.getStatusCode() != 200) {
            IntegrationsfehlerLogger.protokolliere(SYSTEM_NAME, 'GET ' + PFAD_LOCATIONS,
                antwort.getStatusCode(), 'Der CPO hat mit ' + antwort.getStatus() + ' geantwortet.',
                null, antwort.getBody());
            ergebnis.hinweis = 'Der CPO hat den Abruf abgelehnt. Es wurde nichts importiert.';
            return ergebnis;
        }

        List<Object> standorte;
        try {
            Map<String, Object> huelle = (Map<String, Object>) JSON.deserializeUntyped(antwort.getBody());
            standorte = (List<Object>) huelle.get('data');
        } catch (Exception e) {
            IntegrationsfehlerLogger.protokolliere(SYSTEM_NAME, 'GET ' + PFAD_LOCATIONS,
                antwort.getStatusCode(), 'Die Antwort war kein gueltiges OCPI-Dokument: '
                + e.getMessage(), null, antwort.getBody());
            ergebnis.hinweis = 'Die Antwort des CPO war nicht lesbar.';
            return ergebnis;
        }
        if (standorte == null) {
            ergebnis.hinweis = 'Der CPO hat keine Standorte geliefert.';
            return ergebnis;
        }

        List<Ladepunkt__c> zuSpeichern = new List<Ladepunkt__c>();
        List<Integrationsfehler__c> fehler = new List<Integrationsfehler__c>();
        Set<String> gesehen = new Set<String>();

        for (Object roh : standorte) {
            ergebnis.standorte++;
            Map<String, Object> standort = (Map<String, Object>) roh;
            for (Ladepunkt__c lp : ausStandort(standort, fehler)) {
                ergebnis.gelesen++;
                // The CPO may list the same EVSE under two locations. Upserting a batch that
                // repeats an external id fails the whole batch, so the duplicate is dropped here
                // and recorded rather than allowed to take the run down.
                if (!gesehen.add(lp.EVSE_ID__c)) {
                    fehler.add(IntegrationsfehlerLogger.baue(SYSTEM_NAME, 'GET ' + PFAD_LOCATIONS,
                        200, 'Dieselbe EVSE-ID kam mehrfach in einer Antwort vor und wurde nur '
                        + 'einmal uebernommen.', lp.EVSE_ID__c, null));
                    continue;
                }
                zuSpeichern.add(lp);
            }
        }

        ergebnis.fehlerhaft = fehler.size();
        speichere(zuSpeichern, fehler, ergebnis);
        IntegrationsfehlerLogger.protokolliere(fehler);

        ergebnis.ohneEichdaten = ergebnis.uebernommen;
        ergebnis.hinweis = ergebnis.uebernommen + ' Ladepunkt(e) uebernommen. OCPI fuehrt weder '
            + 'Inverkehrbringen noch Eichdaten, daher bleibt der eichrechtliche Status dieser '
            + 'Ladepunkte UNBEKANNT, bis die Daten ergaenzt werden.';
        return ergebnis;
    }

    /** Callout kept in one place so a test mock has one seam and a URL change has one file. */
    private static HttpResponse ruf(String pfad) {
        HttpRequest anfrage = new HttpRequest();
        anfrage.setEndpoint('callout:OCPI_CPO' + pfad);
        anfrage.setMethod('GET');
        anfrage.setHeader('Accept', 'application/json');
        anfrage.setTimeout(60000);
        return new Http().send(anfrage);
    }

    /**
     * One OCPI Location yields one Ladepunkt__c per EVSE. A location without EVSEs is not an error
     * - a CPO may publish a site before it energises it - so it is skipped silently, while an EVSE
     * without an evse_id is recorded, because that one cannot be matched on the next run either.
     */
    private static List<Ladepunkt__c> ausStandort(Map<String, Object> standort,
                                                  List<Integrationsfehler__c> fehler) {
        List<Ladepunkt__c> ladepunkte = new List<Ladepunkt__c>();
        String standortId = text(standort.get('id'));
        String adresse = adresseAus(standort);
        List<Object> evses = (List<Object>) standort.get('evses');
        if (evses == null) {
            return ladepunkte;
        }

        for (Object rohEvse : evses) {
            Map<String, Object> evse = (Map<String, Object>) rohEvse;
            String evseId = text(evse.get('evse_id'));
            if (String.isBlank(evseId)) {
                fehler.add(IntegrationsfehlerLogger.baue(SYSTEM_NAME, 'GET ' + PFAD_LOCATIONS, 200,
                    'Ein EVSE kam ohne evse_id. Ohne diese Kennung laesst er sich weder zuordnen '
                    + 'noch beim naechsten Lauf wiederfinden.', standortId, JSON.serialize(evse)));
                continue;
            }
            Ladepunkt__c lp = new Ladepunkt__c(
                EVSE_ID__c = evseId,
                OCPI_Standort_ID__c = standortId,
                OCPI_Status__c = text(evse.get('status')),
                Standort_Adresse__c = adresse,
                Datenquelle__c = 'OCPI',
                Zuletzt_importiert_am__c = System.now()
            );
            uebernehmeAnschluss(lp, (List<Object>) evse.get('connectors'));
            ladepunkte.add(lp);
        }
        return ladepunkte;
    }

    /**
     * Power and current type come from the connectors, not from the EVSE. Where an EVSE has several,
     * the strongest wins: the regulatory thresholds - 4.2 kW, 22 kW, 50 kW - all ask what the point
     * can deliver, not what its weakest socket can.
     */
    private static void uebernehmeAnschluss(Ladepunkt__c lp, List<Object> connectors) {
        if (connectors == null || connectors.isEmpty()) {
            return;
        }
        Decimal maxKw;
        String stromart;
        for (Object roh : connectors) {
            Map<String, Object> anschluss = (Map<String, Object>) roh;
            Object watt = anschluss.get('max_electric_power');
            if (watt != null) {
                // OCPI reports watts; every threshold in the German rules is stated in kW.
                Decimal kw = (Decimal.valueOf(String.valueOf(watt)) / 1000).setScale(2);
                if (maxKw == null || kw > maxKw) {
                    maxKw = kw;
                    stromart = stromartAus(text(anschluss.get('power_type')));
                }
            }
        }
        lp.Ladeleistung_kW__c = maxKw;
        lp.Stromart__c = stromart;
    }

    /** OCPI distinguishes one-phase from three-phase AC; the Eichfrist does not. */
    private static String stromartAus(String powerType) {
        if (String.isBlank(powerType)) {
            return null;
        }
        return powerType.startsWith('DC') ? 'DC' : 'AC';
    }

    private static String adresseAus(Map<String, Object> standort) {
        List<String> teile = new List<String>();
        for (String schluessel : new List<String>{'address', 'postal_code', 'city'}) {
            String wert = text(standort.get(schluessel));
            if (String.isNotBlank(wert)) {
                teile.add(wert);
            }
        }
        return teile.isEmpty() ? null : String.join(teile, ', ');
    }

    private static String text(Object wert) {
        return wert == null ? null : String.valueOf(wert);
    }

    /**
     * Upsert on the external id, partial success allowed. One charge point the org rejects - a
     * validation rule, a field length - must not discard the other seven hundred, and the row that
     * failed is recorded with its identifier so somebody can find it.
     */
    private static void speichere(List<Ladepunkt__c> ladepunkte,
                                  List<Integrationsfehler__c> fehler, Ergebnis ergebnis) {
        if (ladepunkte.isEmpty()) {
            return;
        }
        Schema.SObjectField schluessel = Ladepunkt__c.EVSE_ID__c;
        List<Database.UpsertResult> ergebnisse = Database.upsert(ladepunkte, schluessel, false);
        for (Integer i = 0; i < ergebnisse.size(); i++) {
            if (ergebnisse[i].isSuccess()) {
                ergebnis.uebernommen++;
                continue;
            }
            ergebnis.fehlerhaft++;
            List<String> meldungen = new List<String>();
            for (Database.Error e : ergebnisse[i].getErrors()) {
                meldungen.add(e.getStatusCode() + ': ' + e.getMessage());
            }
            fehler.add(IntegrationsfehlerLogger.baue(SYSTEM_NAME, 'Upsert Ladepunkt__c', null,
                String.join(meldungen, ' | '), ladepunkte[i].EVSE_ID__c,
                JSON.serialize(ladepunkte[i])));
        }
    }
}
