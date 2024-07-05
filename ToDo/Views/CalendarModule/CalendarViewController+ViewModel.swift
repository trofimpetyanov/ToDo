import Foundation

extension CalendarViewController {
    enum Section: Hashable, Comparable {
        case dates
        case toDoItems(for: Date)
        case other
        
        static func < (lhs: Section, rhs: Section) -> Bool {
            switch (lhs, rhs) {
            case (dates, _):
                return true
            case (toDoItems(let lhsDate), toDoItems(let rhsDate)):
                return lhsDate < rhsDate
            case (_, other):
                return true
            default:
                return false
            }
        }
    }
    
    enum Row: Hashable {
        case date(_ date: Date?)
        case toDoItem(_ toDoItem: ToDoItem)
    }
    
    struct ViewModel {
        var toDoItems: [ToDoItem]
        var selectedDate: Row
        
        init(toDoItems: [ToDoItem]) {
            self.toDoItems = toDoItems
            
            self.selectedDate = .date(nil)
            self.selectedDate = datesSection.first ?? .date(nil)
        }
        
        var sections: [(key: Section, value: [Row])] {
            var sections = toDoItemsSection
            sections[.dates] = datesSection
            return sections.sorted(by: { $0.key < $1.key })
        }
        
        private var datesSection: [Row] {
            toDoItemsSection.keys
                .compactMap { section in
                    if case .toDoItems(for: let date) = section {
                        return .date(date)
                    }
                    
                    return nil
                }
                .sorted { lhs, rhs in
                    if case .date(let lhsDate) = lhs, let lhsDate = lhsDate, case .date(let rhsDate) = rhs, let rhsDate = rhsDate {
                        return lhsDate < rhsDate
                    }
                    
                    return false
                }
        }
        
        private var toDoItemsSection: [Section: [Row]] {
            toDoItems
                .reduce(into: [Section: [Row]]()) { result, toDoItem in
                    if let dueDate = toDoItem.dueDate {
                        let components = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
                        
                        if let dueDate = Calendar.current.date(from: components) {
                            let section = Section.toDoItems(for: dueDate)
                            
                            result[section, default: []].append(.toDoItem(toDoItem))
                        } else {
                            result[.other, default: []].append(.toDoItem(toDoItem))
                        }
                    } else {
                        result[.other, default: []].append(.toDoItem(toDoItem))
                    }
                }
        }
    }
}
