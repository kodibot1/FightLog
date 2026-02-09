import Foundation
import SwiftData

@Model
final class VideoNote {
    var id: UUID
    var title: String
    var videoURL: String  // Local file URL
    var thumbnailURL: String?
    var notes: String?
    var timestamp: Date
    var durationSeconds: Int?

    // Tags for categorization
    var tags: [String]

    @Relationship(deleteRule: .nullify)
    var linkedSession: Session?

    @Relationship(deleteRule: .nullify)
    var linkedTechnique: Technique?

    init(
        title: String,
        videoURL: String,
        thumbnailURL: String? = nil,
        notes: String? = nil,
        durationSeconds: Int? = nil,
        tags: [String] = [],
        linkedSession: Session? = nil,
        linkedTechnique: Technique? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.notes = notes
        self.timestamp = Date()
        self.durationSeconds = durationSeconds
        self.tags = tags
        self.linkedSession = linkedSession
        self.linkedTechnique = linkedTechnique
    }
}
