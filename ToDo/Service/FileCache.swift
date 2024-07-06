import Foundation

/// A structure for managing `ToDoItem` objects in cache, providing methods to add, delete, save, and load items.
struct FileCache {
    
    enum FileFormat: String {
        case json, csv
    }
    
    static let mock: [ToDoItem] = [
//        ToDoItem(text: "Buy groceries", isCompleted: true),
//        ToDoItem(text: "Walk the dog named \"Daisy\"", importance: .important, dueDate: Date(timeIntervalSinceNow: 3600)),
//        ToDoItem(text: "Read a book", dateCreated: Date(timeIntervalSinceNow: -86400)),
//        ToDoItem(text: "Write a blog post", importance: .unimportant),
//        ToDoItem(text: "Workout", dueDate: Date(timeIntervalSinceNow: 7200), isCompleted: false),
//        ToDoItem(text: "Plan vacation", isCompleted: true, dateEdited: Date(timeIntervalSinceNow: -3600)),
//        ToDoItem(text: "Clean the house", importance: .important),
//        ToDoItem(text: "Call mom", importance: .ordinary, dueDate: Date(timeIntervalSinceNow: 1800), isCompleted: false)
    ]
    
    private(set) var toDoItems: [ToDoItem] = []
    
    private var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    var isFirstLaunch: Bool {
        let path = documentsDirectory
            .appending(path: "hasLaunched")
            .path()
        
        if !FileManager.default.fileExists(atPath: path) {
            let path = documentsDirectory
                .appending(path: "hasLaunched")
            
            try? "true".data(using: .utf8)?.write(to: path)
            
            return true
        }
        
        return false
    }
    
    /// Adds a new `ToDoItem` to the cache.
    ///
    /// - Parameter toDoItem: The `ToDoItem` to be added.
    /// - Note: If an item with the same `id` already exists in the cache, it will not be added.
    mutating func add(_ toDoItem: ToDoItem) {
        guard !toDoItems.contains(where: { toDoItem.id == $0.id }) else { return }
        
        toDoItems.append(toDoItem)
    }
    
    /// Updates an existing `ToDoItem` in the cache or adds a new one if it does not exist.
    ///
    /// - Parameter toDoItem: The `ToDoItem` to be updated or added.
    /// - Note: If an item with the same `id` already exists in the cache, it will be updated. Otherwise, the item will be added to the beginning of the list.
    mutating func addOrUpdate(_ toDoItem: ToDoItem) {
        if let index = toDoItems.firstIndex(where: { toDoItem.id == $0.id }) {
            toDoItems[index] = toDoItem
        } else {
            toDoItems.append(toDoItem)
        }
    }
    
    /// Deletes a `ToDoItem` from the cache by its `id`.
    ///
    /// - Parameter id: The `id` of the `ToDoItem` to be deleted.
    /// - Returns: The removed`ToDoItem` object.
    @discardableResult
    mutating func delete(with id: String) -> ToDoItem? {
        guard let index = toDoItems.firstIndex(where: { id == $0.id }) else { return nil }
        
        return toDoItems.remove(at: index)
    }
    
    /// Saves the current list of `ToDoItem` objects to a file in the specified format.
    ///
    /// - Parameters:
    ///   - file: The name of the file to save the items to.
    ///   - format: The format of the file (`.json` or `.csv`). Defaults to `.json`.
    /// - Throws: An error if the save operation fails. Possible errors include file write errors or serialization errors.
    /// - Note: The items are saved in a pretty-printed format if the format is `.json`.
    func save(to file: String, format: FileFormat = .json) throws {
        let path = documentsDirectory
            .appending(path: file)
            .appendingPathExtension(format.rawValue)
        
        switch format {
        case .json:
            try saveToJSON(at: path)
        case .csv:
            try saveToCSV(at: path)
        }
    }
    
    /// Loads `ToDoItem` objects from a file in the specified format.
    ///
    /// - Parameters:
    ///   - file: The name of the file to load the items from.
    ///   - format: The format of the file (`.json` or `.csv`). Defaults to `.json`.
    /// - Returns: An array of `ToDoItem` objects loaded from the specified file.
    /// - Throws: An error if the load operation fails. Possible errors include file read errors or deserialization errors.
    /// - Note: If there is an error reading from the file, an empty array is returned.
    mutating func load(from file: String, format: FileFormat = .json) throws {
        let path = documentsDirectory
            .appending(path: file)
            .appendingPathExtension(format.rawValue)
        
        switch format {
        case .json:
            toDoItems = try loadFromJSON(at: path)
        case .csv:
            toDoItems = try loadFromCSV(at: path)
        }
    }
}

// MARK: – Saving & Loading
extension FileCache {
    
    // JSON
    private func saveToJSON(at path: URL) throws {
        let items = toDoItems
            .map { $0.json }
        
        let data = try JSONSerialization.data(withJSONObject: items, options: .prettyPrinted)
        try data.write(to: path)
    }
    
    private func loadFromJSON(at path: URL) throws -> [ToDoItem] {
        let data = try Data(contentsOf: path)
        let items = try JSONSerialization.jsonObject(with: data) as! [Any]
        let toDoItems = items.compactMap { ToDoItem.parse(json: $0) }
        
        return toDoItems
    }
    
    // CSV
    private func saveToCSV(at path: URL) throws {
        let fields = ["id", "text", "importance", "dueDate", "isCompleted", "dateCreated", "dateEdited"]
        var data = "\"" + fields.joined(separator: "\",\"") + "\"\n"
        
        data += toDoItems
            .reduce("", { partialResult, toDoItem in
                return partialResult + toDoItem.csv
            })
        
        try data.write(to: path, atomically: true, encoding: .utf8)
    }
    
    private func loadFromCSV(at path: URL) throws -> [ToDoItem] {
        let data = try String(contentsOf: path)
        
        let lines = data.components(separatedBy: .newlines).dropFirst()
        let toDoItems: [ToDoItem] = lines.compactMap { ToDoItem.parse(csv: $0) }
        
        return toDoItems
    }
}
