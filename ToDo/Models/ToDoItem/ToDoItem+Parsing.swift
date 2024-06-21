import Foundation

extension ToDoItem {
    
    /// Parses a JSON-compatible dictionary into a `ToDoItem` instance.
    ///
    /// - Parameter json: The JSON-compatible dictionary to parse.
    /// - Returns: An optional `ToDoItem` if the parsing is successful, or `nil` if any required fields are missing or invalid.
    static func parse(json: Any) -> ToDoItem? {
        guard let dictionary = json as? [String: Any],
              let id = dictionary["id"] as? String,
              let text = dictionary["text"] as? String,
              let dateCreatedTimeInterval = dictionary["dateCreated"] as? TimeInterval,
              let isCompleted = dictionary["isCompleted"] as? Bool
        else { return nil }
        
        let importance: Importance
        if let importanceRaw = dictionary["importance"] as? String {
            importance = Importance(rawValue: importanceRaw) ?? .ordinary
        } else {
            importance = .ordinary
        }
        
        let dueDate = Date(anyTimeIntervalSince1970: dictionary["dueDate"])
        let dateCreated = Date(anyTimeIntervalSince1970: dateCreatedTimeInterval) ?? Date()
        let dateEdited = Date(anyTimeIntervalSince1970: dictionary["dateEdited"])
        
        return ToDoItem(
            id: id,
            text: text,
            importance: importance,
            dueDate: dueDate,
            isCompleted: isCompleted,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
    }
    
    /// A computed property that converts the `ToDoItem` into a JSON-compatible dictionary.
    var json: Any {
        var dictionary: [String: Any] = [
            "id": id,
            "text": text,
            "isCompleted": isCompleted,
            "dateCreated": dateCreated.timeIntervalSince1970
        ]
        
        if importance != .ordinary {
            dictionary["importance"] = importance.rawValue
        }
        
        if let dueDate = dueDate {
            dictionary["dueDate"] = dueDate.timeIntervalSince1970
        }
        
        if let dateEdited = dateEdited {
            dictionary["dateEdited"] = dateEdited.timeIntervalSince1970
        }
        
        return dictionary
    }
}
