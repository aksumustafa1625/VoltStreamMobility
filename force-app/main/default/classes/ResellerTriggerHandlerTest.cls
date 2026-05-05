/**
 * @description  Integration tests for ResellerTrigger + ResellerTriggerHandler.
 *               Tests fire DML on Reseller__c to exercise the full
 *               Trigger -> Handler -> Helper chain end-to-end in real org
 *               transactions. Complements ResellerTriggerHelperTest, which
 *               exercises the algorithm in isolation without DML.
 *
 *               These tests prove:
 *                 1. The trigger actually fires on insert and update.
 *                 2. The Handler correctly delegates to the Helper.
 *                 3. The Helper's normalization sticks in the database.
 *                 4. The Kevin O'Hara framework's bypass API works.
 *
 *               Coverage target: 100%.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
@IsTest
private class ResellerTriggerHandlerTest {

    // Insert with mixed-case email -> stored lowercase (External ID match-safe).
    @IsTest
    static void insert_mixedCaseEmail_storedLowercase() {
        Reseller__c r = TestDataFactory.buildReseller(
            'Berlin Elektrotechnik', 'KONTAKT@BERLIN-ELEKTRO.DE', 'Electrical Contractor'
        );

        Test.startTest();
        insert r;
        Test.stopTest();

        Reseller__c stored = [SELECT Company_Email__c FROM Reseller__c WHERE Id = :r.Id];
        System.assertEquals('kontakt@berlin-elektro.de', stored.Company_Email__c,
            'Trigger must lowercase the email before insert reaches the database.');
    }

    // Insert with raw 10-digit phone -> stored in canonical (NNN) NNN NN-NN format.
    @IsTest
    static void insert_rawPhone_storedFormatted() {
        Reseller__c r = TestDataFactory.buildReseller(
            'Hotel X', 'hotel@x.de', 'Hotel Chain'
        );
        r.Phone__c = '1231231212';

        Test.startTest();
        insert r;
        Test.stopTest();

        Reseller__c stored = [SELECT Phone__c FROM Reseller__c WHERE Id = :r.Id];
        System.assertEquals('(123) 123 12-12', stored.Phone__c,
            'Trigger must format the phone before insert reaches the database.');
    }

    // Insert with extra-spaced name -> stored single-spaced.
    @IsTest
    static void insert_messyName_storedTrimmed() {
        Reseller__c r = TestDataFactory.buildReseller(
            '  Acme   GmbH ', 'acme@x.de', 'Hotel Chain'
        );

        Test.startTest();
        insert r;
        Test.stopTest();

        Reseller__c stored = [SELECT Name FROM Reseller__c WHERE Id = :r.Id];
        System.assertEquals('Acme GmbH', stored.Name,
            'Trigger must trim and collapse name whitespace before insert.');
    }

    // Update with new mixed-case email -> stored lowercase.
    @IsTest
    static void update_emailChangeMixedCase_storedLowercase() {
        Reseller__c r = TestDataFactory.buildReseller(
            'Hotel Y', 'old@y.de', 'Hotel Chain'
        );
        insert r;

        r.Company_Email__c = 'NEW@Y.DE';

        Test.startTest();
        update r;
        Test.stopTest();

        Reseller__c stored = [SELECT Company_Email__c FROM Reseller__c WHERE Id = :r.Id];
        System.assertEquals('new@y.de', stored.Company_Email__c,
            'Trigger must re-normalize on update, not just on insert.');
    }

    // End-to-end proof: stored normalized email matches what the Selector queries.
    // This is the original problem statement from the README — Reseller stored
    // mixed-case would silently fail to match. After this trigger lands, that
    // failure mode is impossible.
    @IsTest
    static void insert_mixedCaseEmail_selectorCanMatchByNormalizedQuery() {
        Reseller__c r = TestDataFactory.buildReseller(
            'Mixed Case Hotel', 'PARTNER@MIXED.DE', 'Hotel Chain'
        );
        insert r;

        Set<String> normalizedEmails = new Set<String>{ 'partner@mixed.de' };
        List<Reseller__c> matches = ResellerSelector.findActiveByEmails(normalizedEmails);

        System.assertEquals(1, matches.size(),
            'Selector lookup with the normalized email must find the reseller, '
            + 'proving the trigger closed the External ID case-sensitivity loophole.');
    }

    // Bulk insert (200 records) -> all normalized, no governor limit issues.
    @IsTest
    static void insert_bulk200_allNormalized() {
        List<Reseller__c> resellers = new List<Reseller__c>();
        for (Integer i = 0; i < 200; i++) {
            Reseller__c r = TestDataFactory.buildReseller(
                'Bulk  ' + i,           // double space in name
                'BULK' + i + '@X.DE',   // uppercase email
                'Hotel Chain'
            );
            r.Phone__c = '1231231212';
            resellers.add(r);
        }

        Test.startTest();
        insert resellers;
        Test.stopTest();

        List<Reseller__c> stored = [
            SELECT Name, Company_Email__c, Phone__c FROM Reseller__c WHERE Id IN :resellers
        ];
        System.assertEquals(200, stored.size(), 'All 200 resellers should insert.');
        for (Reseller__c r : stored) {
            System.assertEquals(r.Company_Email__c.toLowerCase(), r.Company_Email__c,
                'Every bulk email must be stored lowercase.');
            System.assertEquals('(123) 123 12-12', r.Phone__c,
                'Every bulk phone must be stored in the canonical format.');
        }
    }

    // Bypass API: when active, the trigger is skipped and data is stored raw.
    // Proves the Kevin O'Hara framework's bypass mechanism is wired up.
    @IsTest
    static void bypass_handlerSkipped_dataNotNormalized() {
        TriggerHandler.bypass('ResellerTriggerHandler');

        Reseller__c r = TestDataFactory.buildReseller(
            'Bypassed', 'BYPASS@X.DE', 'Hotel Chain'
        );

        Test.startTest();
        insert r;
        Test.stopTest();

        Reseller__c stored = [SELECT Company_Email__c FROM Reseller__c WHERE Id = :r.Id];
        System.assertEquals('BYPASS@X.DE', stored.Company_Email__c,
            'When the handler is bypassed, no normalization should run.');

        TriggerHandler.clearBypass('ResellerTriggerHandler');
    }
}
