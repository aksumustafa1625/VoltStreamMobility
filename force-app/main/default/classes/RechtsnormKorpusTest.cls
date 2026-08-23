/**
 * @description  Integrity tests for the statute corpus in Rechtsnorm__mdt.
 *
 *               This class deliberately has no production partner. What it tests is deployed
 *               metadata rather than code, and that is exactly why it has to be tested: custom
 *               metadata cannot be inserted by DML, so every legal change arrives as a git diff
 *               and the only thing standing between a bad diff and a wrong legal answer is a
 *               test that runs in CI.
 *
 *               It asserts three things a text key cannot give for free — that the records the
 *               engine addresses by name still exist, that a citation string never silently
 *               changes shape, and that a repealed norm keeps both its end date and a successor
 *               that resolves.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-23
 */
@IsTest
private class RechtsnormKorpusTest {

    /**
     * Keys the engine addresses directly. If one is renamed or dropped, getInstance returns null
     * at runtime and the agent loses its citation — silently, because a null Wortlaut reads like
     * an empty answer rather than a missing law.
     */
    private static final Map<String, String> ERWARTETE_NORMEN = new Map<String, String>{
        'MessEG_37_1_2'             => '§ 37 Abs. 1 Satz 2 MessEG',
        'MessEG_37_2_2'             => '§ 37 Abs. 2 Nr. 2 MessEG',
        'MessEG_37_5_2'             => '§ 37 Abs. 5 Nr. 2 MessEG',
        'MessEG_37_6'               => '§ 37 Abs. 6 MessEG',
        'MessEG_38_1'               => '§ 38 Satz 1 MessEG',
        'MessEG_38_2'               => '§ 38 Satz 2 MessEG',
        'MessEV_34_1_1'             => '§ 34 Abs. 1 Satz 1 MessEV',
        'MessEV_34_1_2'             => '§ 34 Abs. 1 Satz 2 MessEV',
        'MessEV_34_1_3'             => '§ 34 Abs. 1 Satz 3 MessEV',
        'MessEV_34_1_4'             => '§ 34 Abs. 1 Satz 4 MessEV',
        'MessEV_34_2'               => '§ 34 Abs. 2 MessEV',
        'MessEV_Anlage7_Tab1_Nr6_7' => 'MessEV Anlage 7 Tabelle 1 Nr. 6.7',
        'EnWG_14a_3'                => '§ 14a Abs. 3 EnWG'
    };

    @IsTest
    static void jedeAdressierteNormIstVorhandenUndTraegtIhrZitat() {
        for (String schluessel : ERWARTETE_NORMEN.keySet()) {
            Rechtsnorm__mdt norm = Rechtsnorm__mdt.getInstance(schluessel);
            System.assertNotEquals(null, norm,
                'Der Korpus kennt den Schluessel nicht mehr: ' + schluessel);
            System.assertEquals(ERWARTETE_NORMEN.get(schluessel), norm.Norm__c,
                'Das Zitat zu ' + schluessel + ' hat sich geaendert. Norm__c ist der String, den '
                + 'eine Aktion als rechtsgrundlage zurueckgibt und den das Transkript-Gate prueft.');
        }
    }

    @IsTest
    static void jedeAdressierteNormHatEinenWortlaut() {
        // A Rechtsnorm without a Wortlaut is an empty citation: the agent would cite a paragraph
        // it cannot quote. Two records are knowingly text-free and named here rather than
        // excluded by a wildcard, so adding a third is a decision and not an oversight.
        Set<String> ohneWortlaut = new Set<String>{'LSV_2016_aufgehoben', 'LSV_2025_Neufassung'};
        for (String schluessel : ERWARTETE_NORMEN.keySet()) {
            if (ohneWortlaut.contains(schluessel)) {
                continue;
            }
            System.assertNotEquals(null, Rechtsnorm__mdt.getInstance(schluessel).Wortlaut__c,
                schluessel + ' hat keinen Wortlaut. Ein Zitat ohne Text ist kein Zitat.');
        }
    }

    @IsTest
    static void aufgehobeneNormenBleibenMitEndedatumUndNachfolger() {
        // The repealed Ladesaeulenverordnung is the corpus's own evidence for the factuality
        // experiment: someone citing "LSV § 4 verlangt Kartenzahlung" is quoting a provision that
        // ceased to exist on 1 January 2026. Deleting the record would destroy the engine's
        // ability to say a citation WAS right and no longer is.
        Rechtsnorm__mdt alt = Rechtsnorm__mdt.getInstance('LSV_2016_aufgehoben');
        System.assertNotEquals(null, alt,
            'Aufgehobene Normen werden nicht geloescht, sie bekommen ein Gueltig_bis__c.');
        System.assertEquals(Date.newInstance(2025, 12, 31), alt.Gueltig_bis__c,
            'Die Ladesaeulenverordnung von 2016 galt bis zum 31. Dezember 2025.');

        System.assertNotEquals(null, alt.Abgeloest_durch__c,
            'Eine aufgehobene Norm ohne Nachfolger laesst die Frage offen, was stattdessen gilt.');
        System.assertNotEquals(null, Rechtsnorm__mdt.getInstance(alt.Abgeloest_durch__c),
            'Abgeloest_durch__c zeigt auf ' + alt.Abgeloest_durch__c + ', und dieser Datensatz '
            + 'fehlt. Der Schluessel ist bewusst Text und keine Beziehung, also muss ein Test '
            + 'leisten, was das Schema hier nicht erzwingt.');
    }

    @IsTest
    static void inKraftBefindlicheNormenHabenKeinEndedatum() {
        for (String schluessel : ERWARTETE_NORMEN.keySet()) {
            System.assertEquals(null, Rechtsnorm__mdt.getInstance(schluessel).Gueltig_bis__c,
                schluessel + ' traegt ein Gueltig_bis__c. Entweder ist die Norm aufgehoben - dann '
                + 'gehoert sie nicht mehr in die Liste der adressierten Normen - oder das Datum '
                + 'ist ein Fehler.');
        }
    }
}
