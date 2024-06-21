import XCTest
@testable import ToDo

final class ToDoItemTests: XCTestCase {
    
    func testToDoItemInitialization() {
        // Given
        let id = "1"
        let text = "Test"
        let importance = Importance.important
        let dueDate = Date(timeIntervalSinceNow: 86400)
        let isCompleted = false
        let dateCreated = Date()
        let dateEdited = Date()
        
        // When
        let toDoItem = ToDoItem(
            id: id,
            text: text,
            importance: importance,
            dueDate: dueDate,
            isCompleted: isCompleted,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
        
        // Then
        XCTAssertEqual(toDoItem.id, id)
        XCTAssertEqual(toDoItem.text, text)
        XCTAssertEqual(toDoItem.importance, importance)
        XCTAssertEqual(toDoItem.dueDate, dueDate)
        XCTAssertEqual(toDoItem.isCompleted, isCompleted)
        XCTAssertEqual(toDoItem.dateCreated, dateCreated)
        XCTAssertEqual(toDoItem.dateEdited, dateEdited)
    }
    
    func testToDoItemJSONConversion() {
        // Given
        let id = "1"
        let text = "Test"
        let importance = Importance.important
        let dueDate = Date(timeIntervalSinceNow: 86400)
        let isCompleted = false
        let dateCreated = Date()
        let dateEdited = Date()
        
        let toDoItem = ToDoItem(
            id: id,
            text: text,
            importance: importance,
            dueDate: dueDate,
            isCompleted: isCompleted,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
        
        // When
        let json = toDoItem.json
        
        // Then
        guard let jsonDictionary = json as? [String: Any] else {
            XCTFail("Error converting json to a `[String: Any]` dictionary.")
            return
        }
        
        XCTAssertEqual(jsonDictionary["id"] as? String, id)
        XCTAssertEqual(jsonDictionary["text"] as? String, text)
        XCTAssertEqual(jsonDictionary["importance"] as? String, importance.rawValue)
        XCTAssertEqual(jsonDictionary["dueDate"] as? TimeInterval, dueDate.timeIntervalSince1970)
        XCTAssertEqual(jsonDictionary["isCompleted"] as? Bool, isCompleted)
        XCTAssertEqual(jsonDictionary["dateCreated"] as? TimeInterval, dateCreated.timeIntervalSince1970)
        XCTAssertEqual(jsonDictionary["dateEdited"] as? TimeInterval, dateEdited.timeIntervalSince1970)
    }
    
    func testToDoItemJSONParsing() {
        // Given
        let json: [String: Any] = [
            "id": "1",
            "text": "Test",
            "importance": "important",
            "dueDate": 1719066998.1372972,
            "isCompleted": false,
            "dateCreated": 1719065998.1372972,
            "dateEdited": 1719065998.1372972
        ]
        
        // When
        guard let toDoItem = ToDoItem.parse(json: json) else {
            XCTFail("Error parsing json to `ToDoItem`.")
            return
        }
        
        // Then
        XCTAssertEqual(toDoItem.id, json["id"] as? String)
        XCTAssertEqual(toDoItem.text, json["text"] as? String)
        XCTAssertEqual(toDoItem.importance.rawValue, json["importance"] as? String)
        XCTAssertEqual(toDoItem.dueDate?.timeIntervalSince1970, json["dueDate"] as? TimeInterval)
        XCTAssertEqual(toDoItem.isCompleted, json["isCompleted"] as? Bool)
        XCTAssertEqual(toDoItem.dateCreated.timeIntervalSince1970, json["dateCreated"] as? TimeInterval)
        XCTAssertEqual(toDoItem.dateEdited?.timeIntervalSince1970, json["dateEdited"] as? TimeInterval)
    }
}
