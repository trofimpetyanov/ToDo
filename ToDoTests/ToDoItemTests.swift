import XCTest
@testable import ToDo

final class ToDoItemTests: XCTestCase {
    
    func testInitializationWithAllProperties() {
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
    
    func testToDoItemInitializationWithRequiredProperties() {
        // Given
        let id = "1"
        let text = "Test"
        let isCompleted = false
        
        // When
        let toDoItem = ToDoItem(text: "Test")
        
        // Then
        XCTAssertEqual(toDoItem.text, text)
        XCTAssertEqual(toDoItem.importance, .ordinary)
        XCTAssertNil(toDoItem.dueDate)
        XCTAssertEqual(toDoItem.isCompleted, false)
        XCTAssertNil(toDoItem.dateEdited)
    }
    
    func testJSONConversion() {
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
    
    func testJSONParsing() {
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
    
    func testCSVParsing() {
        // Given
        let csv = "\"123\",\"Test Task\",\"important\",\"1609459200\",\"true\",\"1609455600\",\"1609462800\""
        
        // When
        guard let item = ToDoItem.parse(csv: csv) else {
            XCTFail("Failed to parse CSV")
            return
        }
        
        // Then
        XCTAssertEqual(item.id, "123")
        XCTAssertEqual(item.text, "Test Task")
        XCTAssertEqual(item.importance, .important)
        XCTAssertEqual(item.dueDate?.timeIntervalSince1970, 1609459200)
        XCTAssertEqual(item.isCompleted, true)
        XCTAssertEqual(item.dateCreated.timeIntervalSince1970, 1609455600)
        XCTAssertEqual(item.dateEdited?.timeIntervalSince1970, 1609462800)
    }
    
    func testCSVConversion() {
        // Given
        let dateCreated = Date(timeIntervalSince1970: 1609455600)
        let dueDate = Date(timeIntervalSince1970: 1609459200)
        let dateEdited = Date(timeIntervalSince1970: 1609462800)
        
        let item = ToDoItem(
            id: "123",
            text: "Test Task",
            importance: .important,
            dueDate: dueDate,
            isCompleted: true,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
        
        // When
        let csv = item.csv
        
        // Then
        let expectedCSV = "\"123\",\"Test Task\",\"important\",\"1609459200.0\",\"true\",\"1609455600.0\",\"1609462800.0\"\n"
        XCTAssertEqual(csv, expectedCSV)
    }
    
    func testParseInvalidCSV() {
        // Given
        let invalidCSV = "\"123\",\"Test Task\",\"high\",\"1609459200\",\"true\",\"1609455600\""
        
        // When
        let item = ToDoItem.parse(csv: invalidCSV)
        
        // Then
        XCTAssertNil(item)
    }
}
