import UIKit

extension CalendarListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    enum Section: Hashable, Comparable {
        case toDoItems(for: Date)
        case other
        
        static func < (lhs: Section, rhs: Section) -> Bool {
            switch (lhs, rhs) {
            case (toDoItems(let lhsDate), toDoItems(let rhsDate)):
                return lhsDate < rhsDate
            case (_, other):
                return true
            default:
                return false
            }
        }
    }
    
    typealias Row = ToDoItem
    
    struct ViewModel {
        var toDoItems: [ToDoItem]
        
        var sections: [Section: [Row]] {
            toDoItems.reduce(into: [Section: [Row]]()) { result, toDoItem in
                if let dueDate = toDoItem.dueDate {
                    let section = Section.toDoItems(for: dueDate)
                    result[section, default: []].append(toDoItem)
                } else {
                    result[.other, default: []].append(toDoItem)
                }
            }
        }
        
        init(toDoItems: [ToDoItem]) {
            self.toDoItems = toDoItems
        }
    }
}
