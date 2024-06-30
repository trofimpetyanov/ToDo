import SwiftUI

extension Image {
    /// Creates an `Image` instance using a system image with a specified font and tint color.
    ///
    /// - Parameters:
    ///   - systemName: The name of the system image to load.
    ///   - font: The `UIFont` to apply to the system image.
    ///   - tint: The `UIColor` to use as the tint color. The default value is `.label`.
    /// - Returns: An `Image` instance configured with the specified font and tint color.
    /// - Note: If the system image cannot be loaded or configured, an exclamation mark triangle image is returned.
    static func systemImage(_ systemName: String, for font: UIFont, tint: UIColor = .label) -> Image {
        let fontConfiguration = UIImage.SymbolConfiguration(font: font)
        let colorConfiguration = UIImage.SymbolConfiguration(hierarchicalColor: tint)
        
        guard let uiImage = UIImage(systemName: systemName, withConfiguration: fontConfiguration),
              let uiImage = uiImage.applyingSymbolConfiguration(colorConfiguration)
        else { return Image(systemName: "exclamationmark.triangle") }
        
        return Image(uiImage: uiImage)
    }
}
