import Foundation

/// A class that manages a collection of `ToDoItem` objects and provides functionality for adding, updating, deleting, and sorting these items.
class ToDoItemsStore: ObservableObject {
    /// Sorting options for the to-do items.
    enum SortingOption: String, Identifiable, CaseIterable {
        var id: String {
            rawValue
        }
        
        case dateAdded = "По дате добавления"
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
    @Published var sortingOption: SortingOption = .dateAdded {
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
    
    /// Initializes a new instance of `ToDoItemsStore`.
    init() {
        fileCache = FileCache()
        toDoItems = []
        
        do {
            try fileCache.load(from: "toDoItems")
            toDoItems = fileCache.toDoItems
        } catch {
            print("ToDoItemsStore: Failure while loading toDoItems from the file. It is normal if it is the first launch.")
        }
        
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
            print("ToDoItemsStore: Error saving toDoItems to the file.")
        }
    }
    
    private func updateCurrentToDoItems() {
        currentToDoItems = toDoItems
        
        switch sortingOption {
        case .importance:
            currentToDoItems = toDoItems.sorted(by: { lhs, rhs in
                lhs.importance < rhs.importance
            })
        case .dateAdded:
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
