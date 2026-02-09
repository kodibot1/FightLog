import SwiftUI
import SwiftData

struct TechniqueDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var technique: Technique

    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: technique.category.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text(technique.name)
                        .font(.title.bold())

                    Text(technique.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Proficiency Rating
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Proficiency")
                        .font(.headline)

                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                withAnimation {
                                    technique.proficiencyRating = technique.proficiencyRating == star ? 0 : star
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                Image(systemName: star <= technique.proficiencyRating ? "star.fill" : "star")
                                    .font(.title)
                                    .foregroundStyle(star <= technique.proficiencyRating ? .yellow : .gray)
                            }
                        }

                        Spacer()

                        Text(ratingLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                // Stats
                HStack(spacing: 16) {
                    TechniqueStatBox(title: "Times Used", value: "\(technique.useCount)", icon: "repeat")
                    TechniqueStatBox(title: "Last Used", value: lastUsedText, icon: "clock")
                }
                .padding(.horizontal)

                // Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Your Notes")
                            .font(.headline)
                        Spacer()
                        Button(isEditing ? "Done" : "Edit") {
                            isEditing.toggle()
                        }
                    }

                    if isEditing {
                        TextField("Add notes about this technique...", text: Binding(
                            get: { technique.notes ?? "" },
                            set: { technique.notes = $0.isEmpty ? nil : $0 }
                        ), axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .lineLimit(4...8)
                    } else if let notes = technique.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text("Tap Edit to add notes")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)

                // Common Mistakes
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common Mistakes to Avoid")
                        .font(.headline)

                    if isEditing {
                        TextField("What mistakes should you watch for?", text: Binding(
                            get: { technique.commonMistakes ?? "" },
                            set: { technique.commonMistakes = $0.isEmpty ? nil : $0 }
                        ), axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .lineLimit(2...4)
                    } else if let mistakes = technique.commonMistakes, !mistakes.isEmpty {
                        Text(mistakes)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text("Tap Edit to add common mistakes")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)

                // Sessions using this technique
                if let sessions = technique.sessions, !sessions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Sessions")
                            .font(.headline)

                        ForEach(sessions.sorted { $0.timestamp > $1.timestamp }.prefix(5)) { session in
                            HStack {
                                Image(systemName: session.sessionType.icon)
                                    .foregroundStyle(.orange)
                                Text(session.sessionType.rawValue)
                                Spacer()
                                Text(formatDate(session.timestamp))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Technique")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var ratingLabel: String {
        switch technique.proficiencyRating {
        case 0: return "Not rated"
        case 1: return "Beginner"
        case 2: return "Learning"
        case 3: return "Developing"
        case 4: return "Proficient"
        case 5: return "Mastered"
        default: return ""
        }
    }

    private var lastUsedText: String {
        guard let lastUsed = technique.lastUsed else { return "Never" }
        let calendar = Calendar.current
        if calendar.isDateInToday(lastUsed) { return "Today" }
        if calendar.isDateInYesterday(lastUsed) { return "Yesterday" }
        let days = calendar.dateComponents([.day], from: lastUsed, to: Date()).day ?? 0
        if days < 7 { return "\(days)d ago" }
        let weeks = days / 7
        return "\(weeks)w ago"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct TechniqueStatBox: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.orange)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
