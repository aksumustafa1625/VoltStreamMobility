/**
 * @description  Everything the compliance path does, run as a user who holds nothing but
 *               `VoltStream_Eichrecht_Access`.
 *
 *               Every other test in this project runs as an administrator, which is the one user
 *               whose permissions prove nothing. `WITH USER_MODE` appears on every query and was,
 *               until this class existed, a claim rather than a demonstration.
 *
 *               It was written because the claim failed in production. The agent — which runs as a
 *               service user, not as an administrator — began answering "der Status konnte nicht
 *               bestimmt werden" for a charge point whose status was perfectly determinable. The
 *               cause was a Selector pulling `Betreiber__r.Name` on a path that never read it:
 *               under `WITH USER_MODE` a cross-object field drags that object's permissions into
 *               the dependency, and one missing object grant took the whole feature down. Nothing
 *               in the suite could have caught it, because nothing in the suite ran as anybody but
 *               an admin.
 *
 *               The failure mode is worth naming: it did not throw a visible error at a developer.
 *               It degraded into a polite German sentence saying the status was unknown — which is
 *               exactly the sentence the engine produces for a genuine data gap. A wrong answer
 *               wearing the costume of a correct one.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-08-24
 */
@IsTest
private class EichrechtBerechtigungTest {

    /**
     * A user with the permission set and nothing else. Minimum Access is deliberate: a profile that
     * already grants half the org would hide exactly what this class is here to find.
     */
    private static User eingeschraenkterNutzer() {
        Profile minimal = [
            SELECT Id FROM Profile
            WHERE Name IN ('Minimum Access - Salesforce', 'Standard User')
            ORDER BY Name LIMIT 1
        ];
        User u = new User(
            Alias = 'eichpr',
            Email = 'eichrecht.rechte@voltstream.invalid',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Eichrecht',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'de_DE',
            TimeZoneSidKey = 'Europe/Berlin',
            ProfileId = minimal.Id,
            UserName = 'eichrecht.rechte.' + DateTime.now().getTime() + '@voltstream.invalid'
        );
        // User and PermissionSetAssignment are setup objects; the charge point and its operator
        // are not, and Salesforce refuses both in one transaction. Running the setup DML as the
        // current user is the platform's own escape hatch for exactly this.
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert u;
            insert new PermissionSetAssignment(
                AssigneeId = u.Id,
                PermissionSetId = [SELECT Id FROM PermissionSet
                                   WHERE Name = 'VoltStream_Eichrecht_Access' LIMIT 1].Id
            );
        }
        return u;
    }

    private static Ladepunkt__c abgelaufenerLadepunkt() {
        Account betreiber = TestDataFactory.buildBetreiber('Stadtwerke Musterstadt GmbH');
        insert betreiber;
        Ladepunkt__c lp = TestDataFactory.buildLadepunkt(
            'Rechteprobe', Date.newInstance(Date.today().year() - 10, 3, 1));
        lp.Betreiber__c = betreiber.Id;
        insert lp;
        return [SELECT Id, Name FROM Ladepunkt__c WHERE Id = :lp.Id LIMIT 1];
    }

    @IsTest
    static void dieAktionAntwortetAuchFuerEinenEingeschraenktenNutzer() {
        User nutzer = eingeschraenkterNutzer();
        Ladepunkt__c lp = abgelaufenerLadepunkt();

        PruefeEichfristen.Antwort antwort;
        Test.startTest();
        System.runAs(nutzer) {
            PruefeEichfristen.Anfrage a = new PruefeEichfristen.Anfrage();
            a.ladepunktNummer = lp.Name;
            antwort = PruefeEichfristen.pruefe(new List<PruefeEichfristen.Anfrage>{a})[0];
        }
        Test.stopTest();

        // The exact regression. A missing grant made this return "no charge point found", which the
        // agent then narrated as "the status could not be determined" - indistinguishable, to a
        // reader, from the engine's answer for a genuine data gap.
        System.assertEquals(1, antwort.anzahlGeprueft,
            'Der eingeschraenkte Nutzer muss den Ladepunkt finden. Hinweis: ' + antwort.hinweis);
        System.assertEquals(null, antwort.hinweis,
            'Ein Berechtigungsproblem darf sich nicht als "nicht gefunden" tarnen.');
        System.assert(antwort.zusammenfassung.contains('abgelaufener Eichfrist'),
            'Und die Antwort muss die richtige sein, nicht nur irgendeine: '
            + antwort.zusammenfassung);
        System.assert(String.isNotBlank(antwort.rechtsgrundlagen),
            'Ohne Rechtsgrundlagen waere die Antwort fuer das Transkript-Gate unpruefbar.');
    }

    @IsTest
    static void dieBestandsabfrageKommtOhneJedenAccountZugriffAus() {
        User nutzer = eingeschraenkterNutzer();
        abgelaufenerLadepunkt();

        PruefeEichfristen.Antwort antwort;
        Test.startTest();
        System.runAs(nutzer) {
            PruefeEichfristen.Anfrage a = new PruefeEichfristen.Anfrage();
            a.betreiber = 'Musterstadt';
            antwort = PruefeEichfristen.pruefe(new List<PruefeEichfristen.Anfrage>{a})[0];
        }
        Test.stopTest();

        // This path filters on a denormalised formula rather than traversing the relationship,
        // so it needs no permission on Account at all. The first attempt did traverse it and this
        // test refused to pass - a restricted user cannot even resolve Betreiber__r. Granting the
        // service user an entire standard object to answer a question about charge points was the
        // wrong fix; a cross-object formula, evaluated in system context, is the right one.
        System.assertEquals(1, antwort.anzahlGeprueft,
            'Die Bestandsabfrage muss ohne jeden Account-Zugriff funktionieren. Hinweis: '
            + antwort.hinweis);
    }

    @IsTest
    static void dieKarteLaedtAuchOhneAdministratorrechte() {
        User nutzer = eingeschraenkterNutzer();
        Ladepunkt__c lp = abgelaufenerLadepunkt();

        EichrechtCardController.Ansicht sicht;
        Test.startTest();
        System.runAs(nutzer) {
            sicht = EichrechtCardController.ladeEichrecht(lp.Id);
        }
        Test.stopTest();

        System.assertEquals('ABGELAUFEN', sicht.status,
            'Die Karte sitzt auf einer Datensatzseite, die jeder Sachbearbeiter oeffnet - sie darf '
            + 'nicht nur fuer Administratoren funktionieren.');
        System.assert(!sicht.rechtsgrundlagen.isEmpty(),
            'Und der Normenkorpus ist Metadaten: getInstance umgeht CRUD, aber das Berechtigungsset '
            + 'erteilt den Zugriff trotzdem, damit die Absicht dokumentiert ist.');
        System.assert(String.isNotBlank(sicht.rechtsgrundlagen[0].wortlaut),
            'Der amtliche Wortlaut kommt mit.');
    }

    @IsTest
    static void ohneDasBerechtigungssetKommtKeineAntwortStattEinerFalschen() {
        // The negative control. Without the permission set the platform must refuse rather than
        // return a partial answer - a check that only ever passes proves nothing, and the same
        // applies to a permission set that is never absent in any test.
        Profile minimal = [
            SELECT Id FROM Profile
            WHERE Name IN ('Minimum Access - Salesforce', 'Standard User')
            ORDER BY Name LIMIT 1
        ];
        User ohne = new User(
            Alias = 'ohneps', Email = 'ohne.rechte@voltstream.invalid',
            EmailEncodingKey = 'UTF-8', LastName = 'OhneRechte', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'de_DE', TimeZoneSidKey = 'Europe/Berlin', ProfileId = minimal.Id,
            UserName = 'ohne.rechte.' + DateTime.now().getTime() + '@voltstream.invalid');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert ohne;
        }
        Ladepunkt__c lp = abgelaufenerLadepunkt();

        Boolean verweigert = false;
        Test.startTest();
        System.runAs(ohne) {
            try {
                List<Ladepunkt__c> gefunden = LadepunktSelector.byName(lp.Name);
                verweigert = gefunden.isEmpty();
            } catch (Exception e) {
                // Either shape is correct: WITH USER_MODE may throw or may return nothing. What
                // matters is that it does not hand data to a user who was never granted it.
                verweigert = true;
            }
        }
        Test.stopTest();

        System.assert(verweigert,
            'Ohne Berechtigungsset darf der Selector keine Ladepunkte herausgeben.');
    }
}
