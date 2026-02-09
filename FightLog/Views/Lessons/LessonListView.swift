import SwiftUI
import SwiftData

struct LessonListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Lesson.updatedAt, order: .reverse) private var lessons: [Lesson]

    @State private var showingCreateLesson = false

    var body: some View {
        NavigationStack {
            Group {
                if lessons.isEmpty {
                    ContentUnavailableView(
                        "No Lessons Yet",
                        systemImage: "book.fill",
                        description: Text("Create workouts to share with friends and family")
                    )
                } else {
                    List {
                        ForEach(lessons) { lesson in
                            NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                                LessonRow(lesson: lesson)
                            }
                        }
                        .onDelete(perform: deleteLessons)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Lessons")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateLesson = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateLesson) {
                CreateLessonSheet()
            }
        }
    }

    private func deleteLessons(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(lessons[index])
        }
    }
}

struct LessonRow: View {
    let lesson: Lesson

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lesson.title)
                    .font(.headline)
                Spacer()
                Image(systemName: lesson.difficulty.icon)
                    .foregroundStyle(difficultyColor)
            }

            HStack {
                Label("\(lesson.durationMinutes) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("•")
                    .foregroundStyle(.secondary)

                Text(lesson.difficulty.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !lesson.drills.isEmpty {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("\(lesson.drills.count) drills")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let notes = lesson.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private var difficultyColor: Color {
        switch lesson.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

#Preview {
    LessonListView()
        .modelContainer(for: [Session.self, Technique.self, ProgressNote.self, Location.self, Combo.self, Lesson.self], inMemory: true)
}
