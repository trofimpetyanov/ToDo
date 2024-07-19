import Foundation

struct ItemResponse<Item: Decodable>: @unchecked Sendable {
    let status: String
    let item: Item
    let revision: UInt32
}

extension ItemResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case status
        case item = "element"
        case revision
    }
}
