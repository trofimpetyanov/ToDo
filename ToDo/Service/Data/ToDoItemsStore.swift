import Foundation
import SwiftData

/// A class that manages a collection of `ToDoItem` objects and provides functionality for adding, updating, deleting, and sorting these items.
class ToDoItemsStore: ObservableObject {
    /// Sorting options for the to-do items.
    enum SortingOption: String, Identifiable, CaseIterable {
        var id: String {
            rawValue
        }
        
        case dateCreated = "По дате добавления"
        case importance = "По важности"
    }
    
    /// Sorting order for the todo items.
    enum SortingOrder: String, Identifiable, CaseIterable {
        var id: String {
            rawValue
        }
        
        case ascending = "По возрастанию"
        case descending = "По убыванию"
    }
    
    static let mock: [ToDoItem] = [
        ToDoItem(text: "Buy groceries", isCompleted: true),
        ToDoItem(text: "Walk the dog named \"Daisy\"", importance: .important, dueDate: Date(timeIntervalSinceNow: 3600)),
        ToDoItem(text: "Read a book", dateCreated: Date(timeIntervalSinceNow: -86400)),
        ToDoItem(text: "Write a blog post", importance: .unimportant),
        ToDoItem(text: "Workout", dueDate: Date(timeIntervalSinceNow: 7200), isCompleted: false),
        ToDoItem(text: "Plan vacation", isCompleted: true, dateEdited: Date(timeIntervalSinceNow: -3600)),
        ToDoItem(text: "Clean the house", importance: .important),
        ToDoItem(text: "Call mom", importance: .ordinary, dueDate: Date(timeIntervalSinceNow: 1800), isCompleted: false)
    ]
    
    private var fileCache: FileCache
    private var toDoItems: [ToDoItem]
    
    /// The current list of to-do items, sorted and filtered based on the current settings.
    @Published var currentToDoItems: [ToDoItem] = []
    
    /// A Boolean value indicating whether completed items should be shown.
    @Published var areCompletedShown: Bool = true {
        didSet {
            updateCurrentToDoItems()
        }
    }
    
    /// The current sorting option for the to-do items.
    @Published var sortingOption: SortingOption = .dateCreated {
        didSet {
            updateCurrentToDoItems()
        }
    }
    
    /// The current sorting order for the to-do items.
    @Published var sortingOrder: SortingOrder = .ascending {
        didSet {
            updateCurrentToDoItems()
        }
    }
    
    /// The number of completed to-do items.
    var completedCount: Int {
        toDoItems
            .filter { $0.isCompleted }
            .count
    }
    
    /// The flag signalizing the first launch of the app.
    var isFirstLaunch: Bool = {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        if launchedBefore {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            return true
        }
    }()
    
    /// Initializes a new instance of `ToDoItemsStore`.
    /// - Note: `ToDoItemsStore` initializes with mock items if there are no todos in the storage.
    init() {
        fileCache = FileCache()
        toDoItems = []
        
        do {
            try fileCache.load(from: "toDoItems")
            toDoItems = fileCache.toDoItems
        } catch {
            if isFirstLaunch {
                Logger.logInfo("First launch detected. Initializing with mock data.")
                
                Self.mock.forEach { toDoItem in
                    fileCache.add(toDoItem)
                }
                
                toDoItems = Self.mock
            } else {
                Logger.logError("Failed to load ToDoItems from file: toDoItems. Error: \(error.localizedDescription)")
            }
        }
        
        toDoItems = fileCache.toDoItems
        updateCurrentToDoItems()
    }
    
    /// Adds a new to-do item to the store.
    /// - Parameter toDoItem: The to-do item to add.
    func add(_ toDoItem: ToDoItem) {
        guard !toDoItems.contains(where: { $0.id == toDoItem.id }) else { return }
        
        toDoItems.append(toDoItem)
        fileCache.add(toDoItem)
        
        updateCurrentToDoItems()
        save()
    }
    
    /// Adds a new to-do item to the store or updates an existing item if it already exists.
    /// - Parameter toDoItem: The to-do item to add or update.
    func addOrUpdate(_ toDoItem: ToDoItem) {
        if let index = toDoItems.firstIndex(where: { toDoItem.id == $0.id }) {
            toDoItems[index] = toDoItem
        } else {
            toDoItems.append(toDoItem)
        }
        
        fileCache.addOrUpdate(toDoItem)
        
        updateCurrentToDoItems()
        save()
    }
    
    /// Deletes a to-do item from the store.
    /// - Parameter toDoItem: The to-do item to delete.
    /// - Returns: The deleted to-do item, or `nil` if the item was not found.
    @discardableResult
    func delete(_ toDoItem: ToDoItem) -> ToDoItem? {
        guard let index = toDoItems.firstIndex(where: { $0.id == toDoItem.id }) else { return nil }
        
        let removedToDoItem = toDoItems.remove(at: index)
        fileCache.delete(with: toDoItem.id)
        
        updateCurrentToDoItems()
        save()
        
        return removedToDoItem
    }
    
    private func save() {
        do {
            try fileCache.save(to: "toDoItems")
        } catch {
            Logger.logError("Failed to save ToDoItems to file: toDoItems. Error: \(error.localizedDescription)")
        }
    }
    
    private func updateCurrentToDoItems() {
        currentToDoItems = toDoItems
        
        switch sortingOption {
        case .importance:
            currentToDoItems = toDoItems.sorted(by: { lhs, rhs in
                lhs.importance < rhs.importance
            })
        case .dateCreated:
            currentToDoItems = toDoItems.sorted(by: { lhs, rhs in
                lhs.dateCreated < rhs.dateCreated
            })
        }
        
        if sortingOrder == .descending {
            currentToDoItems.reverse()
        }
        
        if !areCompletedShown {
            currentToDoItems = currentToDoItems.filter { toDoItem in
                !toDoItem.isCompleted
            }
        }
    }
}
