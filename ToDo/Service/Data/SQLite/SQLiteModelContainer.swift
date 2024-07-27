import Foundation

protocol SQLiteModelContainer<Item> {
    associatedtype Item
    
    func add(_ item: Item)
    func load() throws -> [Item]
    func update(_ item: Item)
    func delete(with id: String)
    func clear() throws
}
