import Foundation
import SwiftData

@Model
final class Person {
    var id: UUID
    var name: String
    var shortDescription: String
    var compiledDescription: String
    var createdAt: Date
    var lastSeenAt: Date
    var memoryAids: [String: String]

    @Relationship(deleteRule: .nullify) var location: Location?

    init(name: String, shortDescription: String = "", location: Location? = nil) {
        self.id = UUID()
        self.name = name
        self.shortDescription = shortDescription
        self.compiledDescription = ""
        self.createdAt = Date()
        self.lastSeenAt = Date()
        self.memoryAids = [:]
        self.location = location
    }

    func compileDescription() {
        var parts: [String] = []

        if !shortDescription.isEmpty {
            parts.append(shortDescription)
        }

        for question in MemoryQuestions.allQuestions {
            if let answer = memoryAids[question.id], !answer.isEmpty {
                parts.append("\(question.descriptionPrefix) \(answer)")
            }
        }

        compiledDescription = parts.joined(separator: ". ")
        if !compiledDescription.isEmpty && !compiledDescription.hasSuffix(".") {
            compiledDescription += "."
        }
    }
}
