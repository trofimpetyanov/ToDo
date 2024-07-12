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
}

extension Category {
    static let other = Category(id: "0", name: "Другое", color: "00000000")
    
    static let template = [
        Category(id: "1", name: "Работа", color: "FC2B2D"),
        Category(id: "2", name: "Учеба", color: "106BFF"),
        Category(id: "3", name: "Хобби", color: "30D33B"),
        Category(id: "0", name: "Другое", color: "00000000")
    ]
}
