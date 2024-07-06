import Foundation

protocol CalendarContainerViewControllerDelegate: AnyObject {
    func didSelectDate(_ viewController: CalendarDatesViewController, date: Date?)
    
    func didScrollThroughDateSection(_ viewController: CalendarListViewController, date: Date?)
    
    func didCompleteToDoItem(_ viewController: CalendarListViewController, toDoItem: ToDoItem, isCompleted: Bool)
}
