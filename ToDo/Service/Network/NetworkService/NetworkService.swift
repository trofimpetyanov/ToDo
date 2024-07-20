import Foundation

actor NetworkService: NetworkServiceProtocol {
    
    static let token = "<token>"
    
    private var revision: UInt32 = 0
    
    func getList<Item: Codable & Sendable>() async throws -> [Item] {
        let request = GetListRequest<Item>(revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.list
    }
    
    func patchList<Item: Codable & Sendable>(_ list: [Item]) async throws -> [Item] {
        let request = PatchListRequest<Item>(list: list, revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.list
    }
    
    func getItem<Item: Codable & Sendable>(_ id: String) async throws -> Item {
        let request = GetItemRequest<Item>(id: id, revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.item
    }
    
    func postItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item {
        let request = PostItemRequest<Item>(item: item, revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.item
    }
    
    func putItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item {
        let request = PutItemRequest<Item>(item: item, revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.item
    }
    
    func deleteItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item {
        let request = DeleteItemRequest<Item>(item: item, revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.item
    }
}
