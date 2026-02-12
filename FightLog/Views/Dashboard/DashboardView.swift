import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]
    @Query private var techniques: [Technique]
    @Query private var streaks: [Streak]
    @Query private var profiles: [UserProfile]

    @State private var showingLogSheet = false
    @State private var showingVoiceLog = false
    @State private var showingNoteSheet = false
    @State private var showingTimer = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Log Buttons
                    HStack(spacing: 12) {
                        Button {
                            showingLogSheet = true
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                Text("Log Training")
                                    .font(.title2.bold())
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button {
                            showingVoiceLog = true
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        } label: {
                            Image(systemName: "mic.fill")
                                .font(.title2)
                                .frame(width: 64, height: 64)
                                .background(Color.purple)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal)

                    // Goals & Streaks
                    GoalsStreaksView()
                        .padding(.horizontal)

                    // Calendar Heatmap
                    CalendarHeatmapView()
                        .padding(.horizontal)

                    // Quick Actions
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickActionButton(title: "Timer", icon: "timer", color: .red) {
                            showingTimer = true
                        }
                        QuickActionButton(title: "Note", icon: "note.text", color: .blue) {
                            showingNoteSheet = true
                        }
                        NavigationLink {
                            SparringPartnersView()
                        } label: {
                            QuickActionLabel(title: "Sparring", icon: "person.2.fill", color: .purple)
                        }
                        NavigationLink {
                            PeopleListView()
                        } label: {
                            QuickActionLabel(title: "People", icon: "person.crop.circle", color: .cyan)
                        }
                    }
                    .padding(.horizontal)

                    // Schedule Link
                    NavigationLink {
                        TrainingScheduleView()
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title2)
                                .foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Training Schedule")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)
                                Text("Set your training days & reminders")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    // Recovery Link
                    NavigationLink {
                        RecoveryView()
                    } label: {
                        HStack {
                            Image(systemName: "figure.cooldown")
                                .font(.title2)
                                .foregroundStyle(.mint)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Recovery")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)
                                Text("Stretches & recovery circuits")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    // Recent Sessions
                    if !sessions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Sessions")
                                    .font(.headline)
                                Spacer()
                                NavigationLink("See All") {
                                    SessionListView()
                                }
                                .font(.subheadline)
                            }
                            .padding(.horizontal)

                            ForEach(sessions.prefix(3)) { session in
                                NavigationLink(destination: SessionDetailView(session: session)) {
                                    SessionRow(session: session)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "figure.boxing")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("No sessions yet")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("Tap \"Log Training\" to get started")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding(.vertical)
            }
            .premiumBackground()
            .navigationTitle(greeting)
            .onAppear {
                ensureDefaultData()
            }
            .sheet(isPresented: $showingLogSheet) {
                QuickLogSheet()
            }
            .sheet(isPresented: $showingVoiceLog) {
                VoiceLogSheet()
            }
            .sheet(isPresented: $showingNoteSheet) {
                QuickNoteSheet()
            }
            .sheet(isPresented: $showingTimer) {
                RoundTimerView()
            }
        }
    }

    private var greeting: String {
        if let profile = profiles.first {
            return "Hey, \(profile.username)"
        }
        return "FightLog"
    }

    private func ensureDefaultData() {
        // Ensure streak exists
        if streaks.isEmpty {
            modelContext.insert(Streak())
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            QuickActionLabel(title: title, icon: icon, color: color)
        }
    }
}

struct QuickActionLabel: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SessionRow: View {
    let session: Session

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.sessionType.icon)
                .font(.title2)
                .foregroundStyle(.orange)
                .frame(width: 44, height: 44)
                .background(Color.orange.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(session.sessionType.rawValue)
                    .font(.body.bold())

                HStack(spacing: 8) {
                    Text("\(session.duration) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let intensity = session.intensity {
                        Text(intensity.rawValue)
                            .font(.caption)
                            .foregroundStyle(intensityColor(intensity))
                    }

                    if let location = session.location {
                        Text(location.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Text(formatDate(session.timestamp))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func intensityColor(_ intensity: Intensity) -> Color {
        switch intensity {
        case .light: return .green
        case .moderate: return .orange
        case .hard: return .red
        }
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }
    }
}
