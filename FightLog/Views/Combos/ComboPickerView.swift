import SwiftUI
import SwiftData

struct ComboPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Combo.numbers) private var combos: [Combo]

    @Binding var selectedCombos: Set<Combo>
    @State private var searchText = ""
    @State private var showingAddCombo = false
    @State private var newComboNumbers = ""
    @State private var newComboName = ""

    private var filteredCombos: [Combo] {
        if searchText.isEmpty {
            return combos
        }
        return combos.filter {
            $0.numbers.localizedCaseInsensitiveContains(searchText) ||
            ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    private var defaultCombos: [Combo] {
        filteredCombos.filter { !$0.isCustom }
    }

    private var customCombos: [Combo] {
        filteredCombos.filter { $0.isCustom }
    }

    var body: some View {
        List {
            // Boxing Number Reference
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Boxing Number System")
                        .font(.headline)
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("1 = Jab")
                            Text("2 = Cross")
                            Text("3 = Lead Hook")
                            Text("4 = Rear Hook")
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("5 = Lead Uppercut")
                            Text("6 = Rear Uppercut")
                            Text("7 = Lead Body Hook")
                            Text("8 = Rear Body Hook")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            // Custom Combos
            if !customCombos.isEmpty {
                Section("Your Combos") {
                    ForEach(customCombos) { combo in
                        ComboRow(combo: combo, isSelected: selectedCombos.contains(combo)) {
                            toggleCombo(combo)
                        }
                    }
                }
            }

            // Default Combos
            Section("Common Combos") {
                ForEach(defaultCombos) { combo in
                    ComboRow(combo: combo, isSelected: selectedCombos.contains(combo)) {
                        toggleCombo(combo)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Search combos (e.g., 1-2-3)")
        .navigationTitle("Select Combos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddCombo = true
                } label: {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
                .font(.body.bold())
            }
        }
        .alert("Add Custom Combo", isPresented: $showingAddCombo) {
            TextField("Combo (e.g., 1-2-3-2)", text: $newComboNumbers)
            TextField("Name (optional)", text: $newComboName)
            Button("Cancel", role: .cancel) {
                newComboNumbers = ""
                newComboName = ""
            }
            Button("Add") {
                addCustomCombo()
            }
        } message: {
            Text("Enter the combo using numbers (1=Jab, 2=Cross, etc.)")
        }
    }

    private func toggleCombo(_ combo: Combo) {
        if selectedCombos.contains(combo) {
            selectedCombos.remove(combo)
        } else {
            selectedCombos.insert(combo)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func addCustomCombo() {
        let numbers = newComboNumbers.trimmingCharacters(in: .whitespaces)
        guard !numbers.isEmpty else { return }

        let name = newComboName.trimmingCharacters(in: .whitespaces)
        let combo = Combo(
            numbers: numbers,
            name: name.isEmpty ? nil : name,
            isCustom: true
        )
        modelContext.insert(combo)
        selectedCombos.insert(combo)

        newComboNumbers = ""
        newComboName = ""
    }
}

struct ComboRow: View {
    let combo: Combo
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(combo.numbers)
                            .font(.body.monospaced().bold())
                        if let name = combo.name {
                            Text("(\(name))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(combo.breakdown)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if combo.useCount > 0 {
                    Text("\(combo.useCount)×")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .orange : .secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ComboPickerView(selectedCombos: .constant([]))
    }
    .modelContainer(for: [Session.self, Technique.self, ProgressNote.self, Location.self, Combo.self, Lesson.self], inMemory: true)
}
