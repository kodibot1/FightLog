import SwiftUI

struct PersonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var person: Person

    @State private var showingQAFlow = false
    @State private var showingDeleteAlert = false
    @State private var showSeenCheck = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Avatar + Name
                VStack(spacing: 12) {
                    Text(String(person.name.prefix(1)).uppercased())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.cyan)
                        .clipShape(Circle())

                    Text(person.name)
                        .font(.title.bold())

                    if let location = person.location {
                        Text(location.name)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.cyan.opacity(0.15))
                            .foregroundStyle(.cyan)
                            .clipShape(Capsule())
                    }
                }
                .padding(.top)

                // Compiled description
                if !person.compiledDescription.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        Text(person.compiledDescription)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }

                // Memory aids
                let answeredQuestions = MemoryQuestions.allQuestions.filter {
                    person.memoryAids[$0.id] != nil && !(person.memoryAids[$0.id]?.isEmpty ?? true)
                }
                if !answeredQuestions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(answeredQuestions) { question in
                            HStack(spacing: 12) {
                                Image(systemName: question.icon)
                                    .font(.title3)
                                    .foregroundStyle(.cyan)
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(question.question)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(person.memoryAids[question.id] ?? "")
                                        .font(.body)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                }

                // Add More Details
                let unanswered = MemoryQuestions.allQuestions.filter {
                    person.memoryAids[$0.id] == nil || person.memoryAids[$0.id]?.isEmpty == true
                }
                if !unanswered.isEmpty {
                    Button {
                        showingQAFlow = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add More Details")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.cyan)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }

                // Mark as Seen
                ZStack {
                    Button {
                        person.lastSeenAt = Date()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showSeenCheck = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showSeenCheck = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: showSeenCheck ? "checkmark.circle.fill" : "eye.fill")
                            Text(showSeenCheck ? "Marked!" : "Mark as Seen")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemGray5))
                        .foregroundStyle(showSeenCheck ? .green : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }

                // Last seen
                Text("Last seen \(person.lastSeenAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom)
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete Person", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(person)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \(person.name)?")
        }
        .fullScreenCover(isPresented: $showingQAFlow) {
            MemoryQAFlowView(person: person)
        }
    }
}
