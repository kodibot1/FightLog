import Foundation

struct DefaultTechniques {
    static let all: [(name: String, category: TechniqueCategory)] = [
        // Punches
        ("Jab", .punch),
        ("Cross", .punch),
        ("Hook", .punch),
        ("Uppercut", .punch),
        ("Body Jab", .punch),
        ("Body Hook", .punch),
        ("Body Uppercut", .punch),
        ("Overhand", .punch),
        ("Lead Hook", .punch),
        ("Rear Hook", .punch),

        // Footwork
        ("Pivot", .footwork),
        ("Angle Out", .footwork),
        ("Cut Angle", .footwork),
        ("In-Out Movement", .footwork),
        ("Lateral Movement", .footwork),
        ("Step Jab", .footwork),
        ("L-Step", .footwork),

        // Defense
        ("Parry", .defense),
        ("Slip", .defense),
        ("Roll", .defense),
        ("Block", .defense),
        ("Catch", .defense),
        ("Pull Back", .defense),
        ("Shoulder Roll", .defense),
        ("Duck", .defense),

        // Clinch
        ("Collar Tie", .clinch),
        ("Underhook", .clinch),
        ("Body Lock", .clinch),
    ]

    static func createDefaultTechniques() -> [Technique] {
        all.map { Technique(name: $0.name, category: $0.category) }
    }
}
