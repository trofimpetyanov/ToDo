import SwiftUI

extension Image {
    static func systemImage(_ systemName: String, for font: UIFont, tint: UIColor = .label) -> Image {
        let fontConfiguration = UIImage.SymbolConfiguration(font: font)
        let colorConfiguration = UIImage.SymbolConfiguration(hierarchicalColor: tint)
        
        guard let uiImage = UIImage(systemName: systemName, withConfiguration: fontConfiguration),
              let uiImage = uiImage.applyingSymbolConfiguration(colorConfiguration)
        else { return Image(systemName: "exclamationmark.triangle") }
        
        return Image(uiImage: uiImage)
    }
}
