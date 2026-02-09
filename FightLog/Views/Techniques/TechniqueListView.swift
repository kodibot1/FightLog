import SwiftUI
import SwiftData

struct TechniqueListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Technique.name) private var techniques: [Technique]

    @State private var searchText = ""
    @State private var showingAddTechnique = false

    private var techniquesByCategory: [TechniqueCategory: [Technique]] {
        let filtered = searchText.isEmpty
            ? techniques
            : techniques.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        return Dictionary(grouping: filtered) { $0.category }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(TechniqueCategory.allCases) { category in
                    if let categoryTechniques = techniquesByCategory[category], !categoryTechniques.isEmpty {
                        Section {
                            ForEach(categoryTechniques) { technique in
                                NavigationLink(destination: TechniqueDetailView(technique: technique)) {
                                    TechniqueRow(technique: technique)
                                }
                            }
                        } header: {
                            Label(category.rawValue, systemImage: category.icon)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search techniques")
            .navigationTitle("Techniques")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTechnique = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTechnique) {
                AddTechniqueSheet()
            }
            .onAppear {
                ensureDefaultTechniques()
            }
        }
    }

    private func ensureDefaultTechniques() {
        guard techniques.isEmpty else { return }
        for technique in DefaultTechniques.createDefaultTechniques() {
            modelContext.insert(technique)
        }
    }
}

struct TechniqueRow: View {
    let technique: Technique

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(technique.name)
                    .font(.body)

                HStack(spacing: 8) {
                    // Rating stars
                    if technique.proficiencyRating > 0 {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= technique.proficiencyRating ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundStyle(star <= technique.proficiencyRating ? .yellow : .gray.opacity(0.3))
                            }
                        }
                    }

                    // Use count
                    if technique.useCount > 0 {
                        Text("\(technique.useCount)×")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

struct AddTechniqueSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category: TechniqueCategory = .punch

    var body: some View {
        NavigationStack {
            Form {
                TextField("Technique Name", text: $name)

                Picker("Category", selection: $category) {
                    ForEach(TechniqueCategory.allCases) { cat in
                        Label(cat.rawValue, systemImage: cat.icon)
                            .tag(cat)
                    }
                }
            }
            .navigationTitle("Add Technique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let technique = Technique(name: name.trimmingCharacters(in: .whitespaces), category: category)
                        modelContext.insert(technique)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .font(.body.bold())
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
