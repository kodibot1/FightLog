import SwiftUI
import SwiftData

struct SparringPartnersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SparringPartner.lastSparred, order: .reverse) private var partners: [SparringPartner]

    @State private var showingAddPartner = false

    var body: some View {
        NavigationStack {
            Group {
                if partners.isEmpty {
                    ContentUnavailableView(
                        "No Sparring Partners",
                        systemImage: "person.2.fill",
                        description: Text("Add people you train with")
                    )
                } else {
                    List {
                        ForEach(partners) { partner in
                            NavigationLink(destination: SparringPartnerDetailView(partner: partner)) {
                                PartnerRow(partner: partner)
                            }
                        }
                        .onDelete(perform: deletePartners)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Sparring Partners")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPartner = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPartner) {
                AddSparringPartnerSheet()
            }
        }
    }

    private func deletePartners(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(partners[index])
        }
    }
}

struct PartnerRow: View {
    let partner: SparringPartner

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(partner.name.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundStyle(.orange)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(partner.name)
                    .font(.body)

                HStack(spacing: 8) {
                    if let style = partner.style, !style.isEmpty {
                        Text(style)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if partner.sessionCount > 0 {
                        Text("\(partner.sessionCount) sessions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if let lastSparred = partner.lastSparred {
                Text(formatDate(lastSparred))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct SparringPartnerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var partner: SparringPartner

    @State private var showingLogSession = false
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Text(partner.name.prefix(1).uppercased())
                                .font(.largeTitle)
                                .foregroundStyle(.orange)
                        }

                    Text(partner.name)
                        .font(.title.bold())

                    if let nickname = partner.nickname, !nickname.isEmpty {
                        Text("\"\(nickname)\"")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Stats
                HStack(spacing: 16) {
                    StatBox(title: "Sessions", value: "\(partner.sessionCount)", icon: "figure.boxing")

                    if let weight = partner.weightClass, !weight.isEmpty {
                        StatBox(title: "Weight", value: weight, icon: "scalemass")
                    }
                }
                .padding(.horizontal)

                // Style & Notes
                if let style = partner.style, !style.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fighting Style")
                            .font(.headline)
                        Text(style)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }

                if isEditing {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        TextField("Notes about this partner...", text: Binding(
                            get: { partner.notes ?? "" },
                            set: { partner.notes = $0.isEmpty ? nil : $0 }
                        ), axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .lineLimit(3...6)
                    }
                    .padding(.horizontal)
                } else if let notes = partner.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        Text(notes)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }

                // Log Session Button
                Button {
                    showingLogSession = true
                } label: {
                    Label("Log Sparring Session", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Partner")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
        }
        .sheet(isPresented: $showingLogSession) {
            LogSparringSessionSheet(partner: partner)
        }
    }
}

struct AddSparringPartnerSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var nickname = ""
    @State private var weightClass = ""
    @State private var style = ""

    let styleOptions = ["Pressure Fighter", "Counter Puncher", "Southpaw", "Orthodox", "Technical", "Brawler", "Out-Fighter"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)
                    TextField("Nickname (optional)", text: $nickname)
                    TextField("Weight Class (optional)", text: $weightClass)
                }

                Section("Fighting Style") {
                    TextField("Style (optional)", text: $style)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(styleOptions, id: \.self) { option in
                                Button {
                                    style = option
                                } label: {
                                    Text(option)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(style == option ? Color.orange : Color(.systemGray5))
                                        .foregroundStyle(style == option ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Partner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let partner = SparringPartner(
                            name: name.trimmingCharacters(in: .whitespaces),
                            nickname: nickname.isEmpty ? nil : nickname,
                            weightClass: weightClass.isEmpty ? nil : weightClass,
                            style: style.isEmpty ? nil : style
                        )
                        modelContext.insert(partner)
                        dismiss()
                    }
                    .font(.body.bold())
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct LogSparringSessionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let partner: SparringPartner

    @State private var rounds = 3
    @State private var roundLength = 180
    @State private var intensity: Intensity?
    @State private var whatWorked = ""
    @State private var whatDidntWork = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Session Details") {
                    Stepper("Rounds: \(rounds)", value: $rounds, in: 1...12)

                    Picker("Round Length", selection: $roundLength) {
                        Text("2:00").tag(120)
                        Text("3:00").tag(180)
                        Text("5:00").tag(300)
                    }

                    Picker("Intensity", selection: $intensity) {
                        Text("Not Set").tag(nil as Intensity?)
                        ForEach(Intensity.allCases) { i in
                            Text(i.rawValue).tag(i as Intensity?)
                        }
                    }
                }

                Section("What Worked Well") {
                    TextField("Techniques, combos, strategies...", text: $whatWorked, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("What Didn't Work") {
                    TextField("Things to improve...", text: $whatDidntWork, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Notes") {
                    TextField("Other observations...", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Log Sparring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let session = SparringSession(
                            partner: partner,
                            rounds: rounds,
                            roundLengthSeconds: roundLength,
                            intensity: intensity,
                            whatWorked: whatWorked.isEmpty ? nil : whatWorked,
                            whatDidntWork: whatDidntWork.isEmpty ? nil : whatDidntWork,
                            notes: notes.isEmpty ? nil : notes
                        )
                        modelContext.insert(session)
                        partner.recordSession()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .font(.body.bold())
                }
            }
        }
    }
}
