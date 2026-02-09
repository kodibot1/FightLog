import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            SessionListView()
                .tabItem {
                    Label("Sessions", systemImage: "list.bullet")
                }

            LessonListView()
                .tabItem {
                    Label("Lessons", systemImage: "book.fill")
                }

            TechniqueListView()
                .tabItem {
                    Label("Techniques", systemImage: "figure.boxing")
                }

            NoteListView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }

            PeopleListView()
                .tabItem {
                    Label("People", systemImage: "person.crop.circle")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Session.self, Technique.self, ProgressNote.self, Location.self, Combo.self, Lesson.self, Person.self, UserProfile.self], inMemory: true)
}
