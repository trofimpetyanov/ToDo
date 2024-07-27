import Foundation

@MainActor
class NetworkService: NetworkServiceProtocol {
    
    typealias ItemType = Codable & Sendable
    typealias IdentifiableItemType = ItemType & Identifiable
    
    var token: String {
        SettingsManager.shared.token
    }
    
    private var revision: UInt32 = 0
    
    func getList<Item: ItemType>() async throws -> [Item] {
        let request = GetListRequest<Item>(revision: 0, token: token)
        
        let result = try await request.send()
        revision = result.revision
        
        return result.list
    }
    
    func patchList<Item: ItemType>(_ list: [Item]) async throws -> [Item] {
        let request = PatchListRequest<Item>(list: list, revision: revision, token: token)
        
        let result = try await retryingRequest(request)
        revision = result.revision
        
        return result.list
    }
    
    func getItem<Item: ItemType>(_ id: String) async throws -> Item {
        let request = GetItemRequest<Item>(id: id, revision: 0, token: token)
        
        let result = try await retryingRequest(request)
        revision = result.revision
        
        return result.item
    }
    
    func postItem<Item: IdentifiableItemType>(_ item: Item) async throws -> Item {
        let request = PostItemRequest<Item>(item: item, revision: revision, token: token)
        
        let result = try await retryingRequest(request)
        revision = result.revision
        
        return result.item
    }
    
    func putItem<Item: IdentifiableItemType>(_ item: Item) async throws -> Item {
        let request = PutItemRequest<Item>(item: item, revision: revision, token: token)
        
        let result = try await retryingRequest(request)
        revision = result.revision
        
        return result.item
    }
    
    func deleteItem<Item: IdentifiableItemType>(_ item: Item) async throws -> Item {
        let request = DeleteItemRequest<Item>(item: item, revision: revision, token: token)
        
        let result = try await retryingRequest(request)
        revision = result.revision
        
        return result.item
    }
    
    private func updateRevision<Item: ItemType>(_ item: Item.Type) async {
        let request = GetListRequest<Item>(revision: 0, token: token)
        
        guard let result = try? await request.send() else { return }
        revision = result.revision
    }
    
    private func retryingRequest<Request: APIRequest>(
        _ request: Request
    ) async throws -> Request.Response where Request.Response: Codable, Request.Response.Item: ItemType {
        try await Task.retrying { [weak self] in
            do {
                guard let revision = await self?.revision else {
                    throw APIRequestError.badRevision
                }
                
                var newRequest = request
                newRequest.revision = revision
                
                return try await newRequest.send()
            } catch APIRequestError.badRevision {
                await self?.updateRevision(Request.Response.Item.self)
                
                throw APIRequestError.badRevision
            } catch {
                throw error
            }
        }.value
    }
}
