import Foundation

extension ToDoItem {
    /// An enumeration of the properties of `ToDoItem`.
    ///
    /// Each case represents a field of the `ToDoItem` that can be converted to and from JSON and CSV formats.
    enum Properties: String, CaseIterable {
        case id = "id"
        case text = "text"
        case importance = "importance"
        case dueDate = "dueDate"
        case color = "color"
        case isCompleted = "isCompleted"
        case dateCreated = "dateCreated"
        case dateEdited = "dateEdited"
    }
}
