/**
 * @description  Unit tests for StringUtils. Pure static method tests — no
 *               DML, no SOQL, no Limits-bound operations. Every branch of
 *               every public method is exercised, including null / empty /
 *               whitespace-only edge cases that the null-safe contract
 *               promises to handle.
 *
 *               Coverage target: 100%. Because StringUtils has no external
 *               dependencies, the test suite runs in milliseconds and is
 *               cheap to expand whenever a new normalization rule is added.
 *
 * @group        VoltStream Channel Partner Management — Tests
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
@IsTest
private class StringUtilsTest {

    // ==========================================================
    // normalizeEmail — happy path
    // ==========================================================

    // Trim + lowercase on a typical messy input.
    @IsTest
    static void normalizeEmail_messyInput_trimmedAndLowered() {
        System.assertEquals('partner@hotel.de',
            StringUtils.normalizeEmail('  PARTNER@HOTEL.DE  '),
            'Email should be trimmed and lowercased.');
    }

    // Already-clean input must be returned unchanged.
    @IsTest
    static void normalizeEmail_alreadyClean_unchanged() {
        System.assertEquals('a@b.com',
            StringUtils.normalizeEmail('a@b.com'),
            'Already-normalized email should pass through unchanged.');
    }

    // Mixed case, no whitespace.
    @IsTest
    static void normalizeEmail_mixedCase_lowercased() {
        System.assertEquals('mixed.case@example.de',
            StringUtils.normalizeEmail('Mixed.Case@Example.de'));
    }

    // ==========================================================
    // normalizeEmail — null-safe contract
    // ==========================================================

    // Null in -> null out (no NPE).
    @IsTest
    static void normalizeEmail_null_returnsNull() {
        System.assertEquals(null, StringUtils.normalizeEmail(null));
    }

    // Empty string in -> null out.
    @IsTest
    static void normalizeEmail_empty_returnsNull() {
        System.assertEquals(null, StringUtils.normalizeEmail(''));
    }

    // Whitespace-only input -> null out (treat as blank).
    @IsTest
    static void normalizeEmail_whitespaceOnly_returnsNull() {
        System.assertEquals(null, StringUtils.normalizeEmail('     '));
    }

    // ==========================================================
    // normalizePhone — formatting
    // ==========================================================

    // 10 digits with no symbols -> standard project format.
    @IsTest
    static void normalizePhone_tenDigits_formatted() {
        System.assertEquals('(234) 567 89-01',
            StringUtils.normalizePhone('2345678901'));
    }

    // Messy input with parens / dashes / spaces -> stripped and formatted.
    @IsTest
    static void normalizePhone_messyTenDigits_formatted() {
        System.assertEquals('(234) 567 89-01',
            StringUtils.normalizePhone('(234) 567-8901'));
    }

    // International notation: '+' + country code + 10-digit local.
    @IsTest
    static void normalizePhone_internationalGerman_formatted() {
        System.assertEquals('+49 (301) 234 56-78',
            StringUtils.normalizePhone('+49 3012345678'));
    }

    // International with messy separators -> still formatted cleanly.
    @IsTest
    static void normalizePhone_internationalMessy_formatted() {
        System.assertEquals('+49 (301) 234 56-78',
            StringUtils.normalizePhone('+49 30 1234 5678'));
    }

    // ==========================================================
    // normalizePhone — fallback paths
    // ==========================================================

    // Too few digits — return the cleaned digits without spurious formatting.
    @IsTest
    static void normalizePhone_tooFewDigits_returnsCleaned() {
        System.assertEquals('1234567', StringUtils.normalizePhone('123-4567'));
    }

    // Too many digits without '+' — return cleaned digits unmodified.
    @IsTest
    static void normalizePhone_tooManyDigitsNoPlus_returnsCleaned() {
        System.assertEquals('1234567890123',
            StringUtils.normalizePhone('1234567890123'));
    }

    // ==========================================================
    // normalizePhone — null-safe contract
    // ==========================================================

    @IsTest
    static void normalizePhone_null_returnsNull() {
        System.assertEquals(null, StringUtils.normalizePhone(null));
    }

    @IsTest
    static void normalizePhone_empty_returnsNull() {
        System.assertEquals(null, StringUtils.normalizePhone(''));
    }

    // Symbols-only input has no digits to keep -> null out.
    @IsTest
    static void normalizePhone_symbolsOnly_returnsNull() {
        System.assertEquals(null, StringUtils.normalizePhone('()-+ '));
    }

    // ==========================================================
    // normalizeWhitespace
    // ==========================================================

    // Multiple spaces and surrounding whitespace -> single internal spaces, trimmed.
    @IsTest
    static void normalizeWhitespace_multipleSpaces_collapsed() {
        System.assertEquals('Hello World',
            StringUtils.normalizeWhitespace('  Hello    World  '));
    }

    // Tabs and newlines also count as whitespace -> collapsed.
    @IsTest
    static void normalizeWhitespace_tabsAndNewlines_collapsed() {
        System.assertEquals('Foo Bar Baz',
            StringUtils.normalizeWhitespace('Foo\t\nBar  Baz'));
    }

    // Already-clean input passes through unchanged.
    @IsTest
    static void normalizeWhitespace_alreadyClean_unchanged() {
        System.assertEquals('Clean text',
            StringUtils.normalizeWhitespace('Clean text'));
    }

    @IsTest
    static void normalizeWhitespace_null_returnsNull() {
        System.assertEquals(null, StringUtils.normalizeWhitespace(null));
    }

    @IsTest
    static void normalizeWhitespace_empty_returnsNull() {
        System.assertEquals(null, StringUtils.normalizeWhitespace(''));
    }
}
