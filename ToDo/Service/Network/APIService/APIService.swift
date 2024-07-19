import Foundation

// MARK: – List Requests
struct GetListRequest<Item: Codable>: APIRequest {
    typealias Response = ListResponse<Item>
    
    var path: String { "/todo/list" }

    var revision: UInt32
    var token: String
}

struct PatchListRequest<Item: Codable & Sendable>: APIRequest {
    typealias Response = ListResponse<Item>
    
    var list: [Item]
    
    var path: String { "/todo/list" }
    var method: String { "PATCH" }
    
    var revision: UInt32
    var token: String
    
    var data: Data? {
        let listResponse = ListResponse(status: "ok", list: list, revision: revision)
        return try? encoder.encode(listResponse)
    }
}

// MARK: – Item Requests
struct GetItemRequest<Item: Codable>: APIRequest {
    typealias Response = ItemResponse<Item>
    
    var id: String
    
    var path: String { "/todo/list/\(id)" }
    
    var revision: UInt32
    var token: String
}

struct PostItemRequest<Item: Codable & Sendable>: APIRequest {
    typealias Response = ItemResponse<Item>
    
    var item: Item
    
    var path: String { "/todo/list" }
    var method: String { "POST" }
    
    var revision: UInt32
    var token: String
    
    var data: Data? {
        let itemResponse = ItemResponse(status: "ok", item: item, revision: revision)
        return try? encoder.encode(itemResponse)
    }
}

struct PutItemRequest<Item: Codable & Identifiable & Sendable>: APIRequest {
    typealias Response = ItemResponse<Item>
    
    var item: Item
    
    var path: String { "/todo/list/\(item.id)" }
    var method: String { "PUT" }
    
    var revision: UInt32
    var token: String
    
    var data: Data? {
        let itemResponse = ItemResponse(status: "ok", item: item, revision: revision)
        return try? encoder.encode(itemResponse)
    }
}

struct DeleteItemRequest<Item: Codable & Identifiable & Sendable>: APIRequest {
    typealias Response = ItemResponse<Item>
    
    var item: Item
    
    var path: String { "/todo/list/\(item.id)" }
    var method: String { "DELETE" }
    
    var revision: UInt32
    var token: String
    
    var data: Data? {
        let itemResponse = ItemResponse(status: "ok", item: item, revision: revision)
        return try? encoder.encode(itemResponse)
    }
}
