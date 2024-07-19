import Foundation

@MainActor
struct NetworkService: NetworkServiceProtocol {
    
    static let token = "Faenor"
    static private(set) var shared = NetworkService()
    
    private var revision: UInt32 = 0 {
        didSet {
            print(revision)
        }
    }
    
    // swiftlint:disable:next unneeded_synthesized_initializer
    private init() { }
    
    mutating func getList<Item: Codable & Sendable>() async throws -> [Item] {
        let request = GetListRequest<Item>(revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.list
    }
    
    mutating func patchList<Item: Codable & Sendable>(_ list: [Item]) async throws -> [Item] {
        let request = PatchListRequest<Item>(list: list, revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.list
    }
    
    mutating func getItem<Item: Codable & Sendable>(_ id: String) async throws -> Item {
        let request = GetItemRequest<Item>(id: id, revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.item
    }
    
    mutating func postItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item {
        let request = PostItemRequest<Item>(item: item, revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.item
    }
    
    mutating func putItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item {
        let request = PutItemRequest<Item>(item: item, revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.item
    }
    
    mutating func deleteItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item {
        let request = DeleteItemRequest<Item>(item: item, revision: revision, token: Self.token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.item
    }
}
