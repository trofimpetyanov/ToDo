import SwiftUI

/// An enumeration representing the importance level of a todo item.
enum Importance: String, CaseIterable {
    case unimportant, ordinary, important
}

extension Importance: Comparable {
    static func < (lhs: Importance, rhs: Importance) -> Bool {
        switch (lhs, rhs) {
        case (.unimportant, _) where rhs != .unimportant:
            return true
        case (.ordinary, .important):
            return true
        default:
            return false
        }
    }
}
