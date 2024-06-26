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
    /// - Returns: The removed`ToDoItem` object.
    mutating func delete(with id: String) -> ToDoItem? {
        guard let index = toDoItems.firstIndex(where: { id == $0.id }) else { return nil }
        
        return toDoItems.remove(at: index)
    }
    
    /// Saves the current list of `ToDoItem` objects to a file in the specified format.
    ///
    /// - Parameters:
    ///   - file: The name of the file to save the items to.
    ///   - format: The format of the file (`.json` or `.csv`). Defaults to `.json`.
    /// - Note: The items are saved in a pretty-printed format if the format is `.json`.
    func save(to file: String, format: FileFormat = .json) {
        let path = documentsDirectory
            .appending(path: file)
            .appendingPathExtension(format.rawValue)
        
        switch format {
        case .json:
            saveToJSON(at: path)
        case .csv:
            saveToCSV(at: path)
        }
    }
    
    /// Loads `ToDoItem` objects from a file in the specified format.
    ///
    /// - Parameters:
    ///   - file: The name of the file to load the items from.
    ///   - format: The format of the file (`.json` or `.csv`). Defaults to `.json`.
    /// - Returns: An array of `ToDoItem` objects loaded from the specified file.
    /// - Note: If there is an error reading from the file, an empty array is returned.
    mutating func load(from file: String, format: FileFormat = .json) {
        let path = documentsDirectory
            .appending(path: file)
            .appendingPathExtension(format.rawValue)
        
        print(path)
        
        switch format {
        case .json:
            toDoItems = loadFromJSON(at: path)
        case .csv:
            toDoItems = loadFromCSV(at: path)
        }
    }
}

// MARK: – Saving & Loading
extension FileCache {
    
    // JSON
    private func saveToJSON(at path: URL) {
        let items = toDoItems
            .map { $0.json }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: items, options: .prettyPrinted)
            try data.write(to: path)
        } catch {
            print("Error writing data to a JSON file.")
        }
    }
    
    private func loadFromJSON(at path: URL) -> [ToDoItem] {
        do {
            let data = try Data(contentsOf: path)
            let items = try JSONSerialization.jsonObject(with: data) as! [Any]
            let toDoItems = items.compactMap { ToDoItem.parse(json: $0) }
            
            return toDoItems
        } catch {
            print("Error loading data from a JSON file.")
            
            return []
        }
    }
    
    // CSV
    private func saveToCSV(at path: URL) {
        let fields = ["id", "text", "importance", "dueDate", "isCompleted", "dateCreated", "dateEdited"]
        var data = "\"" + fields.joined(separator: "\",\"") + "\"\n"
        
        data += toDoItems
            .reduce("", { partialResult, toDoItem in
                return partialResult + toDoItem.csv
            })
        
        do {
            try data.write(to: path, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing data to a CSV file.")
        }
    }
    
    private func loadFromCSV(at path: URL) -> [ToDoItem] {
        guard let data = try? String(contentsOf: path) else {
            print("Error loading data from a CSV file.")
            
            return []
        }
        
        let lines = data.components(separatedBy: .newlines).dropFirst()
        let toDoItems: [ToDoItem] = lines.compactMap { ToDoItem.parse(csv: $0) }
        
        return toDoItems
    }
}
