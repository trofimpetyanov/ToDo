import Foundation

protocol NetworkServiceProtocol {
    mutating func getList<Item: Codable>() async throws -> [Item]
    mutating func patchList<Item: Codable & Sendable>(_ list: [Item]) async throws -> [Item]
    
    mutating func getItem<Item: Codable>(_ id: String) async throws -> Item
    mutating func postItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item
    mutating func putItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item
    mutating func deleteItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item
}
