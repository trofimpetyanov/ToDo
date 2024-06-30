import SwiftUI

extension Color {
    /// Initializes a color that adapts to the current interface style (light or dark mode).
    /// - Parameters:
    ///   - lightModeColor: The color to use in light mode.
    ///   - darkModeColor: The color to use in dark mode.
    init(
        light lightModeColor: @escaping @autoclosure () -> Color,
        dark darkModeColor: @escaping @autoclosure () -> Color
    ) {
        self.init(uiColor: UIColor(
            light: UIColor(lightModeColor()),
            dark: UIColor(darkModeColor())
        ))
    }
}

extension UIColor {
    /// Initializes a color that adapts to the current interface style (light or dark mode).
    /// - Parameters:
    ///   - lightModeColor: The color to use in light mode.
    ///   - darkModeColor: The color to use in dark mode.
    convenience init(
        light lightModeColor: @escaping @autoclosure () -> UIColor,
        dark darkModeColor: @escaping @autoclosure () -> UIColor
    ) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return lightModeColor()
            case .dark:
                return darkModeColor()
            default:
                return lightModeColor()
            }
        }
    }
}
