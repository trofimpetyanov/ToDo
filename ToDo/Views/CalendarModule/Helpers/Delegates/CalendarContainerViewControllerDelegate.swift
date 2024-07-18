import Foundation

@MainActor
protocol CalendarContainerViewControllerDelegate: AnyObject {
    func didSelectDate(_ viewController: CalendarDatesViewController, date: Date?)
    
    func didSelectToDoItem(_ viewController: CalendarListViewController, at indexPath: IndexPath)
    func didCompleteToDoItem(_ viewController: CalendarListViewController, toDoItem: ToDoItem, isCompleted: Bool)
    func didScrollThroughDateSection(_ viewController: CalendarListViewController, date: Date?)
}
