import SwiftUI

// MARK: - Design Tokens
//
// VitaTheme defines all visual constants used by the app.
//
// Color rules (iOS 17+ Light/Dark Mode required — see SOP §8.14, HR-19):
//  - Chrome tokens (background, surface, text) are dynamic and adapt to the
//    user's appearance (Light / Dark). They MUST stay legible in both modes.
//  - Brand tokens (primary, secondary, accent) are fixed — they define the
//    app's identity and look good against both backgrounds.
//  - Card rarity tokens (Common / Uncommon / Rare / Epic / Legendary) are
//    fixed — card art is intentionally dark, regardless of system theme.
//
// Adding a new token? Add it to BOTH `light:` and `dark:` (unless it's a
// brand or card color, in which case the same hex is fine for both).
enum VitaTheme {
    // MARK: - Colors
    enum Colors {
        // ── Brand colors (fixed across themes) ─────────────────────────
        static let primary      = Color(lightHex: "6B4EFF", darkHex: "6B4EFF")  // Royal purple
        static let secondary    = Color(lightHex: "00D9A0", darkHex: "00D9A0")  // Teal accent
        static let accent       = Color(lightHex: "FFD700", darkHex: "FFD700")  // Gold

        // ── Chrome (adaptive — change with appearance) ─────────────────
        // Dark mode: deep purple. Light mode: airy lavender.
        static let background   = Color(lightHex: "F5F3FF", darkHex: "0D0B1E")
        static let surface      = Color(lightHex: "FFFFFF", darkHex: "1A1730")
        static let surfaceLight = Color(lightHex: "EDE9FE", darkHex: "252040")

        // Standard iOS system colors so Form/List/Settings look native in
        // both light & dark. We expose them through our token system for
        // consistency.
        static let listBackground = Color(lightHex: "F5F3FF", darkHex: "0D0B1E")
        static let separator      = Color(lightHex: "E5E1F4", darkHex: "2A2540")

        // Text — opacity is encoded into the light/dark hex equivalents so
        // the same `textPrimary` token works in both modes.
        // Dark mode uses near-white; light mode uses deep purple.
        static let textPrimary   = Color(lightHex: "1A1730", darkHex: "FFFFFF")
        static let textSecondary = Color(lightHex: "4A4458", darkHex: "FFFFFF")    // ~0.7 alpha
        static let textTertiary  = Color(lightHex: "6B6580", darkHex: "FFFFFF")    // ~0.5 alpha

        // ── Status (fixed — convey meaning, not theme) ────────────────
        static let success = Color(lightHex: "2ECC71", darkHex: "2ECC71")
        static let warning = Color(lightHex: "F39C12", darkHex: "F39C12")
        static let error   = Color(lightHex: "E74C3C", darkHex: "E74C3C")

        // ── Card rarity (fixed — card art is always dark) ─────────────
        static let cardRare      = Color(lightHex: "FF6B6B", darkHex: "FF6B6B")
        static let cardEpic      = Color(lightHex: "9B59B6", darkHex: "9B59B6")
        static let cardLegendary = Color(lightHex: "FFD700", darkHex: "FFD700")
        static let cardCommon    = Color(lightHex: "4ECDC4", darkHex: "4ECDC4")
        static let cardUncommon  = Color(lightHex: "6B4EFF", darkHex: "6B4EFF")
    }

    // MARK: - Gradients
    enum Gradients {
        // Brand gradients (fixed)
        static let primary = LinearGradient(
            colors: [Colors.primary, Colors.primary.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let gold = LinearGradient(
            colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
            startPoint: .top,
            endPoint: .bottom
        )

        static let epic = LinearGradient(
            colors: [Color(hex: "9B59B6"), Color(hex: "8E44AD")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Card art is always dark — keep cardBackground fixed.
        static let cardBackground = LinearGradient(
            colors: [Color(hex: "1A1730"), Color(hex: "0D0B1E")],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Shadows
    enum Shadows {
        // Shadow opacity differs by mode: dark mode wants stronger shadows
        // (so the card "lifts" off a dark background); light mode wants
        // subtler shadows (the bright background already provides contrast).
        static let card = Shadow(
            color: Color(lightHex: "0D0B1E", darkHex: "000000"),
            radius: 8, x: 0, y: 4
        )
        static let cardLight = Shadow(
            color: Color(lightHex: "0D0B1E", darkHex: "000000"),
            radius: 8, x: 0, y: 4
        )
        static let glow = Shadow(color: Colors.primary.opacity(0.5), radius: 12, x: 0, y: 0)
        static let glowGold = Shadow(color: Colors.accent.opacity(0.6), radius: 15, x: 0, y: 0)
    }

    // MARK: - Fonts
    enum Fonts {
        static let displayBold = SwiftUI.Font.system(size: 28, weight: .bold, design: .rounded)
        static let displaySemibold = SwiftUI.Font.system(size: 24, weight: .semibold, design: .rounded)
        static let title = SwiftUI.Font.system(size: 20, weight: .bold, design: .rounded)
        static let titleMedium = SwiftUI.Font.system(size: 18, weight: .medium, design: .rounded)
        static let body = SwiftUI.Font.system(size: 16, weight: .regular, design: .default)
        static let caption = SwiftUI.Font.system(size: 13, weight: .regular, design: .default)
        static let captionBold = SwiftUI.Font.system(size: 12, weight: .bold, design: .rounded)
        static let statNumber = SwiftUI.Font.system(size: 32, weight: .bold, design: .monospaced)
        static let statLabel = SwiftUI.Font.system(size: 11, weight: .medium, design: .rounded)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let card: CGFloat = 16
    }
}

// MARK: - Color Extension (single-mode fallback for card art)
//
// The old `Color(hex:)` is preserved for places that want a single, theme-
// independent color (e.g. card art). Chrome code should prefer the
// `Colors.*` tokens which are dynamic.
extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}

// MARK: - Shadow Model
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifier for Shadows
struct CardShadow: ViewModifier {
    let shadow: Shadow

    func body(content: Content) -> some View {
        content
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {
    func cardShadow(_ shadow: Shadow) -> some View {
        modifier(CardShadow(shadow: shadow))
    }
}
