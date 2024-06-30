import SwiftUI

extension Color {
    /// Calculates the luminance of the color.
    /// - Returns: The luminance value of the color as a `CGFloat`.
    ///   Uses the relative luminance formula: 0.2126 * red + 0.7152 * green + 0.0722 * blue.
    func luminance() -> CGFloat {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 0]
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        // Use the relative luminance formula.
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        
        return luminance
    }
    
    /// A Boolean value indicating whether the color is dark.
    /// - Returns: `true` if the luminance of the color is less than 0.5; otherwise, `false`.
    var isDark: Bool {
        return luminance() < 0.5
    }
    
    /// The ideal text color (black or white) based on the luminance of the color.
    /// - Returns: `.white` if the color is dark; otherwise, `.black`.
    var idealTextColor: Color {
        return isDark ? .white : .black
    }
}
