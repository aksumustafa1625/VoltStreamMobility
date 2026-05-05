/**
 * @description  Stateless string normalization utilities used across the
 *               VoltStream codebase. Pure static methods — every public
 *               method is null-safe (blank input returns null, never throws).
 *
 *               Single source of truth for:
 *                 - Email casing and whitespace cleanup (used by
 *                   OpportunityTriggerHelper for case-insensitive matching).
 *                 - Phone number formatting (consistent display format
 *                   across the org regardless of how users typed the input).
 *                 - General whitespace normalization (trim + collapse
 *                   internal multi-spaces).
 *
 *               When normalization rules change, they change in one place —
 *               not scattered across triggers, helpers, batches, and tests.
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class StringUtils {

    /**
     * @description  Normalize an email for storage and case-insensitive
     *               comparison: trim leading/trailing whitespace and
     *               lowercase the whole string. RFC-strict local-part case
     *               sensitivity is intentionally ignored — almost every mail
     *               server folds case in practice, and case-insensitive
     *               matching is what business users expect.
     *
     * @param  email  Raw email input. May be null, blank, padded with
     *                whitespace, or in any case.
     * @return  Lowercase, trimmed email. Returns null when input is blank
     *          (null, empty, or whitespace-only) so callers can use
     *          `if (normalized != null)` as a single-check guard.
     */
    public static String normalizeEmail(String email) {
        // Null-safe contract: blank in -> null out, never throw.
        if (String.isBlank(email)) {
            return null;
        }
        return email.trim().toLowerCase();
    }

    /**
     * @description  Normalize a phone number to the project's display format.
     *               Strips every character that is not a digit or a leading
     *               '+', then groups the digits.
     *
     *               Format rules:
     *                 - 10 digits          -> '(NNN) NNN NN-NN'
     *                 - Leading '+' kept  -> '+CC (NNN) NNN NN-NN' when the
     *                                         remainder is exactly 10 digits.
     *                 - Anything else      -> return cleaned digits (with '+'
     *                                         preserved if input had one) so
     *                                         we never silently lose data.
     *
     * @param  phone  Raw phone input — may include parentheses, dashes,
     *                spaces, '+', country code, etc.
     * @return  Formatted phone string, or null when input is blank or has
     *          no digits at all.
     */
    public static String normalizePhone(String phone) {
        // Null-safe contract.
        if (String.isBlank(phone)) {
            return null;
        }

        // Detect international notation BEFORE stripping symbols.
        Boolean hasPlus = phone.trim().startsWith('+');

        // Strip every non-digit character to get the bare number.
        String digits = phone.replaceAll('[^0-9]', '');
        if (digits.length() == 0) {
            // Input was symbols only — nothing meaningful to keep.
            return null;
        }

        // International format: '+' + country code + 10 local digits.
        if (hasPlus && digits.length() > 10) {
            String countryCode = digits.substring(0, digits.length() - 10);
            String local = digits.substring(digits.length() - 10);
            return '+' + countryCode + ' '
                 + '(' + local.substring(0, 3) + ') '
                 + local.substring(3, 6) + ' '
                 + local.substring(6, 8) + '-'
                 + local.substring(8, 10);
        }

        // Plain 10-digit national number.
        if (digits.length() == 10) {
            return '(' + digits.substring(0, 3) + ') '
                 + digits.substring(3, 6) + ' '
                 + digits.substring(6, 8) + '-'
                 + digits.substring(8, 10);
        }

        // Fallback: too short or odd length — return cleaned digits with '+' if any.
        return (hasPlus ? '+' : '') + digits;
    }

    /**
     * @description  Trim leading/trailing whitespace and collapse any internal
     *               run of whitespace (spaces, tabs, newlines) down to a
     *               single space. Useful for free-text fields like company
     *               names, addresses, or descriptions where users may
     *               accidentally double-space or paste content with tabs.
     *
     * @param  s  Raw string. May be null, empty, or contain inconsistent
     *            whitespace.
     * @return  Cleaned string with single spaces between tokens. Returns
     *          null when input is blank.
     */
    public static String normalizeWhitespace(String s) {
        // Null-safe contract.
        if (String.isBlank(s)) {
            return null;
        }
        // \s+ matches any whitespace run (space, tab, newline, etc.).
        return s.trim().replaceAll('\\s+', ' ');
    }
}
