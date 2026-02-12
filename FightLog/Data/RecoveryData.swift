import SwiftUI

// MARK: - Body Area

enum BodyArea: String, CaseIterable, Identifiable {
    case shoulders = "Shoulders"
    case wristsHands = "Hands & Wrists"
    case neckUpperBack = "Neck & Upper Back"
    case lowerBack = "Lower Back"
    case hipsLegs = "Hips & Legs"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .shoulders: return "figure.arms.open"
        case .wristsHands: return "hand.raised.fill"
        case .neckUpperBack: return "figure.stand"
        case .lowerBack: return "figure.core.training"
        case .hipsLegs: return "figure.run"
        }
    }

    var color: Color {
        switch self {
        case .shoulders: return .orange
        case .wristsHands: return .blue
        case .neckUpperBack: return .purple
        case .lowerBack: return .red
        case .hipsLegs: return .green
        }
    }

    var commonPains: String {
        switch self {
        case .shoulders:
            return "Sore deltoids from extended guard, fatigued rotator cuffs from hooks and uppercuts"
        case .wristsHands:
            return "Sore knuckles and wrist strain from impact, forearm tightness from gripping"
        case .neckUpperBack:
            return "Stiff traps from hunched guard, tight neck from head movement and slips"
        case .lowerBack:
            return "Tightness from rotation and bending, fatigue from generating power in punches"
        case .hipsLegs:
            return "Tight hip flexors from stance, sore calves and quads from footwork and bouncing"
        }
    }
}

// MARK: - Stretch Exercise

struct StretchExercise: Identifiable {
    let id = UUID()
    let name: String
    let duration: String
    let bodyArea: BodyArea
    let instructions: [String]
    let sfSymbol: String
    let targetMuscles: String
}

// MARK: - Recovery Circuit

struct RecoveryCircuit: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let focusDescription: String
    let exercises: [StretchExercise]
    let totalMinutes: Int
    let icon: String
    let color: Color
}

// MARK: - All Stretches by Body Area

struct RecoveryData {

    static func stretches(for area: BodyArea) -> [StretchExercise] {
        switch area {
        case .shoulders: return shoulderStretches
        case .wristsHands: return wristStretches
        case .neckUpperBack: return neckStretches
        case .lowerBack: return lowerBackStretches
        case .hipsLegs: return hipLegStretches
        }
    }

    // MARK: Shoulders

