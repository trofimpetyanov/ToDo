import Foundation

/// A structure representing a todo item.
struct ToDoItem: Identifiable {
    let id: String
    let text: String
    
    let importance: Importance
    let dueDate: Date?
    
    let isCompleted: Bool

    let dateCreated: Date
    let dateEdited: Date?
    
    /// Initializes a new todo item with the provided values.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the todo item. Defaults to a new UUID string.
    ///   - text: The text description of the todo item.
    ///   - importance: The importance level of the todo item. Defaults to `.ordinary`.
    ///   - dueDate: The due date of the todo item. Defaults to `nil`.
    ///   - isCompleted: A Boolean value indicating whether the todo item is completed. Defaults to `false`.
    ///   - dateCreated: The date the todo item was created. Defaults to the current date and time.
    ///   - dateEdited: The date the todo item was last edited. Defaults to `nil`.
    init(id: String = UUID().uuidString,
         text: String,
         importance: Importance = .ordinary,
         dueDate: Date? = nil,
         isCompleted: Bool = false,
         dateCreated: Date = Date(),
         dateEdited: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated
        self.dateEdited = dateEdited
    }
}
