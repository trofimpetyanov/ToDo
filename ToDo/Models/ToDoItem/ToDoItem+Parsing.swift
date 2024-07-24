import Foundation
import SwiftData

extension ToDoItem: JSONRepresentable {
    
    /// A computed property that converts the `ToDoItem` into a JSON-compatible dictionary.
    var json: Any {
        var dictionary: [String: Any] = [
            Properties.id.rawValue: id,
            Properties.text.rawValue: text,
            Properties.isCompleted.rawValue: isCompleted,
            Properties.dateCreated.rawValue: dateCreated.timeIntervalSince1970
        ]
        
        if importance != .basic {
            dictionary[Properties.importance.rawValue] = importance.rawValue
        }
        
        if let dueDate = dueDate {
            dictionary[Properties.dueDate.rawValue] = dueDate.timeIntervalSince1970
        }
        
        if let dateEdited = dateEdited {
            dictionary[Properties.dateEdited.rawValue] = dateEdited.timeIntervalSince1970
        }
        
        if let color = color {
            dictionary[Properties.color.rawValue] = color
        }
        
        return dictionary
    }
    
    /// Parses a JSON-compatible dictionary into a `ToDoItem` instance.
    ///
    /// - Parameter json: The JSON-compatible dictionary to parse.
    /// - Returns: An optional `ToDoItem` if the parsing is successful,
    ///            or `nil` if any required fields are missing or invalid.
    static func parse(json: Any) -> ToDoItem? {
        guard let dictionary = json as? [String: Any],
              let id = dictionary[Properties.id.rawValue] as? String,
              let text = dictionary[Properties.text.rawValue] as? String,
              let dateCreatedTimeInterval = dictionary[Properties.dateCreated.rawValue] as? TimeInterval,
              let isCompleted = dictionary[Properties.isCompleted.rawValue] as? Bool
        else { return nil }
        
        let importance: Importance
        if let importanceRaw = dictionary[Properties.importance.rawValue] as? String {
            importance = Importance(rawValue: importanceRaw) ?? .basic
        } else {
            importance = .basic
        }
        
        let dueDate = Date(anyTimeIntervalSince1970: dictionary[Properties.dueDate.rawValue])
        let dateCreated = Date(anyTimeIntervalSince1970: dateCreatedTimeInterval) ?? Date()
        let dateEdited = Date(anyTimeIntervalSince1970: dictionary[Properties.dateEdited.rawValue])
        
        let color = dictionary[Properties.color.rawValue] as? String
        
        return ToDoItem(
            id: id,
            text: text,
            importance: importance,
            dueDate: dueDate,
            isCompleted: isCompleted,
            color: color,
            dateCreated: dateCreated,
            dateEdited: dateEdited)
    }
}

extension ToDoItem: CSVRepresentable {
    
    /// A computed property that converts the `ToDoItem` into a CSV string.
    var csv: String {
        guard
            let json = json as? [String: Any],
            let lastField = Properties.allCases.last else { return "" }
        var csv = ""
        
        Properties.allCases.forEach { field in
            let value = "\"\(json[field.rawValue] ?? "")\""
            let separator = field != lastField ? "," : "\n"
            csv += value + separator
        }
        
        return csv
    }
    
    /// Parses a CSV string into a `ToDoItem` instance.
    ///
    /// - Parameter csv: The CSV string to parse.
    /// - Returns: An optional `ToDoItem` if the parsing is successful, or `nil` if the format is invalid.
    static func parse(csv: String) -> ToDoItem? {
        let values = csv
            .components(separatedBy: "\",\"")
        
        guard values.count == 8 else { return nil }
        
        let id = "\(values[0].dropFirst())"
        let text = values[1]
        let importance = Importance(rawValue: values[2]) ?? .basic
        let dueDate = Date(anyTimeIntervalSince1970: values[3])
        let isCompleted = Bool(values[4]) ?? false
        let color = values[5]
        let dateCreated = Date(anyTimeIntervalSince1970: values[6]) ?? Date()
        let dateEdited = Date(anyTimeIntervalSince1970: "\(values[7].dropLast())")
        
        return ToDoItem(
            id: id,
            text: text,
            importance: importance,
            dueDate: dueDate,
            isCompleted: isCompleted,
            color: color,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
    }
}
