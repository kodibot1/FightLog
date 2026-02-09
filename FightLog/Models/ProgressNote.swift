import Foundation
import SwiftData

@Model
final class ProgressNote {
    var id: UUID
    var content: String
    var timestamp: Date

    var session: Session?

    init(content: String, session: Session? = nil, timestamp: Date = Date()) {
        self.id = UUID()
        self.content = content
        self.session = session
        self.timestamp = timestamp
    }
}
