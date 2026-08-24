/**
 * @description  Imports real charge points from OpenStreetMap over the Overpass API.
 *
 *               This is the source that actually answers. OCPI is the protocol the charging
 *               industry roams on and `OcpiImportService` speaks it correctly — but OCPI has no
 *               public endpoint: every operator's interface requires a negotiated token and a
 *               Credentials handshake, which is the protocol's design and not an omission here.
 *               Overpass needs no key, so the fleet on the screen is a fleet somebody actually
 *               mapped, in a city you can go and stand in.
 *
 *               **And it makes the project's central finding demonstrable rather than argued.**
 *               A real charge point in Berlin, operated by a real operator, arrives with a
 *               connector type and a socket count and nothing whatsoever about Inverkehrbringen,
 *               Tag der Eichung or Nacheichung — because no public charge point database exists to
 *               answer a German metrology question. Every imported record evaluates to UNBEKANNT,
 *               which already counts as Handlungsbedarf. On fixtures that was a design principle;
 *               on live data it is the state of the estate.
 *
 *               Two mirrors, tried in order. The public Overpass instances are free shared
 *               infrastructure with no service level, and measured here they returned 502 and 504
 *               as often as 200 — so a single endpoint would make the demo a coin toss. Falling
 *               back is not defensive decoration; it is what using somebody else's free service
 *               honestly requires.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-24
 */
