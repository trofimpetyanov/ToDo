import SwiftUI

struct ListRow: View {
    @Binding var toDoItem: ToDoItem
    
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            CheckmarkView(toDoItem: $toDoItem, onComplete: onComplete)
            
            VStack(alignment: .leading) {
                HStack {
                    if toDoItem.importance == .important {
                        Image(systemName: "exclamationmark.2")
                            .fontWeight(.bold)
                            .foregroundStyle(toDoItem.isCompleted ? Color.secondary : .red)
                    } else if toDoItem.importance == .unimportant {
                        Image(systemName: "arrow.down")
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(toDoItem.text)
                        .strikethrough(toDoItem.isCompleted, color: .secondary)
                        .foregroundStyle(toDoItem.isCompleted ? .secondary : .primary)
                        .lineLimit(3)
                }
                
                if let dueDate = toDoItem.dueDate {
                    HStack {
                        Image(systemName: "calendar")
                        Text(dueDate.dayMonthFormatted)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .alignmentGuide(.listRowSeparatorLeading, computeValue: { dimension in
                return 0
            })
            .padding(.leading, 8)
            
            if let category = toDoItem.category {
                Spacer()
                
                Rectangle()
                    .fill(Color(hex: category.color))
                    .clipShape(.capsule)
                    .frame(width: 5)
                    .padding(.vertical, 8)
            }
        }
    }
}

#Preview {
    ListRow(toDoItem: .constant(ToDoItemsStore.mock[0]), onComplete: {})
}
