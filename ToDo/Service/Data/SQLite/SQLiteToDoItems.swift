import Foundation
import SQLite
import LoggerPackage

class SQLiteToDoItems: SQLiteModelContainer {
    typealias Item = ToDoItem
    
    private var dataBase: Connection!
    private var toDoItems: Table!
    
    private var id = Expression<String>(ToDoItem.Properties.id.rawValue)
    private var text = Expression<String>(ToDoItem.Properties.text.rawValue)
    private var importance = Expression<String>(ToDoItem.Properties.importance.rawValue)
    private var dueDate = Expression<Date?>(ToDoItem.Properties.dueDate.rawValue)
    private var isCompleted = Expression<Bool>(ToDoItem.Properties.isCompleted.rawValue)
    private var color = Expression<String?>(ToDoItem.Properties.color.rawValue)
    private var dateCreated = Expression<Date>(ToDoItem.Properties.dateCreated.rawValue)
    private var dateEdited = Expression<Date?>(ToDoItem.Properties.dateEdited.rawValue)
    private var lastUpdatedBy = Expression<String?>(ToDoItem.Properties.lastUpdatedBy.rawValue)
    
    init() {
        do {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path()
            dataBase = try Connection("\(path)/storage.sqlite3")
            toDoItems = Table("toDoItems")
            if !UserDefaults.standard.bool(forKey: "isDataBaseCreated") {
                try dataBase.run(toDoItems.create { table in
                    table.column(id, primaryKey: true)
                    table.column(text)
                    table.column(importance)
                    table.column(dueDate)
                    table.column(isCompleted)
                    table.column(color)
                    table.column(dateCreated)
                    table.column(dateEdited)
                    table.column(lastUpdatedBy)
                })
                UserDefaults.standard.set(true, forKey: "isDataBaseCreated")
            }
        } catch {
            Logger.logError("Error initializing SQLite database.")
        }
    }
    
    func add(_ item: Item) {
        do {
            try dataBase.run(
                toDoItems.insert(
                    id <- item.id,
                    text <- item.text,
                    importance <- item.importance.rawValue,
                    dueDate <- item.dueDate,
                    isCompleted <- item.isCompleted,
                    color <- item.color,
                    dateCreated <- item.dateCreated,
                    dateEdited <- item.dateEdited,
                    lastUpdatedBy <- item.lastUpdatedBy
                )
            )
        } catch {
            Logger.logError("Error adding item to SQLite database, id: \(item.id).")
        }
    }
    
    func load() throws -> [Item] {
        var result: [ToDoItem] = []
        for data in try dataBase.prepare(self.toDoItems) {
            let toDoItem = ToDoItem(
                id: data[id],
                text: data[text],
                importance: Importance(rawValue: data[importance]) ?? .basic,
                dueDate: data[dueDate],
                isCompleted: data[isCompleted],
                color: data[color],
                dateCreated: data[dateCreated],
                dateEdited: data[dateEdited],
                lastUpdatedBy: data[lastUpdatedBy]
            )
            result.append(toDoItem)
        }
        return result
    }
    
    func update(_ item: Item) {
        do {
            let table = toDoItems.filter(id == item.id)
            try dataBase.run(
                table.update(
                    id <- item.id,
                    text <- item.text,
                    importance <- item.importance.rawValue,
                    dueDate <- item.dueDate,
                    isCompleted <- item.isCompleted,
                    color <- item.color,
                    dateCreated <- item.dateCreated,
                    dateEdited <- item.dateEdited,
                    lastUpdatedBy <- item.lastUpdatedBy
                )
            )
        } catch {
            Logger.logError("Error updating item in SQLite database, id: \(item.id).")
        }
    }
    
    func delete(with id: String) {
        do {
            let table = toDoItems.filter(self.id == id)
            try dataBase.run(table.delete())
        } catch {
            Logger.logError("Error deleting item in SQLite database, id: \(id).")
        }
    }
    
    func clear() throws {
        try dataBase.run(toDoItems.delete())
    }
}
