//
//  AmountFormatter.swift
//  AlinaTest
//
//  Formats a raw digit string into a locale-aware currency display string.
//
//  Raw input always uses "." as the internal decimal separator regardless
//  of locale. The formatter converts this to the locale separator on output
//  and adds the locale currency symbol and grouping separators.
//
//  Examples (en_US locale):
//    ""        → "$0"
//    "2000"    → "$2,000"
//    "2000.5"  → "$2,000.5"
//    "2000.50" → "$2,000.50"
//

import Foundation

enum AmountFormatter {

    // MARK: - Private

    private static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale.current
        f.usesGroupingSeparator = true
        f.maximumFractionDigits = 0
        return f
    }()

    // MARK: - Public Tokens

    /// Locale currency symbol (e.g. "$", "€", "£").
    static var currencySymbol: String {
        Locale.current.currencySymbol ?? "$"
    }

    /// Locale decimal separator (e.g. "." in en_US, "," in de_DE).
    static var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    // MARK: - Format

    /// Converts a raw digit string to a displayable currency string.
    static func format(_ raw: String) -> String {
        guard !raw.isEmpty else {
            return currencySymbol + "0"
        }

        let parts = raw.components(separatedBy: ".")
        let wholeStr = parts[0].isEmpty ? "0" : parts[0]

        let formattedWhole: String
        if let num = Double(wholeStr),
           let s = numberFormatter.string(from: NSNumber(value: num)) {
            formattedWhole = s
        } else {
            formattedWhole = wholeStr
        }

        if parts.count > 1 {
            return currencySymbol + formattedWhole + decimalSeparator + parts[1]
        } else {
            return currencySymbol + formattedWhole
        }
    }
}
