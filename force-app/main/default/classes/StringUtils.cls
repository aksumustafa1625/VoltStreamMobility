/**
 * @description  Stateless string normalization utilities. Single source of
 *               truth for email casing, phone formatting, and whitespace
 *               cleanup. Every public method is null-safe (blank in -> null
 *               out, never throws).
 *
 * @group        VoltStream Channel Partner Management
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
public with sharing class StringUtils {

    /**
     * @description  Trim and lowercase an email for case-insensitive comparison.
     * @param  email  Raw email; may be null, blank, padded, or in any case.
     * @return  Lowercase trimmed email, or null when input is blank.
     */
    public static String normalizeEmail(String email) {
        // Null-safe contract: blank in -> null out, never throw.
        if (String.isBlank(email)) {
            return null;
        }
        return email.trim().toLowerCase();
    }

    /**
     * @description  Format a phone number into the project canonical format.
     *               10 digits -> '(NNN) NNN NN-NN'. Leading '+' kept with
     *               country code: '+CC (NNN) NNN NN-NN' for 12-digit input.
     *               Other lengths return cleaned digits (with '+' if any).
     * @param  phone  Raw phone input — may include parens, dashes, spaces.
     * @return  Formatted phone, or null when input is blank or has no digits.
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
     * @description  Trim and collapse all internal whitespace to single spaces.
     * @param  s  Raw string; may be null or have inconsistent whitespace.
     * @return  Cleaned string, or null when input is blank.
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
