import Foundation

struct GetListRequest<Item: Decodable>: APIRequest {
    typealias Response = ListResponse<Item>
    
    var path: String { "/todo/list" }

    var revision: UInt32
    var token: String
}

struct PatchListRequest<Item: Codable & Sendable>: APIRequest, Sendable {
    typealias Response = ListResponse<Item>
    
    var list: [Item]
    
    var path: String { "/todo/list" }
    var method: String { "PATCH" }
    
    var revision: UInt32
    var token: String
    
    var data: Data? {
        return try? encoder.encode(list)
    }
}

// swiftlint:disable comment_spacing
//struct GetItemRequest<Item: Decodable>: APIRequest {
//
//}
//
//struct PostItemRequest<Item: Decodable>: APIRequest {
//
//}
//
//struct PutItemRequest<Item: Decodable>: APIRequest {
//
//}
//
//struct DeleteItemRequest<Item: Decodable>: APIRequest {
//
//}
// swiftlint:enable comment_spacing
