import UIKit

final class AppIconLoader {
    static let shared = AppIconLoader()

    private(set) var iconImage: UIImage?

    private init() {
        iconImage = loadIcon()
    }

    private func loadIcon() -> UIImage? {
        if let img = UIImage(named: "AppIcon") {
            return img
        }

        if let bundlePath = Bundle.main.resourcePath {
            let fullPath = (bundlePath as NSString).appendingPathComponent("AppIcon.appiconset/Icon-1024@1x.png")
            if let img = UIImage(contentsOfFile: fullPath) {
                return img
            }
        }

        if let url = Bundle.main.url(forResource: "Assets", withExtension: "xcassets", subdirectory: nil) {
            let iconURL = url.appendingPathComponent("AppIcon.appiconset/Icon-1024@1x.png")
            if let img = UIImage(contentsOfFile: iconURL.path) {
                return img
            }
        }

        if let url = Bundle.main.url(forResource: "Assets", withExtension: "xcassets", subdirectory: "Sources/Resources") {
            let iconURL = url.appendingPathComponent("AppIcon.appiconset/Icon-1024@1x.png")
            if let img = UIImage(contentsOfFile: iconURL.path) {
                return img
            }
        }

        return nil
    }
}