import Foundation

struct ListResponse<Item: Codable>: APIResponse, @unchecked Sendable {
    let status: String
    let list: [Item]
    let revision: UInt32
}

extension ListResponse: Codable { }
