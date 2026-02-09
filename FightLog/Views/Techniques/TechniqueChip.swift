import SwiftUI

struct TechniqueChip: View {
    let technique: Technique
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(technique.name)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    HStack {
        TechniqueChip(
            technique: Technique(name: "Jab", category: .punch),
            isSelected: false
        ) {}

        TechniqueChip(
            technique: Technique(name: "Cross", category: .punch),
            isSelected: true
        ) {}
    }
    .padding()
}
