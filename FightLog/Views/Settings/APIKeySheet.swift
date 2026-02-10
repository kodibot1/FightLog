import SwiftUI

struct APIKeySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""
    @State private var showingKey = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.orange)

                    Text("Claude API Key")
                        .font(.title2.bold())

                    Text("Your key is stored locally on your device and used to power the Voice Log AI analysis.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        if showingKey {
                            TextField("sk-ant-...", text: $apiKey)
                                .textFieldStyle(.plain)
                                .font(.system(.body, design: .monospaced))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        } else {
                            SecureField("sk-ant-...", text: $apiKey)
                                .textFieldStyle(.plain)
                                .font(.system(.body, design: .monospaced))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }

                        Button {
                            showingKey.toggle()
                        } label: {
                            Image(systemName: showingKey ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Link(destination: URL(string: "https://console.anthropic.com/settings/keys")!) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text("Get an API key from Anthropic")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                }

                Spacer()

                Button {
                    AIService.shared.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                    dismiss()
                } label: {
                    Text("Save Key")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(apiKey.isEmpty ? Color(.systemGray4) : Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(apiKey.isEmpty)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                apiKey = AIService.shared.apiKey ?? ""
            }
        }
    }
}
