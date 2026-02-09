import SwiftUI
import SwiftData

struct QuickLogSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var techniques: [Technique]
    @Query private var combos: [Combo]
    @Query(sort: \Location.useCount, order: .reverse) private var locations: [Location]
    @Query private var profiles: [UserProfile]

    @State private var selectedType: SessionType = .classSession
    @State private var duration: Int = 60
    @State private var selectedIntensity: Intensity?
    @State private var didApplyDefaults = false
    @State private var notes: String = ""
    @State private var selectedTechniques: Set<Technique> = []
    @State private var selectedCombos: Set<Combo> = []
    @State private var showingMoreOptions = false
    @State private var selectedLocation: Location?
    @State private var newLocationName: String = ""
    @State private var showingNewLocation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    sessionTypeSection
                    durationSection
                    locationSection

                    if showComboSection {
                        comboSection
                    }

                    techniqueSection
                    moreOptionsSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Log Training")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { saveSession() }
                        .font(.body.bold())
                }
            }
            .alert("Add Location", isPresented: $showingNewLocation) {
                TextField("Location name", text: $newLocationName)
                Button("Cancel", role: .cancel) { newLocationName = "" }
                Button("Add") { addNewLocation() }
            } message: {
                Text("Enter a name for this location")
            }
            .onAppear {
                ensureDefaultData()
                applyProfileDefaults()
            }
        }
    }

    private var showComboSection: Bool {
        [.bagWork, .padWork, .shadowBoxing, .drilling].contains(selectedType)
    }

    // MARK: - Sections

    private var sessionTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What did you do?")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(SessionType.allCases) { type in
                    SessionTypeButton(type: type, isSelected: selectedType == type) {
                        selectedType = type
                        duration = type.defaultDuration
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Duration")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach([15, 30, 45, 60, 90], id: \.self) { mins in
                    DurationButton(minutes: mins, isSelected: duration == mins) {
                        duration = mins
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }

            HStack {
                Text("Custom:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Stepper("\(duration) min", value: $duration, in: 5...180, step: 5)
            }
        }
        .padding(.horizontal)
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)

            let allLocations = locations.filter { $0.isFavorite } + locations.filter { !$0.isFavorite }.prefix(5)

            if !allLocations.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(Array(allLocations)) { location in
                        LocationChip(location: location, isSelected: selectedLocation?.id == location.id) {
                            selectedLocation = selectedLocation?.id == location.id ? nil : location
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                    addLocationButton
                }
            } else {
                Button { showingNewLocation = true } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add location")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private var addLocationButton: some View {
        Button { showingNewLocation = true } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                Text("Add")
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))
            .clipShape(Capsule())
        }
    }

    private var comboSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Combos worked on")
                    .font(.headline)
                Spacer()
                Text("1=Jab 2=Cross 3=Hook...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            let suggestedCombos = getSuggestedCombos()
            if !suggestedCombos.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(suggestedCombos) { combo in
                        ComboChip(combo: combo, isSelected: selectedCombos.contains(combo)) {
                            toggleCombo(combo)
                        }
                    }
                    NavigationLink { ComboPickerView(selectedCombos: $selectedCombos) } label: {
                        moreButton
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var techniqueSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let suggestedTechniques = getSuggestedTechniques()
            if !suggestedTechniques.isEmpty {
                Text("Techniques worked on")
                    .font(.headline)

                FlowLayout(spacing: 8) {
                    ForEach(suggestedTechniques) { technique in
                        TechniqueChip(technique: technique, isSelected: selectedTechniques.contains(technique)) {
                            toggleTechnique(technique)
                        }
                    }
                    NavigationLink { TechniquePickerView(selectedTechniques: $selectedTechniques) } label: {
                        moreButton
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var moreButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "plus")
            Text("More")
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
        .clipShape(Capsule())
    }

    private var moreOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation { showingMoreOptions.toggle() }
            } label: {
                HStack {
                    Text("More Details")
                        .font(.headline)
                    Spacer()
                    Image(systemName: showingMoreOptions ? "chevron.up" : "chevron.down")
                }
                .foregroundStyle(.primary)
            }

            if showingMoreOptions {
                intensityPicker
                notesField
            }
        }
        .padding(.horizontal)
    }

    private var intensityPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Intensity")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(Intensity.allCases) { intensity in
                    IntensityButton(intensity: intensity, isSelected: selectedIntensity == intensity) {
                        selectedIntensity = selectedIntensity == intensity ? nil : intensity
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
        }
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("What did you work on?", text: $notes, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .lineLimit(3...6)
        }
    }

    // MARK: - Helper Methods

    private func getSuggestedTechniques() -> [Technique] {
        let recent = techniques.filter { $0.lastUsed != nil }
            .sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }
            .prefix(8)
        let frequent = techniques.filter { $0.useCount > 0 }
            .sorted { $0.useCount > $1.useCount }
            .prefix(8)

        var seen = Set<UUID>()
        var result: [Technique] = []
        for t in recent where seen.insert(t.id).inserted { result.append(t) }
        for t in frequent where seen.insert(t.id).inserted && result.count < 12 { result.append(t) }
        return result
    }

    private func getSuggestedCombos() -> [Combo] {
        let recent = combos.filter { $0.lastUsed != nil }
            .sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }
            .prefix(8)
        let frequent = combos.filter { $0.useCount > 0 }
            .sorted { $0.useCount > $1.useCount }
            .prefix(8)

        var seen = Set<UUID>()
        var result: [Combo] = []
        for c in recent where seen.insert(c.id).inserted { result.append(c) }
        for c in frequent where seen.insert(c.id).inserted && result.count < 12 { result.append(c) }
        if result.isEmpty { result = Array(combos.prefix(8)) }
        return result
    }

    private func toggleTechnique(_ technique: Technique) {
        if selectedTechniques.contains(technique) {
            selectedTechniques.remove(technique)
        } else {
            selectedTechniques.insert(technique)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func toggleCombo(_ combo: Combo) {
        if selectedCombos.contains(combo) {
            selectedCombos.remove(combo)
        } else {
            selectedCombos.insert(combo)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func addNewLocation() {
        let name = newLocationName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let location = Location(name: name)
        modelContext.insert(location)
        selectedLocation = location
        newLocationName = ""
    }

    private func applyProfileDefaults() {
        guard !didApplyDefaults, let profile = profiles.first else { return }
        didApplyDefaults = true
        selectedType = profile.preferredSessionType
        duration = profile.typicalSessionLength
        selectedIntensity = profile.preferredIntensity
    }

    private func ensureDefaultData() {
        if techniques.isEmpty {
            for t in DefaultTechniques.createDefaultTechniques() {
                modelContext.insert(t)
            }
        }
        if combos.isEmpty {
            for c in DefaultCombos.createDefaultCombos() {
                modelContext.insert(c)
            }
        }
    }

    private func saveSession() {
        selectedLocation?.recordUse()
        for combo in selectedCombos { combo.recordUse() }

        let session = Session(
            sessionType: selectedType,
            duration: duration,
            intensity: selectedIntensity,
            notes: notes.isEmpty ? nil : notes,
            location: selectedLocation,
            techniques: Array(selectedTechniques),
            combos: Array(selectedCombos)
        )
        modelContext.insert(session)

        for technique in selectedTechniques { technique.recordUse() }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

// MARK: - Supporting Views

struct SessionTypeButton: View {
    let type: SessionType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title2)
                Text(type.rawValue)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.orange : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct DurationButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(minutes)m")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? Color.orange : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct IntensityButton: View {
    let intensity: Intensity
    let isSelected: Bool
    let action: () -> Void

    private var color: Color {
        switch intensity {
        case .light: return .green
        case .moderate: return .orange
        case .hard: return .red
        }
    }

    var body: some View {
        Button(action: action) {
            Text(intensity.rawValue)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? color : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct LocationChip: View {
    let location: Location
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if location.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                }
                Text(location.name)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

struct ComboChip: View {
    let combo: Combo
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(combo.displayName)
                .font(.subheadline.monospaced())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.red : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}
