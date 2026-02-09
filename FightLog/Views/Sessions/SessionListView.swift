import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]

    private var sessionViewModel: SessionViewModel {
        SessionViewModel(modelContext: modelContext)
    }

    private var sessionsByWeek: [(key: Date, value: [Session])] {
        sessionViewModel.sessionsByWeek(from: sessions)
    }

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions Yet",
                        systemImage: "figure.boxing",
                        description: Text("Your training history will appear here")
                    )
                } else {
                    List {
                        ForEach(sessionsByWeek, id: \.key) { week, weekSessions in
                            Section {
                                ForEach(weekSessions) { session in
                                    NavigationLink(destination: SessionDetailView(session: session)) {
                                        SessionListRow(session: session)
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteSession(at: indexSet, from: weekSessions)
                                }
                            } header: {
                                Text(weekHeader(for: week))
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Sessions")
        }
    }

    private func weekHeader(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            return "This Week"
        }

        let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
        if calendar.isDate(date, equalTo: lastWeek, toGranularity: .weekOfYear) {
            return "Last Week"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: date)!
        return "\(formatter.string(from: date)) - \(formatter.string(from: endOfWeek))"
    }

    private func deleteSession(at offsets: IndexSet, from weekSessions: [Session]) {
        for index in offsets {
            sessionViewModel.deleteSession(weekSessions[index])
        }
    }
}

struct SessionListRow: View {
    let session: Session

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.sessionType.icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.sessionType.rawValue)
                    .font(.body)

                HStack(spacing: 6) {
                    Text("\(session.duration) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let intensity = session.intensity {
                        Circle()
                            .fill(intensityColor(intensity))
                            .frame(width: 6, height: 6)
                        Text(intensity.rawValue)
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
        .padding(.vertical, 4)
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
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    SessionListView()
        .modelContainer(for: [Session.self, Technique.self, ProgressNote.self], inMemory: true)
}
