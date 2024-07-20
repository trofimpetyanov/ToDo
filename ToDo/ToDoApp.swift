import SwiftUI
import SwiftData
import LoggerPackage

@main
struct ToDoApp: App {
    @State private var toDoItemsStore: ToDoItemsStore

    init() {
        self._toDoItemsStore = State(initialValue: ToDoItemsStore())
        Logger.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            ToDoItemsList(toDoItemsStore: toDoItemsStore)
        }
    }
}
