import SwiftUI
import SwiftData

struct AddPersonSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Location.useCount, order: .reverse) private var locations: [Location]

    @State private var name = ""
    @State private var quickDescription = ""
    @State private var selectedLocation: Location?
    @State private var newLocationName = ""
    @State private var showingQAFlow = false
    @State private var savedPerson: Person?

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Their name or nickname", text: $name)
                }

                Section("Quick Description (optional)") {
                    TextField("e.g. Tall guy with red gloves", text: $quickDescription)
                }

                Section("Gym") {
                    if !locations.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(locations) { location in
                                    Button {
                                        if selectedLocation?.id == location.id {
                                            selectedLocation = nil
                                        } else {
                                            selectedLocation = location
                                        }
                                    } label: {
                                        Text(location.name)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedLocation?.id == location.id ? Color.cyan : Color(.systemGray5))
                                            .foregroundStyle(selectedLocation?.id == location.id ? .white : .primary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }

                    TextField("Or type a new gym name", text: $newLocationName)
                }

                Section {
                    Button {
                        save(openQA: false)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .frame(minHeight: 50)

                    Button {
                        save(openQA: true)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save & Add Details")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .tint(.cyan)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .frame(minHeight: 50)
                }
            }
            .navigationTitle("New Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showingQAFlow) {
                if let person = savedPerson {
                    MemoryQAFlowView(person: person)
                }
            }
        }
    }

    private func save(openQA: Bool) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let location: Location?
        let trimmedNewLocation = newLocationName.trimmingCharacters(in: .whitespaces)

        if !trimmedNewLocation.isEmpty {
            let newLoc = Location(name: trimmedNewLocation)
            modelContext.insert(newLoc)
            location = newLoc
        } else {
            location = selectedLocation
        }

        let person = Person(name: trimmedName, shortDescription: quickDescription, location: location)
        person.compileDescription()
        modelContext.insert(person)

        if openQA {
            savedPerson = person
            showingQAFlow = true
        } else {
            dismiss()
        }
    }
}
