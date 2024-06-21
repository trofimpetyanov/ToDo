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
              let isCompleted = dictionary["isCompleted"] as? Bool
        else { return nil }
        
        let importance: Importance
        if let importanceRaw = dictionary["importance"] as? String {
            importance = Importance(rawValue: importanceRaw) ?? .ordinary
        } else {
            importance = .ordinary
        }
        
        let dueDate: Date?
        if let dueDateTimestamp = dictionary["dueDate"] as? TimeInterval {
            dueDate = Date(timeIntervalSince1970: dueDateTimestamp)
        } else {
            dueDate = nil
        }
        
        let dateEdited: Date?
        if let dateEditedTimestamp = dictionary["dateEdited"] as? TimeInterval {
            dateEdited = Date(timeIntervalSince1970: dateEditedTimestamp)
        } else {
            dateEdited = nil
        }
        
        return ToDoItem(
            id: id,
            text: text,
            importance: importance,
            dueDate: dueDate,
            isCompleted: isCompleted,
            dateEdited: dateEdited
        )
    }
    
    /// A computed property that converts the `ToDoItem` into a JSON-compatible dictionary.
    ///
    /// The resulting dictionary contains the `id`, `text`, and `isCompleted` properties.
    /// If the `importance` property is not `.ordinary`, it is also included.
    /// If the `dueDate` property is set, it is included as a time interval since 1970.
    var json: Any {
        var dictionary: [String: Any] = [
            "id": id,
            "text": text,
            "isCompleted": isCompleted
        ]
        
        if importance != .ordinary {
            dictionary["importance"] = importance.rawValue
        }
        
        if let dueDate = dueDate {
            dictionary["dueDate"] = dueDate.timeIntervalSince1970
        }
        
        return dictionary
    }
}
