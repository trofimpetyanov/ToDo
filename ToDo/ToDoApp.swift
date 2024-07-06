import SwiftUI
import SwiftData

@main
struct ToDoApp: App {
    @State private var toDoItemsStore = ToDoItemsStore()
    
    var body: some Scene {
        WindowGroup {
            ToDoItemsList(toDoItemsStore: toDoItemsStore)
                .modelContainer(for: Category.self)
        }
    }
}


