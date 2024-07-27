import Foundation
import SwiftData
import LoggerPackage

/// A structure for managing `Item` objects in cache, providing methods to add, delete, save, and load items.
@MainActor
struct FileCache<Item: Identifiable & JSONRepresentable & CSVRepresentable & PersistentModel> where Item.ID == String {
    
    enum FileFormat: String {
        case json, csv
    }
    
    private(set) var items: [Item]
    
    private var storage: StorageType {
        SettingsManager.shared.storage
    }
    
    private var swiftDataModelContainer: ModelContainer
    private var sqliteModelContainer: any SQLiteModelContainer<Item>
    
    private var context: ModelContext {
        swiftDataModelContainer.mainContext
    }
    
    private var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    init(
        items: [Item] = [],
        swiftDataModelContainer: ModelContainer,
        sqliteModelContainer: any SQLiteModelContainer<Item>
    ) {
        self.items = items
        self.swiftDataModelContainer = swiftDataModelContainer
        self.sqliteModelContainer = sqliteModelContainer
    }
    
    mutating func fetch(predicate: Predicate<Item>? = nil, sortBy descriptors: [SortDescriptor<Item>] = []) throws {
        switch storage {
        case .file:
            try load(from: "storage")
        case .swiftData:
            let fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: descriptors)
            
            try load(fetchDescriptor)
        case .sqlite:
            items = try sqliteModelContainer.load()
        }
    }
    
    func save() throws {
        switch storage {
        case .file:
            try save(to: "storage")
        case .swiftData:
            try context.save()
        default:
            break
        }
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
        insert(item)
        
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
            insert(item)
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
        
        delete(items[index])
        return items.remove(at: index)
    }
    
    mutating func clear() throws {
        items = []
        
        switch storage {
        case .swiftData:
            try context.delete(model: Item.self)
        case .sqlite:
            try sqliteModelContainer.clear()
        default:
            break
        }
    }
}

// MARK: – Saving & Loading
extension FileCache {
    
    private func save(to file: String, format: FileFormat = .json) throws {
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
    
    private mutating func load(from file: String, format: FileFormat = .json) throws {
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

// MARK: – Data Base Methods
extension FileCache {
    
    private func insert(_ item: Item) {
        switch storage {
        case .swiftData:
            context.insert(item)
        case .sqlite:
            sqliteModelContainer.add(item)
        default:
            break
        }
    }
    
    private func delete(_ item: Item) {
        switch storage {
        case .swiftData:
            context.delete(item)
        case .sqlite:
            sqliteModelContainer.delete(with: item.id)
        default:
            break
        }
    }
    
    private func update(_ item: Item) {
        switch storage {
        case .sqlite:
            sqliteModelContainer.update(item)
        default:
            break
        }
    }
    
    private mutating func load(_ descriptor: FetchDescriptor<Item> = FetchDescriptor()) throws {
        items = try context.fetch(descriptor)
    }
}
