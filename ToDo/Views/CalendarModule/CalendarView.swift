import SwiftUI
import SwiftData

struct CalendarView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CalendarContainerViewController
    
    var toDoItemsStore: ToDoItemsStore
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let calendarContainerViewController = CalendarContainerViewController(toDoItemsStore: toDoItemsStore)
        
        return calendarContainerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        return
    }
}

#Preview {
    CalendarView(
        toDoItemsStore: ToDoItemsStore(
            swiftDataModelContainer: ModelContainer.mock,
            sqliteModelContainer: SQLiteToDoItems()
        )
    )
}
