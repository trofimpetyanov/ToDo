import SwiftUI

extension Color {
    func luminance() -> CGFloat {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 0]
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        // Use the relative luminance formula
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance
    }
    
    var isDark: Bool {
        return luminance() < 0.5
    }
    
    var idealTextColor: Color {
        return isDark ? .white : .black
    }
}
