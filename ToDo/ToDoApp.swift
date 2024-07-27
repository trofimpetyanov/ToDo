import SwiftUI
import SwiftData
import LoggerPackage

@main
struct ToDoApp: App {
    @State private var toDoItemsStore: ToDoItemsStore

    init() {
        Logger.setup()
        
        do {
            let modelContainer = try ModelContainer(for: ToDoItem.self)
            self._toDoItemsStore = State(initialValue: ToDoItemsStore(modelContainer: modelContainer))
        } catch {
            fatalError("Cannot launch the App: Failed to create ModelContainer for ToDoItem.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(toDoItemsStore: toDoItemsStore)
        }
    }
}
