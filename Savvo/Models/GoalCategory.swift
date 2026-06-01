import SwiftUI

// MARK: - Goal Category

enum GoalCategory: String, CaseIterable, Identifiable {
    case auto, urlaub, technik, wohnen, bildung, hochzeit, fitness, sonstiges

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .urlaub: return "Urlaub"
        case .technik: return "Technik"
        case .wohnen: return "Wohnen"
        case .bildung: return "Bildung"
        case .hochzeit: return "Hochzeit"
        case .fitness: return "Fitness"
        case .sonstiges: return "Sonstiges"
        }
    }

    var emoji: String {
        switch self {
        case .auto: return "🚗"
        case .urlaub: return "✈️"
        case .technik: return "💻"
        case .wohnen: return "🏠"
        case .bildung: return "🎓"
        case .hochzeit: return "💍"
        case .fitness: return "🏋️"
        case .sonstiges: return "🎯"
        }
    }

    var color: Color {
        switch self {
        case .auto: return Color(hex: "3B82F6")
        case .urlaub: return Color(hex: "F59E0B")
        case .technik: return Color(hex: "8B5CF6")
        case .wohnen: return Color(hex: "10B981")
        case .bildung: return Color(hex: "EC4899")
        case .hochzeit: return Color(hex: "F43F5E")
        case .fitness: return Color(hex: "EF4444")
        case .sonstiges: return Color(hex: "6B7280")
        }
    }

    var description: String {
        switch self {
        case .auto: return "Traumwagen kaufen"
        case .urlaub: return "Reise planen"
        case .technik: return "Gadgets & Geräte"
        case .wohnen: return "Einrichten & kaufen"
        case .bildung: return "Kurse & Studium"
        case .hochzeit: return "Den großen Tag"
        case .fitness: return "Sport & Gesundheit"
        case .sonstiges: return "Eigenes Ziel"
        }
    }

    var defaultName: String {
        switch self {
        case .auto: return "Mein neues Auto"
        case .urlaub: return "Traumurlaub"
        case .technik: return "Neues Gerät"
        case .wohnen: return "Wohnungsprojekt"
        case .bildung: return "Weiterbildung"
        case .hochzeit: return "Hochzeit"
        case .fitness: return "Fitnessprojekt"
        case .sonstiges: return "Mein Sparziel"
        }
    }
}

// MARK: - Car Brands

struct CarBrand: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let color: Color
    let models: [String]
}

let carBrands: [CarBrand] = [
    CarBrand(name: "BMW", emoji: "🔵", color: Color(hex: "1C69D4"), models: ["1er", "2er", "3er", "4er", "5er", "7er", "X1", "X3", "X5", "X7", "M3", "M5", "iX", "i4"]),
    CarBrand(name: "Mercedes", emoji: "⭐️", color: Color(hex: "6B7280"), models: ["A-Klasse", "B-Klasse", "C-Klasse", "E-Klasse", "S-Klasse", "GLA", "GLC", "GLE", "AMG C63", "EQA", "EQC"]),
    CarBrand(name: "Audi", emoji: "⚪️", color: Color(hex: "BB0A14"), models: ["A1", "A3", "A4", "A5", "A6", "A7", "A8", "Q3", "Q5", "Q7", "Q8", "RS3", "RS6", "e-tron"]),
    CarBrand(name: "VW", emoji: "🔷", color: Color(hex: "0D5AA7"), models: ["Polo", "Golf", "Golf GTI", "Passat", "Tiguan", "Touareg", "T-Roc", "ID.3", "ID.4", "ID.7", "Arteon"]),
    CarBrand(name: "Toyota", emoji: "🔴", color: Color(hex: "EB0A1E"), models: ["Yaris", "Corolla", "Camry", "RAV4", "Land Cruiser", "GR86", "Supra", "Highlander", "C-HR", "bZ4X"]),
    CarBrand(name: "Tesla", emoji: "⚡️", color: Color(hex: "CC0000"), models: ["Model 3", "Model Y", "Model S", "Model X", "Cybertruck"]),
    CarBrand(name: "Porsche", emoji: "🏆", color: Color(hex: "A78B2C"), models: ["911", "Cayenne", "Macan", "Panamera", "Taycan", "718 Cayman", "718 Boxster"]),
    CarBrand(name: "Ford", emoji: "🔵", color: Color(hex: "003478"), models: ["Fiesta", "Focus", "Puma", "Kuga", "Mustang", "Mustang Mach-E", "Explorer", "F-150"]),
    CarBrand(name: "Opel", emoji: "🟡", color: Color(hex: "F5C518"), models: ["Corsa", "Astra", "Mokka", "Grandland", "Insignia", "Crossland", "Rocks-e"]),
    CarBrand(name: "Skoda", emoji: "🟢", color: Color(hex: "4BA82E"), models: ["Fabia", "Scala", "Octavia", "Superb", "Kamiq", "Karoq", "Kodiaq", "Enyaq"]),
    CarBrand(name: "Hyundai", emoji: "🔵", color: Color(hex: "002C5F"), models: ["i10", "i20", "i30", "Tucson", "Santa Fe", "Kona", "IONIQ 5", "IONIQ 6"]),
    CarBrand(name: "Kia", emoji: "🔴", color: Color(hex: "BF0000"), models: ["Picanto", "Rio", "Ceed", "Sportage", "Sorento", "EV6", "Niro"]),
    CarBrand(name: "Andere", emoji: "🚗", color: Color(hex: "6B7280"), models: []),
]

// MARK: - Vacation Countries

struct VacationCountry: Identifiable {
    let id = UUID()
    let flag: String
    let name: String
}

let vacationCountries: [VacationCountry] = [
    VacationCountry(flag: "🇪🇸", name: "Spanien"),
    VacationCountry(flag: "🇮🇹", name: "Italien"),
    VacationCountry(flag: "🇫🇷", name: "Frankreich"),
    VacationCountry(flag: "🇬🇷", name: "Griechenland"),
    VacationCountry(flag: "🇹🇷", name: "Türkei"),
    VacationCountry(flag: "🇵🇹", name: "Portugal"),
    VacationCountry(flag: "🇺🇸", name: "USA"),
    VacationCountry(flag: "🇯🇵", name: "Japan"),
    VacationCountry(flag: "🇹🇭", name: "Thailand"),
    VacationCountry(flag: "🇲🇦", name: "Marokko"),
    VacationCountry(flag: "🇦🇹", name: "Österreich"),
    VacationCountry(flag: "🇨🇭", name: "Schweiz"),
    VacationCountry(flag: "🇲🇻", name: "Malediven"),
    VacationCountry(flag: "🇲🇽", name: "Mexiko"),
    VacationCountry(flag: "🇧🇷", name: "Brasilien"),
    VacationCountry(flag: "🇦🇺", name: "Australien"),
    VacationCountry(flag: "🇨🇺", name: "Kuba"),
    VacationCountry(flag: "🇮🇩", name: "Bali / Indonesien"),
    VacationCountry(flag: "🇮🇳", name: "Indien"),
    VacationCountry(flag: "🇨🇦", name: "Kanada"),
    VacationCountry(flag: "🇳🇴", name: "Norwegen"),
    VacationCountry(flag: "🇮🇸", name: "Island"),
    VacationCountry(flag: "🇦🇪", name: "Dubai / VAE"),
    VacationCountry(flag: "🇿🇦", name: "Südafrika"),
    VacationCountry(flag: "🇳🇿", name: "Neuseeland"),
    VacationCountry(flag: "🇵🇪", name: "Peru"),
    VacationCountry(flag: "🏳️", name: "Anderes Land"),
]
