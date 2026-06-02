import SwiftUI
import UIKit

// MARK: - UIColor Hex + Dynamic Provider

extension UIColor {
    /// Build a UIColor from a 6/8-digit hex string (e.g. "0D0B1E" or "FF0D0B1E")
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }

    /// Dynamic UIColor that swaps between light and dark variants based on trait collection.
    /// iOS 13+ automatic dark mode support.
    convenience init(light: UIColor, dark: UIColor) {
        self.init { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        }
    }

    /// Dynamic UIColor from hex strings.
    convenience init(lightHex: String, darkHex: String) {
        self.init(light: UIColor(hex: lightHex), dark: UIColor(hex: darkHex))
    }
}

extension Color {
    /// Dynamic Color from hex string pair (light, dark).
    init(lightHex: String, darkHex: String) {
        self.init(UIColor(lightHex: lightHex, darkHex: darkHex))
    }

    /// Dynamic Color from UIColor pair.
    init(light: UIColor, dark: UIColor) {
        self.init(UIColor(light: light, dark: dark))
    }
}
