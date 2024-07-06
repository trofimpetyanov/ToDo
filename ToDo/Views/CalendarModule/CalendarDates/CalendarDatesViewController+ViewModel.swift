import UIKit

extension CalendarDatesViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    typealias Section = Int
    
    enum Row: Hashable {
        case date(_ date: Date)
        case other
    }
    
    struct ViewModel {
        var toDoItems: [ToDoItem]
        
        var rows: [Row] {
            var rows = Set(toDoItems.compactMap { $0.dueDate })
                .sorted { $0 < $1 }
                .map { Row.date($0) }
            
            if rows.count != toDoItems.count {
                rows.append(.other)
            }
            
            return rows
        }
        
        init(toDoItems: [ToDoItem]) {
            self.toDoItems = toDoItems
        }
    }
    
}
