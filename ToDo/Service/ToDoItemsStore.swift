import Foundation

class ToDoItemsStore: ObservableObject {
    var fileCache: FileCache
    @Published var toDoItems: [ToDoItem]
    
    init() {
        fileCache = FileCache()
        toDoItems = []
        
        do {
            try fileCache.load(from: "toDoItems")
            toDoItems = fileCache.toDoItems
        } catch {
            print("ToDoItemsStore: Error loading toDoItems from the file. Setting up with the mock items.")
            
            toDoItems = FileCache.mock
            save()
        }
    }
    
    func add(_ toDoItem: ToDoItem) {
        guard !toDoItems.contains(where: { $0.id == toDoItem.id }) else { return }
        
        toDoItems.append(toDoItem)
        fileCache.add(toDoItem)
        
        save()
    }
    
    func addOrUpdate(_ toDoItem: ToDoItem) {
        if let index = toDoItems.firstIndex(where: { toDoItem.id == $0.id }) {
            toDoItems[index] = toDoItem
        } else {
            toDoItems.append(toDoItem)
        }
        
        fileCache.addOrUpdate(toDoItem)
        
        save()
    }
    
    @discardableResult
    func delete(_ toDoItem: ToDoItem) -> ToDoItem? {
        guard let index = toDoItems.firstIndex(where: { $0.id == toDoItem.id }) else { return nil }
        
        fileCache.delete(with: toDoItem.id)
        save()
        
        return toDoItems.remove(at: index)
    }
    
    private func save() {
        do {
            try fileCache.save(to: "toDoItems")
        } catch {
            print("ToDoItemsStore: Error saving toDoItems to the file.")
        }
    }
}