public with sharing class OsmLadepunktImport {

    private static final String SYSTEM_NAME = 'OpenStreetMap';
    private static final String QUELLE = 'OpenStreetMap';

    /** Tried in order. The first that answers wins; every failure is recorded before moving on. */
    private static final List<String> SPIEGEL = new List<String>{
        'callout:Overpass_Primary', 'callout:Overpass_Mirror'
    };

    /** What one import run did. */
    public class Ergebnis {
        public Integer gelesen = 0;
        public Integer uebernommen = 0;
        public Integer fehlerhaft = 0;
        public Integer ohneBetreiber = 0;
        public String spiegel;
        public String hinweis;
    }

    /**
     * @description  Import every mapped charge point inside a bounding box.
     * @param  sued   Southern latitude.
     * @param  west   Western longitude.
     * @param  nord   Northern latitude.
     * @param  ost    Eastern longitude.
     * @param  grenze Maximum number of nodes to take from the response.
     * @return  Counts for the run; never null, never an exception for a failed call.
     */
    public static Ergebnis importiereBereich(Decimal sued, Decimal west, Decimal nord, Decimal ost,
                                             Integer grenze) {
        Ergebnis ergebnis = new Ergebnis();
        Integer maximum = (grenze == null || grenze <= 0) ? 50 : grenze;
        // Collected rather than written as they happen: Apex forbids a callout once the
        // transaction has uncommitted DML, so logging the first mirror's failure would make the
        // second mirror unreachable. The test that asserts the fallback is what found this.
        List<Integrationsfehler__c> fehler = new List<Integrationsfehler__c>();

        String abfrage = '[out:json][timeout:25];node["amenity"="charging_station"]('
            + sued + ',' + west + ',' + nord + ',' + ost + ');out body ' + maximum + ';';

        HttpResponse antwort = holeMitRueckfall(abfrage, ergebnis, fehler);
        if (antwort == null) {
            IntegrationsfehlerLogger.protokolliere(fehler);
            ergebnis.hinweis = 'Kein Overpass-Spiegel hat geantwortet. Es wurde nichts importiert.';
            return ergebnis;
        }

        List<Object> knoten;
        try {
            Map<String, Object> huelle = (Map<String, Object>) JSON.deserializeUntyped(antwort.getBody());
            knoten = (List<Object>) huelle.get('elements');
        } catch (Exception e) {
            fehler.add(IntegrationsfehlerLogger.baue(SYSTEM_NAME, 'Overpass QL',
                antwort.getStatusCode(), 'Die Antwort war kein lesbares JSON: ' + e.getMessage(),
                null, antwort.getBody()));
            IntegrationsfehlerLogger.protokolliere(fehler);
            ergebnis.hinweis = 'Die Antwort des Spiegels war nicht lesbar.';
            return ergebnis;
        }
        if (knoten == null || knoten.isEmpty()) {
            IntegrationsfehlerLogger.protokolliere(fehler);
            ergebnis.hinweis = 'In diesem Bereich ist kein Ladepunkt kartiert.';
            return ergebnis;
        }

        List<Ladepunkt__c> zuSpeichern = new List<Ladepunkt__c>();
        Set<String> gesehen = new Set<String>();
        Map<String, String> betreiberNamen = new Map<String, String>();
        Map<String, String> betreiberJeQuelle = new Map<String, String>();

        for (Object roh : knoten) {
            Map<String, Object> knotenDaten = (Map<String, Object>) roh;
            ergebnis.gelesen++;
            String quellId = 'OSM:' + text(knotenDaten.get('id'));
            if (!gesehen.add(quellId)) {
                continue;
            }
            Map<String, Object> tags = (Map<String, Object>) knotenDaten.get('tags');
            if (tags == null) {
                tags = new Map<String, Object>();
            }
            String betreiber = text(tags.get('operator'));
            if (String.isBlank(betreiber)) {
                // Not an error. A great many mapped charge points carry no operator at all, and
                // that gap is part of what the import is here to show.
                ergebnis.ohneBetreiber++;
            } else {
                betreiberNamen.put(betreiber.toLowerCase(), betreiber);
            }
            zuSpeichern.add(zuLadepunkt(quellId, knotenDaten, tags));
            if (String.isNotBlank(betreiber)) {
                betreiberJeQuelle.put(quellId, betreiber.toLowerCase());
            }
        }

        // Accounts are resolved once for the whole run rather than per record, then stitched back
        // on by source key - a lookup per charge point would be a query per charge point.
        Map<String, Id> betreiberIds = findeOderLegeAn(betreiberNamen.values(), fehler);
        for (Ladepunkt__c lp : zuSpeichern) {
            String schluessel = betreiberJeQuelle.get(lp.Quell_ID__c);
            if (schluessel != null) {
                lp.Betreiber__c = betreiberIds.get(schluessel);
            }
        }

        speichere(zuSpeichern, fehler, ergebnis);
        IntegrationsfehlerLogger.protokolliere(fehler);

        ergebnis.hinweis = ergebnis.uebernommen + ' Ladepunkt(e) aus OpenStreetMap uebernommen'
            + (ergebnis.ohneBetreiber > 0
                ? ', davon ' + ergebnis.ohneBetreiber + ' ohne kartierten Betreiber' : '')
            + '. Die Quelle fuehrt weder Inverkehrbringen noch Eichdaten, daher bleibt der '
            + 'eichrechtliche Status dieser Ladepunkte UNBEKANNT, bis die Daten ergaenzt werden.';
        return ergebnis;
    }

    /**
     * Tries each mirror in turn. A mirror that answers with anything other than 200, or does not
     * answer at all, is recorded and the next one is tried - so a demo does not become a coin toss
     * and a reader can see afterwards which mirror was up.
     */
    private static HttpResponse holeMitRueckfall(String abfrage, Ergebnis ergebnis,
                                                 List<Integrationsfehler__c> fehler) {
        for (String basis : SPIEGEL) {
            try {
                HttpRequest anfrage = new HttpRequest();
                anfrage.setEndpoint(basis + '/interpreter');
                anfrage.setMethod('POST');
                anfrage.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                anfrage.setBody('data=' + EncodingUtil.urlEncode(abfrage, 'UTF-8'));
                anfrage.setTimeout(60000);
                HttpResponse antwort = new Http().send(anfrage);
                if (antwort.getStatusCode() == 200) {
                    ergebnis.spiegel = basis;
                    return antwort;
                }
                fehler.add(IntegrationsfehlerLogger.baue(SYSTEM_NAME, 'POST ' + basis,
                    antwort.getStatusCode(),
                    'Der Spiegel hat mit ' + antwort.getStatus() + ' geantwortet; es wird der '
                    + 'naechste versucht.', null, antwort.getBody()));
            } catch (Exception e) {
                fehler.add(IntegrationsfehlerLogger.baue(SYSTEM_NAME, 'POST ' + basis, 0,
                    'Der Spiegel war nicht erreichbar: ' + e.getMessage(), null, null));
            }
        }
        return null;
    }

    private static Ladepunkt__c zuLadepunkt(String quellId, Map<String, Object> knoten,
                                            Map<String, Object> tags) {
        Ladepunkt__c lp = new Ladepunkt__c(
            Quell_ID__c = quellId,
            Datenquelle__c = QUELLE,
            Zuletzt_importiert_am__c = System.now(),
            Standort_Adresse__c = adresse(knoten, tags),
            OCPI_Status__c = null
        );
        lp.Ladeleistung_kW__c = leistung(tags);
        lp.Stromart__c = stromart(tags);
        return lp;
    }

    /**
     * OpenStreetMap has no single power tag. Power turns up as "22 kW", "22000", "2 x 22 kW" or not
     * at all, across half a dozen keys. The leading number of the largest value wins, because every
     * threshold in the German rules - 4.2, 22, 50 kW - asks what the point can deliver. A value
     * that cannot be read is left null rather than guessed: a wrong power silently moves a charge
     * point across a legal threshold.
     */
    private static Decimal leistung(Map<String, Object> tags) {
        Decimal groesste;
        for (String schluessel : tags.keySet()) {
            if (!schluessel.endsWith(':output') && schluessel != 'charging_station:output') {
                continue;
            }
            Decimal wert = zahlAusText(text(tags.get(schluessel)));
            if (wert != null && (groesste == null || wert > groesste)) {
                groesste = wert;
            }
        }
        return groesste;
    }

    private static Decimal zahlAusText(String roh) {
        if (String.isBlank(roh)) {
            return null;
        }
        Matcher m = Pattern.compile('(\\d+([.,]\\d+)?)').matcher(roh.replace(',', '.'));
        if (!m.find()) {
            return null;
        }
        Decimal wert = Decimal.valueOf(m.group(1));
        // Some mappers write watts. Anything above 1000 is not a kilowatt figure for a charge point.
        return (wert > 1000) ? (wert / 1000).setScale(2) : wert.setScale(2);
    }

    /** A CCS or CHAdeMO socket means DC; a Type 2 socket alone means AC. */
    private static String stromart(Map<String, Object> tags) {
        for (String schluessel : tags.keySet()) {
            String k = schluessel.toLowerCase();
            if (k.contains('chademo') || k.contains('type2_combo') || k.contains('ccs')) {
                return 'DC';
            }
        }
        for (String schluessel : tags.keySet()) {
            if (schluessel.toLowerCase().startsWith('socket:')) {
                return 'AC';
            }
        }
        return null;
    }

    /**
     * Mapped charge points rarely carry a street address, so the name is used where there is one
     * and the coordinates otherwise. A location nobody can find is not a location.
     */
    private static String adresse(Map<String, Object> knoten, Map<String, Object> tags) {
        List<String> teile = new List<String>();
        for (String schluessel : new List<String>{'name', 'addr:street', 'addr:housenumber',
                                                  'addr:postcode', 'addr:city'}) {
            String wert = text(tags.get(schluessel));
            if (String.isNotBlank(wert)) {
                teile.add(wert);
            }
        }
        if (teile.isEmpty()) {
            String lat = text(knoten.get('lat'));
            String lon = text(knoten.get('lon'));
            return (lat == null || lon == null) ? 'Ohne Standortangabe' : lat + ', ' + lon;
        }
        return String.join(teile, ', ');
    }

    /** Operators arrive as names, so the accounts they belong to are matched or created. */
    private static Map<String, Id> findeOderLegeAn(List<String> namen,
                                                   List<Integrationsfehler__c> fehler) {
        Map<String, Id> nachName = new Map<String, Id>();
        if (namen.isEmpty()) {
            return nachName;
        }
        for (Account a : [SELECT Id, Name FROM Account WHERE Name IN :namen WITH USER_MODE LIMIT 50000]) {
            nachName.put(a.Name.toLowerCase(), a.Id);
        }
        List<Account> neue = new List<Account>();
        for (String name : namen) {
            if (!nachName.containsKey(name.toLowerCase())) {
                neue.add(new Account(Name = name));
            }
        }
        if (neue.isEmpty()) {
            return nachName;
        }
        List<Database.SaveResult> ergebnisse = Database.insert(neue, false);
        for (Integer i = 0; i < ergebnisse.size(); i++) {
            if (ergebnisse[i].isSuccess()) {
                nachName.put(neue[i].Name.toLowerCase(), ergebnisse[i].getId());
            } else {
                fehler.add(IntegrationsfehlerLogger.baue(SYSTEM_NAME, 'Insert Account', null,
                    ergebnisse[i].getErrors()[0].getMessage(), neue[i].Name, null));
            }
        }
        return nachName;
    }

    /** Upsert on the source key, partial success allowed, every rejection recorded with its id. */
    private static void speichere(List<Ladepunkt__c> ladepunkte,
                                  List<Integrationsfehler__c> fehler, Ergebnis ergebnis) {
        if (ladepunkte.isEmpty()) {
            return;
        }
        List<Database.UpsertResult> ergebnisse =
            Database.upsert(ladepunkte, Ladepunkt__c.Quell_ID__c, false);
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
                String.join(meldungen, ' | '), ladepunkte[i].Quell_ID__c,
                JSON.serialize(ladepunkte[i])));
        }
    }

    private static String text(Object wert) {
        return wert == null ? null : String.valueOf(wert);
    }
}
