import SwiftUI

struct ListHeader: View {
    @Binding var toDoItems: [ToDoItem]
    @Binding var isExpanded: Bool
    
    var completedCount: Int {
        toDoItems
            .filter { $0.isCompleted }
            .count
    }
    
    var body: some View {
        HStack {
            Text("Выполнено – \(completedCount)")
                .textCase(.none)
                .contentTransition(.numericText(value: Double(completedCount)))
        }
    }
}

#Preview {
    ListHeader(toDoItems: .constant(ToDoItemsStore.mock), isExpanded: .constant(true))
}
