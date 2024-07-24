import Foundation
import LoggerPackage

/// A structure for managing `Item` objects in cache, providing methods to add, delete, save, and load items.
@MainActor
struct FileCache<Item: Identifiable & JSONRepresentable & CSVRepresentable> where Item.ID == String {
    
    enum FileFormat: String {
        case json, csv
    }
    
    private(set) var items: [Item] = []
    
    private var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    /// Adds a new `Item` to the cache.
    ///
    /// - Parameter item: The `Item` to be added.
    /// - Note: If an item with the same `id` already exists in the cache, it will not be added.
    mutating func add(_ item: Item, ignoreLog: Bool = false) {
        guard !items.contains(where: { item.id == $0.id }) else {
            Logger.logDebug("Item with ID \(item.id) already exists. Not adding.")
            
            return
        }
        
        items.append(item)
        
        if !ignoreLog {
            Logger.logDebug("Added Item with ID \(item.id) to cache.")
        }
    }
    
    /// Updates an existing `Item` in the cache or adds a new one if it does not exist.
    ///
    /// - Parameter item: The `Item` to be updated or added.
    /// - Note: If an item with the same `id` already exists in the cache, it will be updated. 
    ///         Otherwise, the item will be added to the beginning of the list.
    mutating func addOrUpdate(_ item: Item) {
        if let index = items.firstIndex(where: { item.id == $0.id }) {
            items[index] = item
            
            Logger.logDebug("Updated Item: \(item.id).")
        } else {
            items.append(item)
        }
    }
    
    /// Deletes a `Item` from the cache by its `id`.
    ///
    /// - Parameter id: The `id` of the `Item` to be deleted.
    /// - Returns: The removed`Item` object.
    @discardableResult
    mutating func delete(with id: String) -> Item? {
        guard let index = items.firstIndex(where: { id == $0.id }) else {
            Logger.logDebug("Item with ID \(id) not found. Delete operation failed.")
            
            return nil
        }
        
        Logger.logDebug("Deleted Item with ID \(id) from cache.")
        
        return items.remove(at: index)
    }
    
    /// Saves the current list of `Item` objects to a file in the specified format.
    ///
    /// - Parameters:
    ///   - file: The name of the file to save the items to.
    ///   - format: The format of the file (`.json` or `.csv`). Defaults to `.json`.
    /// - Throws: An error if the save operation fails. 
    ///           Possible errors include file write errors or serialization errors.
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
        
        Logger.logDebug("Saved Items to file: \(file).\(format.rawValue)")
    }
    
    /// Loads `Item` objects from a file in the specified format.
    ///
    /// - Parameters:
    ///   - file: The name of the file to load the items from.
    ///   - format: The format of the file (`.json` or `.csv`). Defaults to `.json`.
    /// - Returns: An array of `Item` objects loaded from the specified file.
    /// - Throws: An error if the load operation fails. 
    ///           Possible errors include file read errors or deserialization errors.
    /// - Note: If there is an error reading from the file, an empty array is returned.
    mutating func load(from file: String, format: FileFormat = .json) throws {
        let path = documentsDirectory
            .appending(path: file)
            .appendingPathExtension(format.rawValue)
        
        switch format {
        case .json:
            items = try loadFromJSON(at: path)
        case .csv:
            items = try loadFromCSV(at: path)
        }
        
        Logger.logDebug("Loaded Items from file: \(file).\(format.rawValue)")
    }
    
    mutating func clear() {
        items = []
    }
}

// MARK: – Saving & Loading
extension FileCache {
    
    // JSON
    private func saveToJSON(at path: URL) throws {
        let items = items
            .map { $0.json }
        
        let data = try JSONSerialization.data(withJSONObject: items, options: .prettyPrinted)
        try data.write(to: path)
    }
    
    private func loadFromJSON(at path: URL) throws -> [Item] {
        let data = try Data(contentsOf: path)
        
        guard let object = try JSONSerialization.jsonObject(with: data) as? [Any] else { return [] }
        let items = object.compactMap { Item.parse(json: $0) }
        
        return items
    }
    
    // CSV
    private func saveToCSV(at path: URL) throws {
        let fields = ["id", "text", "importance", "dueDate", "isCompleted", "dateCreated", "dateEdited"]
        var data = "\"" + fields.joined(separator: "\",\"") + "\"\n"
        
        data += items
            .reduce("", { partialResult, item in
                return partialResult + item.csv
            })
        
        try data.write(to: path, atomically: true, encoding: .utf8)
    }
    
    private func loadFromCSV(at path: URL) throws -> [Item] {
        let data = try String(contentsOf: path)
        
        let lines = data.components(separatedBy: .newlines).dropFirst()
        let items: [Item] = lines.compactMap { Item.parse(csv: $0) }
        
        return items
    }
}
