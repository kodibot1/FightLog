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
        ("Overhand", .punch),

        // Kicks
        ("Roundhouse", .kick),
        ("Teep", .kick),
        ("Low Kick", .kick),
        ("Body Kick", .kick),
        ("Head Kick", .kick),
        ("Switch Kick", .kick),
        ("Question Mark Kick", .kick),

        // Elbows
        ("Horizontal Elbow", .elbow),
        ("Uppercut Elbow", .elbow),
        ("Spinning Elbow", .elbow),
        ("Downward Elbow", .elbow),
        ("Diagonal Elbow", .elbow),

        // Knees
        ("Straight Knee", .knee),
        ("Curved Knee", .knee),
        ("Flying Knee", .knee),
        ("Clinch Knee", .knee),

        // Clinch
        ("Collar Tie", .clinch),
        ("Double Collar Tie", .clinch),
        ("Underhook", .clinch),
        ("Body Lock", .clinch),

        // Footwork
        ("Pivot", .footwork),
        ("Angle Out", .footwork),
        ("Cut Angle", .footwork),
        ("In-Out Movement", .footwork),
        ("Lateral Movement", .footwork),

        // Defense
        ("Parry", .defense),
        ("Slip", .defense),
        ("Roll", .defense),
        ("Check", .defense),
        ("Block", .defense),
        ("Catch", .defense),
        ("Pull Back", .defense),

        // Combinations
        ("1-2", .combination),
        ("1-2-3", .combination),
        ("1-2-3-2", .combination),
        ("Jab-Low Kick", .combination),
        ("Jab-Body Kick", .combination),
        ("1-2 Low Kick", .combination),
        ("Hook-Low Kick", .combination),
        ("Teep-Cross", .combination),
        ("Dutch Combo", .combination)
    ]

    static func createDefaultTechniques() -> [Technique] {
        all.map { Technique(name: $0.name, category: $0.category) }
    }
}
