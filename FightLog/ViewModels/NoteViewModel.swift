import Foundation
import SwiftData

@Observable
class NoteViewModel {
    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createNote(content: String, session: Session? = nil) -> ProgressNote {
        let note = ProgressNote(content: content, session: session)
        modelContext.insert(note)
        return note
    }

    func deleteNote(_ note: ProgressNote) {
        modelContext.delete(note)
    }

    func updateNote(_ note: ProgressNote, content: String) {
        note.content = content
    }
}