    static let shoulderStretches: [StretchExercise] = [
        StretchExercise(
            name: "Cross-Body Shoulder Stretch",
            duration: "30s each side",
            bodyArea: .shoulders,
            instructions: [
                "Bring one arm across your chest at shoulder height",
                "Use the opposite hand to gently press above the elbow",
                "Keep shoulders relaxed and down",
                "Hold for 30 seconds, then switch sides"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Rear deltoid, rotator cuff"
        ),
        StretchExercise(
            name: "Overhead Tricep Stretch",
            duration: "30s each side",
            bodyArea: .shoulders,
            instructions: [
                "Raise one arm overhead and bend the elbow behind your head",
                "Use the opposite hand to gently pull the elbow back",
                "Keep your core engaged and avoid arching your back",
                "Hold for 30 seconds, then switch sides"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Triceps, rear deltoid"
        ),
        StretchExercise(
            name: "Chest Expansion",
            duration: "30s",
            bodyArea: .shoulders,
            instructions: [
                "Clasp your hands behind your back",
                "Straighten your arms and lift them slightly",
                "Squeeze shoulder blades together and open your chest",
                "Hold for 30 seconds, breathing deeply"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Chest, front deltoids"
        ),
        StretchExercise(
            name: "Arm Circles",
            duration: "30s each direction",
            bodyArea: .shoulders,
            instructions: [
                "Extend both arms out to your sides at shoulder height",
                "Make small circles, gradually increasing size",
                "Circle forward for 30 seconds",
                "Reverse direction for 30 seconds"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Full shoulder girdle"
        )
    ]

    // MARK: Wrists & Hands

    static let wristStretches: [StretchExercise] = [
        StretchExercise(
            name: "Wrist Flexor Stretch",
            duration: "30s each hand",
            bodyArea: .wristsHands,
            instructions: [
                "Extend one arm forward, palm facing up",
                "Use the other hand to gently pull fingers down and back",
                "Keep the arm straight",
                "Hold for 30 seconds, then switch hands"
            ],
            sfSymbol: "hand.raised.fill",
            targetMuscles: "Wrist flexors, inner forearm"
        ),
        StretchExercise(
            name: "Wrist Extensor Stretch",
            duration: "30s each hand",
            bodyArea: .wristsHands,
            instructions: [
                "Extend one arm forward, palm facing down",
                "Use the other hand to gently press fingers toward you",
                "Keep the arm straight",
                "Hold for 30 seconds, then switch hands"
            ],
            sfSymbol: "hand.raised.fill",
            targetMuscles: "Wrist extensors, outer forearm"
        ),
        StretchExercise(
            name: "Prayer Stretch",
            duration: "30s",
            bodyArea: .wristsHands,
            instructions: [
                "Press palms together in front of your chest",
                "Slowly lower your hands while keeping palms together",
                "Stop when you feel a stretch in your wrists and forearms",
                "Hold for 30 seconds"
            ],
            sfSymbol: "hand.raised.fill",
            targetMuscles: "Wrist flexors, forearms"
        ),
        StretchExercise(
            name: "Finger Spread & Fist Clench",
            duration: "10 reps",
            bodyArea: .wristsHands,
            instructions: [
                "Spread all fingers as wide as possible",
                "Hold the spread for 3 seconds",
                "Clench into a tight fist",
                "Repeat 10 times to restore blood flow"
            ],
            sfSymbol: "hand.raised.fill",
            targetMuscles: "Finger flexors, hand muscles"
        )
    ]

    // MARK: Neck & Upper Back

    static let neckStretches: [StretchExercise] = [
        StretchExercise(
            name: "Head Rolls",
            duration: "30s each direction",
            bodyArea: .neckUpperBack,
            instructions: [
                "Drop your chin to your chest",
                "Slowly roll your head to one side, then back, then to the other side",
                "Make smooth, controlled circles",
                "Avoid forcing the neck backward — keep it gentle"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Neck muscles, upper traps"
        ),
        StretchExercise(
            name: "Upper Trap Stretch",
            duration: "30s each side",
            bodyArea: .neckUpperBack,
            instructions: [
                "Tilt your head to one side, ear toward shoulder",
                "Gently place your hand on top of your head for light pressure",
                "Keep the opposite shoulder relaxed and down",
                "Hold for 30 seconds, then switch sides"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Upper trapezius, levator scapulae"
        ),
        StretchExercise(
            name: "Chin Tucks",
            duration: "10 reps",
            bodyArea: .neckUpperBack,
            instructions: [
                "Stand or sit with good posture",
                "Pull your chin straight back, making a double chin",
                "Hold for 5 seconds, then release",
                "Repeat 10 times — great for posture correction"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Deep neck flexors, upper back"
        ),
        StretchExercise(
            name: "Thread the Needle",
            duration: "30s each side",
            bodyArea: .neckUpperBack,
            instructions: [
                "Start on all fours (tabletop position)",
                "Slide one arm under your body, reaching to the opposite side",
                "Lower your shoulder and temple to the ground",
                "Hold for 30 seconds, then switch sides"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Thoracic spine, rhomboids"
        )
    ]

    // MARK: Lower Back

    static let lowerBackStretches: [StretchExercise] = [
        StretchExercise(
            name: "Child's Pose",
            duration: "45s",
            bodyArea: .lowerBack,
            instructions: [
                "Kneel on the floor and sit back on your heels",
                "Fold forward, reaching arms out in front of you",
                "Let your forehead rest on the ground",
                "Breathe deeply and hold for 45 seconds"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Lower back, lats, hips"
        ),
        StretchExercise(
            name: "Cat-Cow",
            duration: "10 reps",
            bodyArea: .lowerBack,
            instructions: [
                "Start on all fours with a neutral spine",
                "Inhale: Drop belly, lift chest and tailbone (cow)",
                "Exhale: Round spine, tuck chin and pelvis (cat)",
                "Flow slowly between positions for 10 reps"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Entire spine, core"
        ),
        StretchExercise(
            name: "Supine Twist",
            duration: "30s each side",
            bodyArea: .lowerBack,
            instructions: [
                "Lie on your back with arms out to the sides",
                "Bend one knee and cross it over your body",
                "Keep both shoulders on the ground",
                "Hold for 30 seconds, then switch sides"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Lower back, obliques, glutes"
        ),
        StretchExercise(
            name: "Standing Forward Fold",
            duration: "30s",
            bodyArea: .lowerBack,
            instructions: [
                "Stand with feet hip-width apart",
                "Hinge at the hips and fold forward",
                "Let your head and arms hang heavy",
                "Bend knees slightly if needed — hold for 30 seconds"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Hamstrings, lower back"
        )
    ]

    // MARK: Hips & Legs

    static let hipLegStretches: [StretchExercise] = [
        StretchExercise(
            name: "Hip Flexor Lunge Stretch",
            duration: "30s each side",
            bodyArea: .hipsLegs,
            instructions: [
                "Step into a deep lunge position",
                "Drop your back knee to the ground",
                "Push your hips forward gently",
                "Hold for 30 seconds, then switch legs"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Hip flexors, quads"
        ),
        StretchExercise(
            name: "Standing Quad Stretch",
            duration: "30s each side",
            bodyArea: .hipsLegs,
            instructions: [
                "Stand on one leg (use a wall for balance if needed)",
                "Grab your opposite ankle behind you",
                "Pull heel toward your glute, keeping knees together",
                "Hold for 30 seconds, then switch legs"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Quadriceps"
        ),
        StretchExercise(
            name: "Butterfly Stretch",
            duration: "45s",
            bodyArea: .hipsLegs,
            instructions: [
                "Sit on the floor with soles of your feet together",
                "Pull your heels toward your body",
                "Gently press your knees toward the ground",
                "Lean forward slightly and hold for 45 seconds"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Inner thighs, hip adductors"
        ),
        StretchExercise(
            name: "Wall Calf Stretch",
            duration: "30s each side",
            bodyArea: .hipsLegs,
            instructions: [
                "Stand facing a wall, hands on the wall",
                "Step one foot back into a lunge position",
                "Press the back heel into the floor",
                "Hold for 30 seconds, then switch legs"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Calves, Achilles tendon"
        ),
        StretchExercise(
            name: "Seated Hamstring Stretch",
            duration: "30s each side",
            bodyArea: .hipsLegs,
            instructions: [
                "Sit with one leg extended, the other bent inward",
                "Reach forward toward your extended foot",
                "Keep your back straight — hinge from the hips",
                "Hold for 30 seconds, then switch legs"
            ],
            sfSymbol: "figure.cooldown",
            targetMuscles: "Hamstrings"
        )
    ]

    // MARK: - Circuits

    static let circuits: [RecoveryCircuit] = [
        RecoveryCircuit(
            name: "Full Body Flush",
            subtitle: "General post-training",
            focusDescription: "A complete cooldown hitting every major area after any training session.",
            exercises: [
                shoulderStretches[0], // Cross-Body Shoulder
                wristStretches[2],    // Prayer Stretch
                neckStretches[0],     // Head Rolls
                lowerBackStretches[1], // Cat-Cow
                hipLegStretches[0],   // Hip Flexor Lunge
                lowerBackStretches[0], // Child's Pose
                hipLegStretches[4],   // Seated Hamstring
                shoulderStretches[2], // Chest Expansion
            ],
            totalMinutes: 10,
            icon: "figure.cooldown",
            color: .mint
        ),
        RecoveryCircuit(
            name: "Upper Body Recovery",
            subtitle: "After heavy bag or pad work",
            focusDescription: "Targets shoulders, arms, wrists, and upper back — the areas that take the most punishment from bag and pad sessions.",
            exercises: [
                shoulderStretches[0], // Cross-Body Shoulder
                shoulderStretches[1], // Overhead Tricep
                wristStretches[0],    // Wrist Flexor
                wristStretches[1],    // Wrist Extensor
                wristStretches[3],    // Finger Spread
                neckStretches[1],     // Upper Trap
                neckStretches[3],     // Thread the Needle
                shoulderStretches[2], // Chest Expansion
            ],
            totalMinutes: 10,
            icon: "figure.boxing",
            color: .orange
        ),
        RecoveryCircuit(
            name: "Legs & Core Reset",
            subtitle: "After footwork or sparring",
            focusDescription: "Loosens up tight hips, legs, and lower back from heavy movement and stance work.",
            exercises: [
                hipLegStretches[0],    // Hip Flexor Lunge
                hipLegStretches[1],    // Standing Quad
                hipLegStretches[3],    // Wall Calf
                hipLegStretches[4],    // Seated Hamstring
                lowerBackStretches[1], // Cat-Cow
                lowerBackStretches[2], // Supine Twist
                hipLegStretches[2],    // Butterfly
                lowerBackStretches[0], // Child's Pose
            ],
            totalMinutes: 10,
            icon: "figure.run",
            color: .green
        ),
        RecoveryCircuit(
            name: "Fight Night Wind-Down",
            subtitle: "Post-sparring full recovery",
            focusDescription: "Deep full-body recovery for after intense sparring. Calms the nervous system and addresses every sore spot.",
            exercises: [
                neckStretches[0],      // Head Rolls
                shoulderStretches[0],  // Cross-Body Shoulder
                wristStretches[2],     // Prayer Stretch
                neckStretches[3],      // Thread the Needle
                lowerBackStretches[2], // Supine Twist
                hipLegStretches[0],    // Hip Flexor Lunge
                lowerBackStretches[3], // Standing Forward Fold
                lowerBackStretches[0], // Child's Pose
            ],
            totalMinutes: 10,
            icon: "moon.stars.fill",
            color: .indigo
        )
    ]
}
