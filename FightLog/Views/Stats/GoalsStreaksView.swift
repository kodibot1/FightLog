import SwiftUI
import SwiftData

struct GoalsStreaksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @Query private var streaks: [Streak]
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]

    @State private var showingAddGoal = false

    private var currentStreak: Streak {
        if let streak = streaks.first {
            return streak
        }
        let newStreak = Streak()
        modelContext.insert(newStreak)
        return newStreak
    }

    var body: some View {
        VStack(spacing: 16) {
            // Streak Card
            streakCard

            // Goals
            goalsSection
        }
    }

    private var streakCard: some View {
        HStack(spacing: 20) {
            VStack {
                Text("🔥")
                    .font(.system(size: 40))
                Text("\(currentStreak.currentStreak)")
                    .font(.title.bold())
                Text("day streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()

            VStack {
                Text("🏆")
                    .font(.system(size: 40))
                Text("\(currentStreak.longestStreak)")
                    .font(.title.bold())
                Text("best streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()

            VStack {
                Text("📅")
                    .font(.system(size: 40))
                Text("\(sessionsThisWeek)")
                    .font(.title.bold())
                Text("this week")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            currentStreak.checkStreakStatus()
        }
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Goals")
                    .font(.headline)
                Spacer()
                Button {
                    showingAddGoal = true
                } label: {
                    Image(systemName: "plus.circle")
                }
            }

            if goals.filter({ $0.isActive }).isEmpty {
                Text("No active goals. Tap + to add one!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(goals.filter { $0.isActive }) { goal in
                    GoalRow(goal: goal, progress: progressFor(goal))
                }
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalSheet()
        }
    }

    private var sessionsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return sessions.filter { $0.timestamp >= startOfWeek }.count
    }

    private func progressFor(_ goal: Goal) -> Int {
        let calendar = Calendar.current
        let now = Date()

        let startDate: Date
        switch goal.period {
        case .daily:
            startDate = calendar.startOfDay(for: now)
        case .weekly:
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        case .monthly:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        }

        return sessions.filter { $0.timestamp >= startDate }.count
    }
}

struct GoalRow: View {
    let goal: Goal
    let progress: Int

    private var progressPercent: Double {
        min(Double(progress) / Double(goal.targetCount), 1.0)
    }

    private var isComplete: Bool {
        progress >= goal.targetCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: goal.period.icon)
                    .foregroundStyle(.orange)
                Text(goal.title)
                    .font(.subheadline)
                Spacer()
                Text("\(progress)/\(goal.targetCount)")
                    .font(.caption)
                    .foregroundStyle(isComplete ? .green : .secondary)
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(isComplete ? Color.green : Color.orange)
                        .frame(width: geometry.size.width * progressPercent, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AddGoalSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var targetCount = 3
    @State private var period: GoalPeriod = .weekly

    var body: some View {
        NavigationStack {
            Form {
                TextField("Goal (e.g., Train 3 times)", text: $title)

                Stepper("Target: \(targetCount) sessions", value: $targetCount, in: 1...14)

                Picker("Period", selection: $period) {
                    ForEach(GoalPeriod.allCases) { p in
                        Label(p.rawValue, systemImage: p.icon).tag(p)
                    }
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let goal = Goal(
                            title: title.isEmpty ? "Train \(targetCount) times \(period.rawValue.lowercased())" : title,
                            targetCount: targetCount,
                            period: period
                        )
                        modelContext.insert(goal)
                        dismiss()
                    }
                    .font(.body.bold())
                }
            }
        }
    }
}
