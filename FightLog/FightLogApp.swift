import SwiftUI
import SwiftData

@main
struct FightLogApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Session.self,
            Technique.self,
            ProgressNote.self,
            Location.self,
            Combo.self,
            Lesson.self,
            Goal.self,
            Streak.self,
            SparringPartner.self,
            SparringSession.self,
            VideoNote.self,
            TrainingSchedule.self,
            Person.self,
            UserProfile.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    NotificationManager.shared.clearBadge()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        if profiles.isEmpty {
            OnboardingView()
        } else {
            MainTabView()
        }
    }
}
