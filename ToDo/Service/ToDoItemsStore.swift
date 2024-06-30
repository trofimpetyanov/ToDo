import Foundation

class ToDoItemsStore: ObservableObject {
    enum SortingOption: String, Identifiable, CaseIterable {
        var id: String {
            rawValue
        }
        
        case dateAdded = "По дате добавления"
        case importance = "По важности"
    }
    
    enum SortingOrder: String, Identifiable, CaseIterable {
        var id: String {
            rawValue
        }
        
        case ascending = "По возрастанию"
        case descending = "По убыванию"
    }
    
    private var fileCache: FileCache
    private var toDoItems: [ToDoItem]
    
    @Published var currentToDoItems: [ToDoItem] = []
    
    @Published var areCompletedShown: Bool = true {
        didSet {
            updateCurrentToDoItems()
        }
    }
    
    @Published var sortingOption: SortingOption = .dateAdded {
        didSet {
            updateCurrentToDoItems()
        }
    }
    
    @Published var sortingOrder: SortingOrder = .ascending {
        didSet {
            updateCurrentToDoItems()
        }
    }
    
    var completedCount: Int {
        toDoItems
            .filter { $0.isCompleted }
            .count
    }
    
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
    
    func add(_ toDoItem: ToDoItem) {
        guard !toDoItems.contains(where: { $0.id == toDoItem.id }) else { return }
        
        toDoItems.append(toDoItem)
        fileCache.add(toDoItem)
        
        updateCurrentToDoItems()
        save()
    }
    
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
