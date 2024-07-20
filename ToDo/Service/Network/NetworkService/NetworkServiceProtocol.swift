import Foundation

protocol NetworkServiceProtocol: Sendable {
    func getList<Item: Codable>() async throws -> [Item]
    func patchList<Item: Codable & Sendable>(_ list: [Item]) async throws -> [Item]
    
    @discardableResult 
    func getItem<Item: Codable>(_ id: String) async throws -> Item
    
    @discardableResult
    func postItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item
    
    @discardableResult
    func putItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item
    
    @discardableResult
    func deleteItem<Item: Codable & Identifiable & Sendable>(_ item: Item) async throws -> Item
}
