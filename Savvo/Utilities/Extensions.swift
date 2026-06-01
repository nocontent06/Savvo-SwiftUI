import SwiftUI

// MARK: - Color from Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Number Formatting

extension Double {
    /// Formats as Euro currency: e.g. €1.234,56
    var euroFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.locale = Locale(identifier: "de_DE")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "€0,00"
    }

    /// Compact Euro format without fractional part if zero: e.g. €1.234
    var euroFormattedCompact: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.locale = Locale(identifier: "de_DE")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "€0"
    }
}

// MARK: - Date Formatting

extension Date {
    /// German date format: DD.MM.YYYY
    var germanFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: self)
    }

    /// Short German date format: DD.MM.
    var germanFormattedShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: self)
    }
}

// MARK: - String Helpers

extension String {
    /// Parse a user-entered decimal string (accepts both comma and dot as decimal separator)
    var asDouble: Double? {
        let normalized = self.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
}
