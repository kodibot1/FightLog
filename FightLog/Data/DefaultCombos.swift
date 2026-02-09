import Foundation

struct DefaultCombos {
    static let all: [(numbers: String, name: String?, notes: String?)] = [
        // Basic Boxing Combos
        ("1-2", "Basic One-Two", "Jab followed by cross. Foundation of boxing."),
        ("1-1-2", "Double Jab Cross", "Two jabs to set up the cross"),
        ("1-2-3", "Jab Cross Hook", "Classic three-punch combo"),
        ("1-2-3-2", nil, "Jab, cross, hook, cross - keep hands up after hook"),
        ("1-2-5-2", nil, "Jab, cross, lead uppercut, cross"),
        ("1-2-1-2", nil, "Double one-two combination"),
        ("3-2", "Check Hook Cross", "Lead with hook, follow with cross"),
        ("3-2-3", nil, "Hook, cross, hook - stay in the pocket"),
        ("2-3-2", nil, "Cross, hook, cross - counter combination"),
        ("5-2-3", nil, "Lead uppercut, cross, hook"),
        ("6-3-2", nil, "Rear uppercut, lead hook, cross"),
        ("1-6-3-2", nil, "Jab, rear uppercut, hook, cross"),

        // Body Work
        ("1-2-1b-2", nil, "Jab high, cross high, body jab, cross"),
        ("1-2b-3-2", nil, "Jab, body cross, hook, cross"),
        ("7-8-3-2", nil, "Body hooks followed by head shots"),
        ("1-2-7-8", nil, "Head shots to body hooks"),

        // Longer Combinations
        ("1-2-3-4-5-6", "Six Count", "Full combination hitting all angles"),
        ("1-2-3-2-1-2", nil, "Flow combo - great for bag work"),
        ("1-1-2-3-2", nil, "Double jab into three piece"),

        // Muay Thai / Kickboxing Combos
        ("1-2-LK", nil, "Jab, cross, low kick - Dutch style"),
        ("1-2-3-LK", nil, "Jab, cross, hook, low kick"),
        ("1-2-T", nil, "Jab, cross, teep - create distance"),
        ("LK-2-3", nil, "Low kick to set up punches"),
        ("1-2-RH", nil, "Jab, cross, roundhouse kick"),
        ("T-1-2", "Teep Entry", "Teep to close distance, follow with hands"),

        // Counter Combinations
        ("2-3-2", "Counter Cross", "Slip and counter with cross, hook, cross"),
        ("3-2-LK", nil, "Check hook, cross, low kick"),

        // Coach Favorites
        ("1-2-3-2-1", nil, "Five count - ends with jab to reset"),
        ("1-2-5-6-3-2", nil, "Uppercuts in the middle, finish with hook cross"),
        ("1-1-2-LK-2-3", nil, "Long combination with kick in middle")
    ]

    static func createDefaultCombos() -> [Combo] {
        all.map { Combo(numbers: $0.numbers, name: $0.name, notes: $0.notes, isCustom: false) }
    }
}
