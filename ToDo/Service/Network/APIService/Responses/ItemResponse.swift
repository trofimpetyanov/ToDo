import Foundation

struct ItemResponse<Item: Codable>: APIResponse, @unchecked Sendable {
    let status: String
    let item: Item
    let revision: UInt32
}

extension ItemResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case status
        case item = "element"
        case revision
    }
}
