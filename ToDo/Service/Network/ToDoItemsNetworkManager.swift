import Foundation
import LoggerPackage

actor ToDoItemsNetworkManager {
    
    private(set) var isLoading = false
    
    private var networkService: NetworkServiceProtocol
    
    private var activeRequests = 0 {
        didSet {
            isLoading = activeRequests != 0
        }
    }
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func loadItems() async -> [ToDoItem]? {
        activeRequests += 1
        defer { activeRequests -= 1 }
        
        do {
            let items: [ToDoItem] = try await networkService.getList()
            
            Logger.logInfo("Successfully loaded toDoItems.")
            
            return items
        } catch {
            Logger.logError("Could not load toDoItems: \(error.localizedDescription)")
            
            return nil
        }
    }
    
    func patchItems(_ items: [ToDoItem]) async -> [ToDoItem]? {
        activeRequests += 1
        defer { activeRequests -= 1 }
        
        do {
            let patchedItems = try await networkService.patchList(items)
            
            Logger.logInfo("Successfully patched toDoItems.")
            
            return patchedItems
        } catch {
            Logger.logError("Could not patch toDoItems: \(error.localizedDescription)")
            
            return nil
        }
    }
    
    func add(_ item: ToDoItem) async -> Bool {
        activeRequests += 1
        defer { activeRequests -= 1 }
        
        do {
            try await networkService.postItem(item)
            Logger.logInfo("Successfully added toDoItem: \(item.id)")
            
            return true
        } catch APIRequestError.badRevision {
            Logger.logError("Bad revision error while adding toDoItem: \(item.id)")
        } catch {
            Logger.logError("Unknown error while adding toDoItem: \(item.id). Error: \(error.localizedDescription)")
        }
        
        return false
    }
    
    func update(_ item: ToDoItem) async -> Bool {
        activeRequests += 1
        defer { activeRequests -= 1 }
        
        do {
            try await networkService.putItem(item)
            Logger.logInfo("Successfully updated toDoItem: \(item.id)")
            
            return true
        } catch APIRequestError.itemNotFound {
            Logger.logError("Item not found error while updating toDoItem: \(item.id)")
        } catch APIRequestError.badRevision {
            Logger.logError("Bad revision error while updating toDoItem: \(item.id)")
        } catch {
            Logger.logError("Unknown error while updating toDoItem: \(item.id). Error: \(error.localizedDescription)")
        }
        
        return false
    }
    
    func delete(_ item: ToDoItem) async -> Bool {
        activeRequests += 1
        defer { activeRequests -= 1 }
        
        do {
            try await networkService.deleteItem(item)
            Logger.logInfo("Successfully deleted toDoItem: \(item.id)")
            
            return true
        } catch APIRequestError.itemNotFound {
            Logger.logError("Item not found error while deleting toDoItem: \(item.id)")
        } catch APIRequestError.badRevision {
            Logger.logError("Bad revision error while deleting toDoItem: \(item.id)")
        } catch {
            Logger.logError("Unknown error while deleting toDoItem: \(item.id). Error: \(error.localizedDescription)")
        }
        
        return false
    }
}
