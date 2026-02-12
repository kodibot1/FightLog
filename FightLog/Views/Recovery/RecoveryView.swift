import SwiftUI

struct RecoveryView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Pick Your Pain
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pick Your Pain")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(BodyArea.allCases) { area in
                        NavigationLink {
                            BodyAreaDetailView(bodyArea: area)
                        } label: {
                            bodyAreaCard(area)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // 10-Minute Circuits
                VStack(alignment: .leading, spacing: 12) {
                    Text("10-Min Circuits")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(RecoveryData.circuits) { circuit in
                        NavigationLink {
                            CircuitDetailView(circuit: circuit)
                        } label: {
                            circuitCard(circuit)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Recovery")
        .navigationBarTitleDisplayMode(.large)
    }

    private func bodyAreaCard(_ area: BodyArea) -> some View {
        HStack(spacing: 14) {
            Image(systemName: area.icon)
                .font(.title2)
                .foregroundStyle(area.color)
                .frame(width: 44, height: 44)
                .background(area.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(area.rawValue)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text("\(RecoveryData.stretches(for: area).count) stretches")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func circuitCard(_ circuit: RecoveryCircuit) -> some View {
        HStack(spacing: 14) {
            Image(systemName: circuit.icon)
                .font(.title2)
                .foregroundStyle(circuit.color)
                .frame(width: 44, height: 44)
                .background(circuit.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(circuit.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(circuit.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(circuit.totalMinutes) min")
                    .font(.caption.bold())
                    .foregroundStyle(circuit.color)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}
