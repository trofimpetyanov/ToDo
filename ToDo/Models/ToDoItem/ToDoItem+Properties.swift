import Foundation

extension ToDoItem {
    /// An enumeration of the properties of `ToDoItem`.
    ///
    /// Each case represents a field of the `ToDoItem` that can be converted to and from JSON and CSV formats.
    enum Properties: String, CaseIterable {
        case id
        case text
        case importance
        case dueDate
        case isCompleted
        case color
        case dateCreated
        case dateEdited
        case lastUpdatedBy
    }
}
