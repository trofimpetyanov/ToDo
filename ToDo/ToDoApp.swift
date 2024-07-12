import SwiftUI
import SwiftData
import LoggerPackage

@main
struct ToDoApp: App {
    @State private var toDoItemsStore = ToDoItemsStore()
    
    init() {
        Logger.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            ToDoItemsList(toDoItemsStore: toDoItemsStore)
                .modelContainer(for: Category.self)
        }
    }
}
