import Foundation
import SwiftData

@Model
final class Location {
    var id: UUID
    var name: String
    var isFavorite: Bool
    var useCount: Int

    init(name: String, isFavorite: Bool = false) {
        self.id = UUID()
        self.name = name
        self.isFavorite = isFavorite
        self.useCount = 0
    }

    func recordUse() {
        useCount += 1
    }
}
