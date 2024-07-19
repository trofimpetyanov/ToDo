import SwiftUI

/// An enumeration representing the importance level of a todo item.
enum Importance: String, CaseIterable, Codable {
    case low, basic, important
}

extension Importance: Comparable {
    static func < (lhs: Importance, rhs: Importance) -> Bool {
        switch (lhs, rhs) {
        case (.low, _) where rhs != .low:
            return true
        case (.basic, .important):
            return true
        default:
            return false
        }
    }
}
