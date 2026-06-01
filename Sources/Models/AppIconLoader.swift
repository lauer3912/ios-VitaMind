import UIKit

final class AppIconLoader {
    static let shared = AppIconLoader()

    private(set) var iconImage: UIImage?

    private init() {
        iconImage = loadIcon()
    }

    private func loadIcon() -> UIImage? {
        // Method 1: Try UIImage named (standard asset catalog)
        if let img = UIImage(named: "AppIcon") {
            return img
        }

        // Method 2: Search all asset catalogs in the bundle for AppIcon
        if let img = findIconInAssetCatalogs() {
            return img
        }

        // Method 3: Direct bundle path for AppIcon.appiconset/Icon-1024@1x.png
        let bundleURL = URL(fileURLWithPath: Bundle.main.bundlePath)
        let iconFullPath = bundleURL
            .appendingPathComponent("Assets.xcassets")
            .appendingPathComponent("AppIcon.appiconset")
            .appendingPathComponent("Icon-1024@1x.png")

        if let img = UIImage(contentsOfFile: iconFullPath.path) {
            return img
        }

        return nil
    }

    private func findIconInAssetCatalogs() -> UIImage? {
        // Try common asset catalog locations
        let searchPaths: [String] = [
            Bundle.main.bundlePath + "/Assets.xcassets/AppIcon.appiconset/Icon-1024@1x.png",
            Bundle.main.bundlePath + "/Sources/Resources/Assets.xcassets/AppIcon.appiconset/Icon-1024@1x.png"
        ]

        for path in searchPaths {
            if let img = UIImage(contentsOfFile: path) {
                return img
            }
        }

        // Iterate all xcassets folders found in bundle
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: Bundle.main.bundlePath),
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        for case let url as URL in enumerator {
            if url.pathExtension == "xcassets" {
                let iconPath = url.appendingPathComponent("AppIcon.appiconset/Icon-1024@1x.png")
                if let img = UIImage(contentsOfFile: iconPath.path) {
                    return img
                }
            }
        }

        return nil
    }
}