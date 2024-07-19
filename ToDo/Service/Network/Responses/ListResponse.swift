import Foundation

struct ListResponse<Item: Decodable>: @unchecked Sendable {
    let status: String
    let list: [Item]
    let revision: UInt32
}

extension ListResponse: Decodable { }
