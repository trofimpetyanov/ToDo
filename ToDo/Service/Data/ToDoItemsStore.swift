import Foundation
import SwiftData
import LoggerPackage

/// A class that manages a collection of `ToDoItem` objects 
/// and provides functionality for adding, updating, deleting, and sorting these items.
@MainActor
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
        ToDoItem(text: "Buy groceries", isCompleted: true, color: "00FF44"),
        ToDoItem(text: "Walk \"Daisy\"", importance: .important, dueDate: Date(timeIntervalSinceNow: 3600)),
        ToDoItem(text: "Read a book", dateCreated: Date(timeIntervalSinceNow: -86400)),
        ToDoItem(text: "Write a blog post", importance: .low),
        ToDoItem(text: "Workout", dueDate: Date(timeIntervalSinceNow: 7200), isCompleted: false, color: "00DDFF"),
        ToDoItem(text: "Plan vacation", isCompleted: true, dateEdited: Date(timeIntervalSinceNow: -3600)),
        ToDoItem(text: "Clean the house", importance: .important, color: "FF0077"),
        ToDoItem(text: "Call mom", importance: .basic, dueDate: Date(timeIntervalSinceNow: 1800), isCompleted: false)
    ]
    
    var isPatchingEnabled = false
    
    var networkManager: ToDoItemsNetworkManager
    
    /// The number of completed to-do items.
    var completedCount: Int {
        toDoItems
            .filter { $0.isCompleted }
            .count
    }
    
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
    
    private var isDirty: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isDirty")
        } set {
            UserDefaults.standard.setValue(newValue, forKey: "isDirty")
        }
    }

    private var toDoItems: [ToDoItem]
    private var fileCache: FileCache
    
    /// Initializes a new instance of `ToDoItemsStore`.
    init() {
        fileCache = FileCache()
        toDoItems = []
        
        let networkService = NetworkService()
        networkManager = ToDoItemsNetworkManager(networkService: networkService)
        
        Task {
            await load()
        }
    }
    
    func load() async {
        if let toDoItems = await networkManager.loadItems() {
            self.toDoItems = toDoItems
            
            Task(priority: .utility) {
                fileCache.clear()
                toDoItems.forEach { toDoItem in
                    fileCache.add(toDoItem)
                }
                
                save()
            }
        } else {
            Logger.logError(
                "Failed to load ToDoItems from the server. Loading from cache.")
            
            do {
                try fileCache.load(from: "toDoItems")
                toDoItems = fileCache.toDoItems
                
                isDirty = true
                if isPatchingEnabled { await patch() }
            } catch {
                Logger.logError(
                    "Failed to load ToDoItems from the file \"toDoItems\". Error: \(error.localizedDescription)")
            }
        }
        
        updateCurrentToDoItems()
    }
    
    /// Adds a new to-do item to the store.
    /// - Parameter toDoItem: The to-do item to add.
    func add(_ toDoItem: ToDoItem) async {
        if isPatchingEnabled { await patch() }
        
        guard !toDoItems.contains(where: { $0.id == toDoItem.id }) else { return }
        
        toDoItems.append(toDoItem)
        fileCache.add(toDoItem)
        
        updateCurrentToDoItems()
        
        isDirty = await !networkManager.add(toDoItem)
        
        save()
    }
    
    /// Adds a new to-do item to the store or updates an existing item if it already exists.
    /// - Parameter toDoItem: The to-do item to add or update.
    func addOrUpdate(_ toDoItem: ToDoItem) async {
        if isPatchingEnabled { await patch() }
        fileCache.addOrUpdate(toDoItem)
        
        if let index = toDoItems.firstIndex(where: { toDoItem.id == $0.id }) {
            toDoItems[index] = toDoItem
            updateCurrentToDoItems()
            
            isDirty = await !networkManager.update(toDoItem)
        } else {
            toDoItems.append(toDoItem)
            updateCurrentToDoItems()
            
            isDirty = await !networkManager.add(toDoItem)
        }
        
        save()
    }
    
    /// Deletes a to-do item from the store.
    /// - Parameter toDoItem: The to-do item to delete.
    /// - Returns: The deleted to-do item, or `nil` if the item was not found.
    @discardableResult
    func delete(_ toDoItem: ToDoItem) async -> ToDoItem? {
        if isPatchingEnabled { await patch() }
        
        guard let index = toDoItems.firstIndex(where: { $0.id == toDoItem.id }) else { return nil }
        
        let removedToDoItem = toDoItems.remove(at: index)
        fileCache.delete(with: toDoItem.id)
        
        updateCurrentToDoItems()
        
        isDirty = await !networkManager.delete(toDoItem)
        
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
    
    private func patch() async {
        if isDirty, let toDoItems = await networkManager.patchItems(toDoItems) {
            self.toDoItems = toDoItems
            isDirty = false
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
