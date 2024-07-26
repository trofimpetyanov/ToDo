import Foundation

extension ToDoItem: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case dueDate = "deadline"
        case isCompleted = "done"
        case color
        case dateCreated = "created_at"
        case dateEdited = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
    
    convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let text = try container.decode(String.self, forKey: .text)
        let importance = try container.decode(Importance.self, forKey: .importance)
        let dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        let isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        let color = try container.decodeIfPresent(String.self, forKey: .color)
        let dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        let dateEdited = try container.decodeIfPresent(Date.self, forKey: .dateEdited)
        let lastUpdatedBy = try container.decodeIfPresent(String.self, forKey: .lastUpdatedBy)
        
        self.init(
            id: id,
            text: text,
            importance: importance,
            dueDate: dueDate,
            isCompleted: isCompleted,
            color: color,
            dateCreated: dateCreated,
            dateEdited: dateEdited,
            lastUpdatedBy: lastUpdatedBy
        )
    }
    
    nonisolated func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(importance, forKey: .importance)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(dateEdited, forKey: .dateEdited)
        try container.encodeIfPresent(lastUpdatedBy, forKey: .lastUpdatedBy)
    }
}
