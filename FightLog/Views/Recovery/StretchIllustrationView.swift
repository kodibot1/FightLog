import SwiftUI

struct StretchIllustrationView: View {
    let sfSymbol: String
    let bodyArea: BodyArea
    let targetMuscles: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(bodyArea.color.opacity(0.15))
                    .frame(width: 64, height: 64)

                Image(systemName: sfSymbol)
                    .font(.system(size: 28))
                    .foregroundStyle(bodyArea.color)
            }

            Text(targetMuscles)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}
