import SwiftUI
import SwiftData

struct TechniquePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Technique.name) private var techniques: [Technique]

    @Binding var selectedTechniques: Set<Technique>
    @State private var searchText = ""

    private var techniquesByCategory: [TechniqueCategory: [Technique]] {
        let filtered = searchText.isEmpty
            ? techniques
            : techniques.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        return Dictionary(grouping: filtered) { $0.category }
    }

    var body: some View {
        List {
            ForEach(TechniqueCategory.allCases) { category in
                if let categoryTechniques = techniquesByCategory[category], !categoryTechniques.isEmpty {
                    Section {
                        ForEach(categoryTechniques) { technique in
                            Button {
                                toggleTechnique(technique)
                            } label: {
                                HStack {
                                    Text(technique.name)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    if selectedTechniques.contains(technique) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.orange)
                                    }
                                }
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
        .navigationTitle("Select Techniques")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
                .font(.body.bold())
            }
        }
    }

    private func toggleTechnique(_ technique: Technique) {
        if selectedTechniques.contains(technique) {
            selectedTechniques.remove(technique)
        } else {
            selectedTechniques.insert(technique)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    NavigationStack {
        TechniquePickerView(selectedTechniques: .constant([]))
    }
    .modelContainer(for: [Session.self, Technique.self, ProgressNote.self], inMemory: true)
}
