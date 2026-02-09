import Foundation
import SwiftData

@Observable
class TechniqueViewModel {
    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func ensureDefaultTechniques(existing: [Technique]) {
        guard existing.isEmpty else { return }

        for technique in DefaultTechniques.createDefaultTechniques() {
            modelContext.insert(technique)
        }
    }

    func recentTechniques(from techniques: [Technique], limit: Int = 8) -> [Technique] {
        techniques
            .filter { $0.lastUsed != nil }
            .sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }
            .prefix(limit)
            .map { $0 }
    }

    func frequentTechniques(from techniques: [Technique], limit: Int = 8) -> [Technique] {
        techniques
            .filter { $0.useCount > 0 }
            .sorted { $0.useCount > $1.useCount }
            .prefix(limit)
            .map { $0 }
    }

    func techniquesByCategory(from techniques: [Technique]) -> [TechniqueCategory: [Technique]] {
        Dictionary(grouping: techniques) { $0.category }
    }

    func createTechnique(name: String, category: TechniqueCategory) -> Technique {
        let technique = Technique(name: name, category: category)
        modelContext.insert(technique)
        return technique
    }
}
