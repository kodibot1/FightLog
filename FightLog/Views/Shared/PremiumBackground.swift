import SwiftUI

struct PremiumBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geo in
                    ZStack {
                        Color(uiColor: .systemBackground)

                        // Primary radial glow from top center
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(colorScheme == .dark ? 0.08 : 0.10),
                                Color.orange.opacity(colorScheme == .dark ? 0.03 : 0.04),
                                Color.clear
                            ],
                            center: .init(x: 0.5, y: 0.0),
                            startRadius: 20,
                            endRadius: geo.size.height * 0.55
                        )

                        // Subtle warm accent at bottom for depth
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(colorScheme == .dark ? 0.04 : 0.05),
                                Color.clear
                            ],
                            center: .init(x: 0.5, y: 1.2),
                            startRadius: 10,
                            endRadius: geo.size.height * 0.35
                        )
                    }
                }
                .ignoresSafeArea()
            }
    }
}

extension View {
    func premiumBackground() -> some View {
        modifier(PremiumBackgroundModifier())
    }
}
