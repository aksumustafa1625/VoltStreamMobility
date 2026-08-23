/**
 * @description  Table-driven verification of DateUtils. Every row carries the sentence of the
 *               statute it encodes, so the tables can be read straight against § 34 MessEV and
 *               § 38 MessEG. That format is the point: a reviewer who cannot judge German
 *               metrology law can still check that each row's citation matches its expectation,
 *               and the boundary rows — the last lawful day, the first late one — are where the
 *               statute actually bites.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
@IsTest
private class DateUtilsTest {

    /** One row of the § 34 Abs. 1 Sätze 2–4 table. */
    private class Fristbeginnfall {
        String norm;
        String beschreibung;
        Date eichung;
        Date vorherigesEnde;
        Boolean stillgelegt;
        Date erwartet;
        Fristbeginnfall(String norm, String beschreibung, Date eichung,
                        Date vorherigesEnde, Boolean stillgelegt, Date erwartet) {
            this.norm = norm;
            this.beschreibung = beschreibung;
            this.eichung = eichung;
            this.vorherigesEnde = vorherigesEnde;
            this.stillgelegt = stillgelegt;
            this.erwartet = erwartet;
        }
    }

    @IsTest
    static void fristbeginnNachEichung_folgtDenVierSaetzen() {
        List<Fristbeginnfall> tabelle = new List<Fristbeginnfall>{
            new Fristbeginnfall('§ 34 I 2 MessEV', 'Erste Eichung, keine Vorfrist',
                Date.newInstance(2020, 5, 10), null, false,
                Date.newInstance(2020, 5, 10)),

            new Fristbeginnfall('§ 34 I 2 MessEV', 'Rechtzeitig innerhalb der laufenden Frist',
                Date.newInstance(2022, 3, 1), Date.newInstance(2023, 12, 31), false,
                Date.newInstance(2022, 3, 1)),

            // The last lawful day. One day either side of this row is the whole provision.
            new Fristbeginnfall('§ 34 I 2 MessEV', 'Am allerletzten Tag der Frist geeicht',
                Date.newInstance(2023, 12, 31), Date.newInstance(2023, 12, 31), false,
                Date.newInstance(2023, 12, 31)),

            new Fristbeginnfall('§ 34 I 3 MessEV', 'Einen Tag zu spaet: Rueckdatierung greift',
                Date.newInstance(2024, 1, 1), Date.newInstance(2023, 12, 31), false,
                Date.newInstance(2023, 12, 31)),

            // The case the live status matrix carries as DEFERRED. Here it is answered.
            new Fristbeginnfall('§ 34 I 3 MessEV', 'Monate zu spaet — Matrixfall E',
                Date.newInstance(2024, 3, 10), Date.newInstance(2023, 12, 31), false,
                Date.newInstance(2023, 12, 31)),

            new Fristbeginnfall('§ 34 I 4 MessEV', 'Zu spaet, aber Stilllegung nachgewiesen',
                Date.newInstance(2024, 3, 10), Date.newInstance(2023, 12, 31), true,
                Date.newInstance(2024, 3, 10)),

            // Satz 4 relieves Satz 3 and nothing else. A dormancy claim on a device that was
            // never late must not move the start — it would silently grant extra months.
            new Fristbeginnfall('§ 34 I 4 MessEV', 'Stilllegung behauptet, aber rechtzeitig geeicht',
                Date.newInstance(2022, 3, 1), Date.newInstance(2023, 12, 31), true,
                Date.newInstance(2022, 3, 1)),

            new Fristbeginnfall('Nullvertrag', 'Fehlende Behauptung = die haertere Antwort',
                Date.newInstance(2024, 3, 10), Date.newInstance(2023, 12, 31), null,
                Date.newInstance(2023, 12, 31)),

            new Fristbeginnfall('Nullvertrag', 'Eichungsdatum unbekannt',
                null, Date.newInstance(2023, 12, 31), false, null)
        };

        for (Fristbeginnfall f : tabelle) {
            System.assertEquals(
                f.erwartet,
                DateUtils.fristbeginnNachEichung(f.eichung, f.vorherigesEnde, f.stillgelegt),
                f.norm + ' — ' + f.beschreibung);
        }
    }

    /** One row of the § 34 Abs. 1 Satz 1 / Abs. 2 table. */
    private class Fristendefall {
        String norm;
        String beschreibung;
        Date beginn;
        Integer jahre;
        Date erwartet;
        Fristendefall(String norm, String beschreibung, Date beginn, Integer jahre, Date erwartet) {
            this.norm = norm;
            this.beschreibung = beschreibung;
            this.beginn = beginn;
            this.jahre = jahre;
            this.erwartet = erwartet;
        }
    }

    @IsTest
    static void fristende_schiebtAufDasJahresende() {
        List<Fristendefall> tabelle = new List<Fristendefall>{
            new Fristendefall('§ 34 II MessEV', 'Acht Jahre ab Inverkehrbringen',
                Date.newInstance(2015, 6, 1), DateUtils.EICHFRIST_LADEPUNKT_JAHRE,
                Date.newInstance(2023, 12, 31)),

            // What § 34 I 3 hands back for matrix case E, carried through to its end date.
            new Fristendefall('§ 34 II MessEV', 'Ab rueckdatiertem Beginn — Matrixfall E',
                Date.newInstance(2023, 12, 31), DateUtils.EICHFRIST_LADEPUNKT_JAHRE,
                Date.newInstance(2031, 12, 31)),

            new Fristendefall('§ 34 II MessEV', 'Ab Tag der Eichung — Matrixfall P',
                Date.newInstance(2024, 3, 10), DateUtils.EICHFRIST_LADEPUNKT_JAHRE,
                Date.newInstance(2032, 12, 31)),

            new Fristendefall('§ 34 I 1 MessEV', 'Gesetzlicher Regelfall sind zwei Jahre',
                Date.newInstance(2024, 6, 15), DateUtils.EICHFRIST_STANDARD_JAHRE,
                Date.newInstance(2026, 12, 31)),

            // Apex clamps 29 February onto 28 February in a common year. Abs. 2 reads only the
            // year, so the clamp cannot reach the answer — asserted rather than assumed.
            new Fristendefall('§ 34 II MessEV', 'Schalttag, Zieljahr ohne 29. Februar',
                Date.newInstance(2020, 2, 29), 3, Date.newInstance(2023, 12, 31)),

            new Fristendefall('Nullvertrag', 'Fristbeginn unbekannt',
                null, DateUtils.EICHFRIST_LADEPUNKT_JAHRE, null),

            new Fristendefall('Nullvertrag', 'Fristlaenge unbekannt',
                Date.newInstance(2015, 6, 1), null, null)
        };

        for (Fristendefall f : tabelle) {
            System.assertEquals(f.erwartet, DateUtils.fristende(f.beginn, f.jahre),
                f.norm + ' — ' + f.beschreibung);
        }
    }

    @IsTest
    static void fristende_lehntUnterjaehrigeFristenAb() {
        // § 34 Abs. 2 applies only to Fristen of at least a year; anything shorter belongs to
        // Abs. 3 and ends at month's end. Failing loudly beats returning a year-end that would
        // be wrong by up to eleven months.
        try {
            DateUtils.fristende(Date.newInstance(2024, 6, 15), 0);
            System.assert(false, 'Eine Frist unter einem Jahr haette abgelehnt werden muessen.');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('§ 34 Abs. 3 MessEV'),
                'Die Ablehnung soll die einschlaegige Norm nennen: ' + e.getMessage());
        }
    }

    /** One row of the § 38 MessEG table. */
    private class Antragsfall {
        String norm;
        String beschreibung;
        Date antrag;
        Date ende;
        Boolean erwartet;
        Antragsfall(String norm, String beschreibung, Date antrag, Date ende, Boolean erwartet) {
            this.norm = norm;
            this.beschreibung = beschreibung;
            this.antrag = antrag;
            this.ende = ende;
            this.erwartet = erwartet;
        }
    }

    @IsTest
    static void istAntragRechtzeitig_trenntSchutzVonErmessen() {
        Date ende = Date.newInstance(2023, 12, 31);
        List<Antragsfall> tabelle = new List<Antragsfall>{
            // Ten weeks to the day. "Mindestens" makes this row protected, not the first late one.
            new Antragsfall('§ 38 S. 1 MessEG', 'Exakt zehn Wochen vorher',
                Date.newInstance(2023, 10, 22), ende, true),

            new Antragsfall('§ 38 S. 1 MessEG', 'Einen Tag frueher als noetig',
                Date.newInstance(2023, 10, 21), ende, true),

            new Antragsfall('§ 38 S. 2 MessEG', 'Einen Tag zu spaet — nur noch Ermessen',
                Date.newInstance(2023, 10, 23), ende, false),

            new Antragsfall('§ 38 S. 2 MessEG', 'Erst nach Fristablauf beantragt',
                Date.newInstance(2024, 2, 1), ende, false),

            new Antragsfall('Nullvertrag', 'Gar nicht beantragt', null, ende, false),

            new Antragsfall('Nullvertrag', 'Fristende unbekannt',
                Date.newInstance(2023, 10, 22), null, false)
        };

        for (Antragsfall f : tabelle) {
            System.assertEquals(f.erwartet, DateUtils.istAntragRechtzeitig(f.antrag, f.ende),
                f.norm + ' — ' + f.beschreibung);
        }
    }

    @IsTest
    static void deutschSchreibtDatenUnabhaengigVomGebietsschema() {
        // Asserted under an explicitly English locale, because that is the case that breaks:
        // Date.format() would render 23.08.2026 as 8/23/2026 and put a US date inside a German
        // legal sentence that the agent then reads out.
        User englisch = new User(
            Alias = 'enloc', Email = 'eichrecht.locale@voltstream.invalid',
            EmailEncodingKey = 'UTF-8', LastName = 'Locale', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'Europe/Berlin',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            UserName = 'eichrecht.locale.' + DateTime.now().getTime() + '@voltstream.invalid');
        insert englisch;

        Test.startTest();
        System.runAs(englisch) {
            System.assertEquals('23.08.2026', DateUtils.deutsch(Date.newInstance(2026, 8, 23)),
                'Ein englisches Gebietsschema darf die deutsche Schreibweise nicht veraendern.');
            System.assertEquals('01.01.2027', DateUtils.deutsch(Date.newInstance(2027, 1, 1)),
                'Tag und Monat werden zweistellig geschrieben.');
            System.assertEquals('unbekannt', DateUtils.deutsch(null),
                'Ein fehlendes Datum wird zum deutschen Wort, nicht zur Zeichenfolge "null" '
                + 'mitten im Satz.');
        }
        Test.stopTest();
    }

    @IsTest
    static void konstanten_stimmenMitDemNormenkorpusUeberein() {
        // One source of truth. Every number below also lives in Rechtsnorm__mdt beside the
        // sentence that sets it, and the corpus is the authority — these constants are only the
        // convenience. This test is what stops the two from drifting: a Verordnung that changes
        // the corpus then fails the build instead of quietly disagreeing with the engine.
        System.assertEquals(
            DateUtils.EICHFRIST_STANDARD_JAHRE,
            Rechtsnorm__mdt.getInstance('MessEV_34_1_1').Parameter_Wert__c.intValue(),
            '§ 34 Abs. 1 Satz 1 MessEV: der gesetzliche Regelfall.');

        System.assertEquals(
            DateUtils.EICHFRIST_LADEPUNKT_JAHRE,
            Rechtsnorm__mdt.getInstance('MessEV_Anlage7_Tab1_Nr6_7').Parameter_Wert__c.intValue(),
            'MessEV Anlage 7 Tabelle 1 Nr. 6.7: acht Jahre, ein Eintrag fuer AC und DC.');

        // The statute counts weeks and the arithmetic counts days. Asserting the conversion
        // rather than the bare 70 keeps the constant tied to what § 38 actually says.
        Decimal wochen = Rechtsnorm__mdt.getInstance('MessEG_38_1').Parameter_Wert__c;
        System.assertEquals(DateUtils.ANTRAGSFRIST_TAGE, (wochen * 7).intValue(),
            '§ 38 Satz 1 MessEG: zehn Wochen sind siebzig Tage.');
    }
}
