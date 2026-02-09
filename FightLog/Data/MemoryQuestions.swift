import Foundation

struct MemoryQuestion: Identifiable {
    let id: String
    let question: String
    let placeholder: String
    let icon: String
    let descriptionPrefix: String
}

struct MemoryQuestions {
    static let allQuestions: [MemoryQuestion] = [
        MemoryQuestion(
            id: "appearance",
            question: "What did they look like?",
            placeholder: "e.g. Tall, short hair, tattoo on left arm",
            icon: "person.fill",
            descriptionPrefix: "Looks like"
        ),
        MemoryQuestion(
            id: "wore",
            question: "What were they wearing?",
            placeholder: "e.g. Red Everlast gloves, black shorts",
            icon: "tshirt.fill",
            descriptionPrefix: "Was wearing"
        ),
        MemoryQuestion(
            id: "hair",
            question: "Any facial hair or distinctive hair?",
            placeholder: "e.g. Big beard, bald, long ponytail",
            icon: "comb.fill",
            descriptionPrefix: "Has"
        ),
        MemoryQuestion(
            id: "build",
            question: "What was their build?",
            placeholder: "e.g. Stocky, lean, very tall",
            icon: "figure.stand",
            descriptionPrefix: "Build is"
        ),
        MemoryQuestion(
            id: "technique",
            question: "What was their best technique or style?",
            placeholder: "e.g. Great jab, southpaw, very aggressive",
            icon: "figure.boxing",
            descriptionPrefix: "Known for"
        ),
        MemoryQuestion(
            id: "trait",
            question: "Any memorable trait or habit?",
            placeholder: "e.g. Always shadow boxes before rounds",
            icon: "star.fill",
            descriptionPrefix: "Notable trait:"
        ),
        MemoryQuestion(
            id: "experience",
            question: "What was their experience level?",
            placeholder: "e.g. Beginner, been boxing 5 years, amateur fighter",
            icon: "chart.bar.fill",
            descriptionPrefix: "Experience:"
        ),
        MemoryQuestion(
            id: "personality",
            question: "How would you describe their personality?",
            placeholder: "e.g. Quiet, very friendly, intense",
            icon: "face.smiling.fill",
            descriptionPrefix: "Personality is"
        )
    ]
}
