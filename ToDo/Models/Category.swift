import SwiftUI
import SwiftData

@Model
class Category: Hashable, Identifiable {
    let id: String
    let name: String
    let color: String
    
    init(id: String = UUID().uuidString, name: String, color: String) {
        self.id = id
        self.name = name
        self.color = color
    }
    
    static let other = Category(id: "0", name: "Другое", color: "00000000")
}
