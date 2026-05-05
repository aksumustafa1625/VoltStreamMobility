/**
 * @description  Unit tests for ResellerTriggerHelper. Calls the static method
 *               directly with in-memory Reseller records — no DML, no trigger
 *               fire.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
@IsTest
private class ResellerTriggerHelperTest {

    // Mixed-case email -> lowercase storage (guarantees External ID IN matches).
    @IsTest
    static void normalizeFields_mixedCaseEmail_lowercased() {
        Reseller__c r = TestDataFactory.buildReseller(
            'X', 'Partner@Hotel.DE', 'Hotel Chain'
        );

        ResellerTriggerHelper.normalizeFields(new List<Reseller__c>{ r });

        System.assertEquals('partner@hotel.de', r.Company_Email__c,
            'Email must be lowercased so External ID IN-clause lookups can match.');
    }

    // Email with surrounding whitespace -> trimmed.
    @IsTest
    static void normalizeFields_paddedEmail_trimmed() {
        Reseller__c r = TestDataFactory.buildReseller(
            'X', '  partner@hotel.de  ', 'Hotel Chain'
        );

        ResellerTriggerHelper.normalizeFields(new List<Reseller__c>{ r });

        System.assertEquals('partner@hotel.de', r.Company_Email__c,
            'Trim surrounding whitespace as part of email normalization.');
    }

    // 10-digit phone (typed bare) -> '(NNN) NNN NN-NN' canonical format.
    @IsTest
    static void normalizeFields_tenDigitPhone_formatted() {
        Reseller__c r = TestDataFactory.buildReseller(
            'X', 'a@b.de', 'Hotel Chain'
        );
        r.Phone__c = '1231231212';

        ResellerTriggerHelper.normalizeFields(new List<Reseller__c>{ r });

        System.assertEquals('(123) 123 12-12', r.Phone__c,
            'Phone should be formatted into the project canonical format.');
    }

    // International phone with country code -> formatted with '+CC' prefix.
    @IsTest
    static void normalizeFields_internationalPhone_formatted() {
        Reseller__c r = TestDataFactory.buildReseller(
            'X', 'a@b.de', 'Hotel Chain'
        );
        r.Phone__c = '+49 30 1234 5678';

        ResellerTriggerHelper.normalizeFields(new List<Reseller__c>{ r });

        System.assertEquals('+49 (301) 234 56-78', r.Phone__c,
            'International phones must keep their country code and format the local part.');
    }

    // Null phone -> stays null (Phone is optional on Reseller).
    @IsTest
    static void normalizeFields_nullPhone_staysNull() {
        Reseller__c r = TestDataFactory.buildReseller(
            'X', 'a@b.de', 'Hotel Chain'
        );
        r.Phone__c = null;

        ResellerTriggerHelper.normalizeFields(new List<Reseller__c>{ r });

        System.assertEquals(null, r.Phone__c,
            'Null phone must pass through unchanged — Phone is optional.');
    }

    // Name with multiple internal spaces -> single-space tokens.
    @IsTest
    static void normalizeFields_nameWithExtraSpaces_collapsed() {
        Reseller__c r = TestDataFactory.buildReseller(
            'Acme   GmbH', 'a@b.de', 'Hotel Chain'
        );

        ResellerTriggerHelper.normalizeFields(new List<Reseller__c>{ r });

        System.assertEquals('Acme GmbH', r.Name,
            'Multi-space company names must be collapsed to single-space tokens.');
    }

    // Country with surrounding whitespace -> trimmed.
    @IsTest
    static void normalizeFields_paddedCountry_trimmed() {
        Reseller__c r = TestDataFactory.buildReseller(
            'X', 'a@b.de', 'Hotel Chain'
        );
        r.Country__c = '  Germany  ';

        ResellerTriggerHelper.normalizeFields(new List<Reseller__c>{ r });

        System.assertEquals('Germany', r.Country__c,
            'Country padding must be trimmed.');
    }

    // Already-normalized input -> idempotent (no change).
    @IsTest
    static void normalizeFields_alreadyNormalized_unchanged() {
        Reseller__c r = TestDataFactory.buildReseller(
            'Clean GmbH', 'clean@hotel.de', 'Hotel Chain'
        );
        r.Phone__c = '(123) 456 78-90';
        r.Country__c = 'Germany';

        ResellerTriggerHelper.normalizeFields(new List<Reseller__c>{ r });

        System.assertEquals('Clean GmbH',         r.Name);
        System.assertEquals('clean@hotel.de',     r.Company_Email__c);
        System.assertEquals('(123) 456 78-90',    r.Phone__c);
        System.assertEquals('Germany',            r.Country__c);
    }

    // Empty list -> returns cleanly, no exceptions.
    @IsTest
    static void normalizeFields_emptyList_returnsCleanly() {
        List<Reseller__c> empty = new List<Reseller__c>();

        ResellerTriggerHelper.normalizeFields(empty);

        System.assertEquals(0, empty.size(), 'Empty input list must remain empty.');
    }

    // Bulk batch (200 records) -> every record normalized.
    @IsTest
    static void normalizeFields_bulk200_allNormalized() {
        List<Reseller__c> resellers = new List<Reseller__c>();
        for (Integer i = 0; i < 200; i++) {
            Reseller__c r = TestDataFactory.buildReseller(
                'Acme  ' + i + '  GmbH',          // double-space in name
                'PARTNER' + i + '@HOTEL.DE',      // uppercase email
                'Hotel Chain'
            );
            r.Phone__c = '1231231212';
            resellers.add(r);
        }

        ResellerTriggerHelper.normalizeFields(resellers);

        for (Reseller__c r : resellers) {
            System.assert(!r.Name.contains('  '),
                'Bulk input names must have spaces collapsed.');
            System.assertEquals(r.Company_Email__c, r.Company_Email__c.toLowerCase(),
                'Bulk input emails must be lowercased.');
            System.assertEquals('(123) 123 12-12', r.Phone__c,
                'Bulk input phones must be formatted.');
        }
    }
}
