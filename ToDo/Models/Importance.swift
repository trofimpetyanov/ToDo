import Foundation

/// An enumeration representing the importance level of a to-do item.
enum Importance: String {
    case unimportant, ordinary, important
}

// MARK: – Codable
extension Importance: Codable { }
