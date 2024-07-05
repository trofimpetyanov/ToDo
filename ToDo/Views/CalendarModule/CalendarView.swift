import SwiftUI

struct CalendarView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CalendarViewController
    
    var toDoItems: [ToDoItem]
    
    func makeUIViewController(context: Context) -> CalendarViewController {
        let viewModel = CalendarViewController.ViewModel(toDoItems: toDoItems)
        let calendarViewController = CalendarViewController(viewModel: viewModel)
        
        return calendarViewController
    }
    
    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
        return
    }
}

#Preview {
    CalendarView(toDoItems: FileCache.mock)
}
