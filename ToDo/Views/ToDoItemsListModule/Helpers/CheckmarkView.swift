import SwiftUI

struct CheckmarkView: View {
    @Binding var toDoItem: ToDoItem
    
    let size: CGFloat = 24
    let onComplete: () -> Void
    
    var body: some View {
        Button {
            withAnimation(.interactiveSpring) {
                updateToDoItem()
            }
        } label: {
            if toDoItem.isCompleted {
                Circle()
                    .fill(.green)
                    .frame(width: size, height: size)
                    .overlay {
                        Image(systemName: "checkmark")
                            .resizable()
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                            .frame(width: size * 0.5, height: size * 0.5)
                    }
            } else {
                Circle()
                    .fill(toDoItem.importance == .important ? .red.opacity(0.1) : .clear)
                    .strokeBorder(lineWidth: 1.5)
                    .foregroundStyle(toDoItem.importance == .important ? .red : .primary.opacity(0.2))
                    .frame(width: size, height: size)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @MainActor 
    private func updateToDoItem() {
        toDoItem = ToDoItem(
            id: toDoItem.id,
            text: toDoItem.text,
            importance: toDoItem.importance,
            dueDate: toDoItem.dueDate,
            isCompleted: !toDoItem.isCompleted,
            color: toDoItem.color,
            dateCreated: toDoItem.dateCreated,
            dateEdited: toDoItem.dateEdited
        )
        
        onComplete()
    }
}

#Preview {
    CheckmarkView(toDoItem: .constant(ToDoItemsStore.mock[0]), onComplete: {})
}
