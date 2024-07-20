import XCTest
@testable import ToDo

final class ToDoItemTests: XCTestCase {
    
    @MainActor
    func testInitializationWithAllProperties() {
        // Given
        let id = "1"
        let text = "Test"
        let importance = Importance.important
        let dueDate = Date(timeIntervalSinceNow: 86400).clean
        let isCompleted = false
        let color = "ED3ED3"
        let dateCreated = Date().clean
        let dateEdited = Date().clean
        
        // When
        let toDoItem = ToDoItem(
            id: id,
            text: text,
            importance: importance,
            dueDate: dueDate,
            isCompleted: isCompleted,
            color: color,
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
    
    @MainActor
    func testToDoItemInitializationWithRequiredProperties() {
        // Given
        let text = "Test"
        
        // When
        let toDoItem = ToDoItem(text: "Test")
        
        // Then
        XCTAssertEqual(toDoItem.text, text)
        XCTAssertEqual(toDoItem.importance, .basic)
        XCTAssertNil(toDoItem.dueDate)
        XCTAssertEqual(toDoItem.isCompleted, false)
        XCTAssertNil(toDoItem.color)
    }
    
    @MainActor
    func testJSONConversion() {
        // Given
        let id = "1"
        let text = "Test"
        let importance = Importance.important
        let dueDate = Date(timeIntervalSinceNow: 86400).clean
        let isCompleted = false
        let color = "ED3ED3"
        let dateCreated = Date().clean
        let dateEdited = Date().clean
        
        let toDoItem = ToDoItem(
            id: id,
            text: text,
            importance: importance,
            dueDate: dueDate,
            isCompleted: isCompleted,
            color: color,
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
        XCTAssertEqual(jsonDictionary["color"] as? String, color)
        XCTAssertEqual(jsonDictionary["dateCreated"] as? TimeInterval, dateCreated.timeIntervalSince1970)
        XCTAssertEqual(jsonDictionary["dateEdited"] as? TimeInterval, dateEdited.timeIntervalSince1970)
    }
    
    @MainActor
    func testJSONParsing() {
        // Given
        let json: [String: Any] = [
            "id": "1",
            "text": "Test",
            "importance": "important",
            "dueDate": 1719000000,
            "isCompleted": false,
            "color": "ED3ED3",
            "dateCreated": 1719000000.0,
            "dateEdited": 1719000000.0
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
        XCTAssertEqual(toDoItem.color, json["color"] as? String)
        XCTAssertEqual(toDoItem.dateCreated.timeIntervalSince1970, json["dateCreated"] as? TimeInterval)
        XCTAssertEqual(toDoItem.dateEdited?.timeIntervalSince1970, json["dateEdited"] as? TimeInterval)
    }
    
    @MainActor
    func testCSVParsing() {
        // Given
        let csv = "\"123\",\"Test Task\",\"important\",\"1719000000\",\"true\",\"ED3ED3\",\"1719000000\",\"1719000000\""
        
        // When
        guard let item = ToDoItem.parse(csv: csv) else {
            XCTFail("Failed to parse CSV")
            return
        }
        
        // Then
        XCTAssertEqual(item.id, "123")
        XCTAssertEqual(item.text, "Test Task")
        XCTAssertEqual(item.importance, .important)
        XCTAssertEqual(item.dueDate?.timeIntervalSince1970, 1719000000)
        XCTAssertEqual(item.isCompleted, true)
        XCTAssertEqual(item.color, "ED3ED3")
        XCTAssertEqual(item.dateCreated.timeIntervalSince1970, 1719000000)
        XCTAssertEqual(item.dateEdited?.timeIntervalSince1970, 1719000000)
    }
    
    @MainActor
    func testCSVConversion() {
        // Given
        let dateCreated = Date(timeIntervalSince1970: 1719000000)
        let dueDate = Date(timeIntervalSince1970: 1719000000)
        let dateEdited = Date(timeIntervalSince1970: 1719000000)
        
        let item = ToDoItem(
            id: "123",
            text: "Test Task",
            importance: .important,
            dueDate: dueDate,
            isCompleted: true,
            color: "ED3ED3",
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
        
        // When
        let csv = item.csv
        
        // Then
        // swiftlint:disable:next line_length
        let expectedCSV = "\"123\",\"Test Task\",\"important\",\"1719000000.0\",\"true\",\"ED3ED3\",\"1719000000.0\",\"1719000000.0\"\n"
        XCTAssertEqual(csv, expectedCSV)
    }
    
    @MainActor 
    func testParseInvalidCSV() {
        // Given
        let invalidCSV = "\"123\",\"Test Task\",\"high\",\"1719000000\",\"true\",\"1719000000\""
        
        // When
        let item = ToDoItem.parse(csv: invalidCSV)
        
        // Then
        XCTAssertNil(item)
    }
}
