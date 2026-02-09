import SwiftUI
import SwiftData

struct PeopleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.lastSeenAt, order: .reverse) private var people: [Person]
    @State private var searchText = ""
    @State private var showingAddSheet = false

    private var filteredPeople: [Person] {
        if searchText.isEmpty {
            return people
        }
        return people.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.compiledDescription.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedByLocation: [(String, [Person])] {
        let grouped = Dictionary(grouping: filteredPeople) { person in
            person.location?.name ?? "No Gym"
        }
        return grouped.sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            Group {
                if people.isEmpty {
                    ContentUnavailableView(
                        "No People Yet",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Tap + to remember someone you met at the gym")
                    )
                } else if filteredPeople.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(groupedByLocation, id: \.0) { locationName, persons in
                            Section(locationName) {
                                ForEach(Array(persons.enumerated()), id: \.element.id) { index, person in
                                    NavigationLink(destination: PersonDetailView(person: person)) {
                                        PersonRow(person: person)
                                    }
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                }
                                .onDelete { offsets in
                                    deletePeople(from: persons, at: offsets)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("People")
            .searchable(text: $searchText, prompt: "Search people")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddPersonSheet()
            }
        }
    }

    private func deletePeople(from persons: [Person], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(persons[index])
        }
    }
}

struct PersonRow: View {
    let person: Person

    var body: some View {
        HStack(spacing: 12) {
            Text(String(person.name.prefix(1)).uppercased())
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.cyan)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.body.bold())

                if !person.compiledDescription.isEmpty {
                    Text(person.compiledDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            if let location = person.location {
                Text(location.name)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cyan.opacity(0.15))
                    .foregroundStyle(.cyan)
                    .clipShape(Capsule())
            }
        }
    }
}
