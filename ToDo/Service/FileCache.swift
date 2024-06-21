import Foundation

/// A structure for managing `ToDoItem` objects in cache, providing methods to add, delete, save, and load items.
struct FileCache {
    
    enum FileFormat: String {
        case json, csv
    }
    
    static let mock = [
        ToDoItem(text: "Buy groceries", isCompleted: true),
        ToDoItem(text: "Walk the dog named \"Daisy\"", importance: .important, dueDate: Date(timeIntervalSinceNow: 3600)),
        ToDoItem(text: "Read a book", dateCreated: Date(timeIntervalSinceNow: -86400)),
        ToDoItem(text: "Write a blog post", importance: .unimportant),
        ToDoItem(text: "Workout", dueDate: Date(timeIntervalSinceNow: 7200), isCompleted: false),
        ToDoItem(text: "Plan vacation", isCompleted: true, dateEdited: Date(timeIntervalSinceNow: -3600)),
        ToDoItem(text: "Clean the house", importance: .important),
        ToDoItem(text: "Call mom", importance: .ordinary, dueDate: Date(timeIntervalSinceNow: 1800), isCompleted: false)
    ]
    
    private(set) var toDoItems: [ToDoItem] = []
    
    private var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    /// Adds a new `ToDoItem` to the cache.
    ///
    /// - Parameter toDoItem: The `ToDoItem` to be added.
    /// - Note: If an item with the same `id` already exists in the cache, it will not be added.
    mutating func add(_ toDoItem: ToDoItem) {
        guard !toDoItems.contains(where: { toDoItem.id == $0.id }) else { return }
        
        toDoItems.insert(toDoItem, at: 0)
    }
    
    /// Deletes a `ToDoItem` from the cache by its `id`.
    ///
    /// - Parameter id: The `id` of the `ToDoItem` to be deleted.
    mutating func delete(with id: String) {
        guard let index = toDoItems.firstIndex(where: { id == $0.id }) else { return }
        
        toDoItems.remove(at: index)
    }
    
    /// Saves the current list of `ToDoItem` objects to a file.
    ///
    /// - Parameter file: The name of the file to save the items to.
    func save(to file: String) {
        let path = documentsDirectory.appending(path: file)
        let items = toDoItems.map { $0.json }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: items)
            try data.write(to: path)
        } catch {
            print("Error writing data to the file \"\(file)\"")
        }
    }
    
    /// Loads `ToDoItem` objects from a file.
    ///
    /// - Parameter file: The name of the file to load the items from.
    /// - Returns: An array of `ToDoItem` objects loaded from the specified file.
    /// - Note: If there is an error reading from the file, an empty array is returned.
    func load(from file: String) -> [ToDoItem] {
        let path = documentsDirectory.appending(path: file)
        
        do {
            let data = try Data(contentsOf: path)
            let items = try JSONSerialization.jsonObject(with: data) as! [Any]
            let toDoItems = items.compactMap { ToDoItem.parse(json: $0) }
            
            return toDoItems
        } catch {
            
            return []
        }
    }
}
