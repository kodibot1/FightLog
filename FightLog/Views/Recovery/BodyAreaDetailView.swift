import SwiftUI

struct BodyAreaDetailView: View {
    let bodyArea: BodyArea

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: bodyArea.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(bodyArea.color)
                        .frame(width: 80, height: 80)
                        .background(bodyArea.color.opacity(0.15))
                        .clipShape(Circle())

                    Text(bodyArea.commonPains)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 8)

                // Stretches
                VStack(spacing: 16) {
                    ForEach(RecoveryData.stretches(for: bodyArea)) { stretch in
                        stretchCard(stretch)
                    }
                }
            }
            .padding(.vertical)
        }
        .premiumBackground()
        .navigationTitle(bodyArea.rawValue)
        .navigationBarTitleDisplayMode(.large)
    }

    private func stretchCard(_ stretch: StretchExercise) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                StretchIllustrationView(
                    sfSymbol: stretch.sfSymbol,
                    bodyArea: stretch.bodyArea,
                    targetMuscles: stretch.targetMuscles
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(stretch.name)
                        .font(.headline)

                    HStack(spacing: 8) {
                        Label(stretch.duration, systemImage: "timer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            // Instructions
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(stretch.instructions.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.caption.bold())
                            .foregroundStyle(bodyArea.color)
                            .frame(width: 18, alignment: .trailing)

                        Text(step)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}
