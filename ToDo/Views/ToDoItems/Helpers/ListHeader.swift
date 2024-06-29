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
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }) {
                Text(isExpanded ? "Скрыть" : "Показать")
                    .font(.subheadline)
                    .bold()
                    .contentTransition(.identity)
            }
            .textCase(.none)
        }
    }
}

#Preview {
    ListHeader(toDoItems: .constant(FileCache.mock), isExpanded: .constant(true))
}
