import SwiftUI

struct ToDoItemsList: View {
    @ObservedObject var toDoItemsStore: ToDoItemsStore
    
    @State private var newToDoItemText: String = ""
    @State private var editingToDoItem: ToDoItem?
    
    @State private var isDetailPresented: Bool = false
    @State private var isDetailViewPresenting: Bool = false
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NavigationSplitView {
                listSection
                    .navigationTitle("Мои Дела")
            } detail: {
                detailView
            }
        } else {
            NavigationStack {
                listSection
                    .navigationTitle("Мои Дела")
            }
            .sheet(
                isPresented: $isDetailPresented,
                content: {
                    detailView
                }
            )
        }
    }
    
    private var settingsMenu: some View {
        Menu("Настройки", systemImage: "line.3.horizontal.decrease.circle") {
            Button(action: {
                withAnimation {
                    toDoItemsStore.areCompletedShown.toggle()
                }
            }, label: {
                Label(
                    "\(toDoItemsStore.areCompletedShown ? "Скрыть" : "Показать") выполненные",
                    systemImage: toDoItemsStore.areCompletedShown ? "eye.slash" : "eye"
                )
            })
            
            Divider()
            
            Menu("Сортировать", systemImage: "arrow.up.arrow.down") {
                Picker("Опции", selection: $toDoItemsStore.sortingOption) {
                    ForEach(ToDoItemsStore.SortingOption.allCases) { option in
                        Text(option.rawValue)
                            .tag(option)
                    }
                    
                }
                Divider()
                
                Picker("Порядок", selection: $toDoItemsStore.sortingOrder) {
                    ForEach(ToDoItemsStore.SortingOrder.allCases) { order in
                        Text(order.rawValue)
                            .tag(order)
                    }
                }
            }
        }
    }
    
    private var listSection: some View {
        List {
            Section(
                header: Text("Выполнено – \(toDoItemsStore.completedCount)")
            ) {
                ForEach($toDoItemsStore.currentToDoItems) { toDoItem in
                    listRow(for: toDoItem)
                }
                
                TextField("Новое", text: $newToDoItemText)
                    .onSubmit {
                        let toDoItem = ToDoItem(text: newToDoItemText)
                        newToDoItemText = ""
                        toDoItemsStore.add(toDoItem)
                    }
                    .padding(.leading, 40)
            }
        }
        .background(AppColors.backPrimary)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 56)
        .overlay(addNewItemButton, alignment: .bottom)
        .animation(.default, value: toDoItemsStore.currentToDoItems)
        .toolbar {
            settingsMenu
        }
    }
    
    private var addNewItemButton: some View {
        VStack {
            Spacer()
            
            Button {
                isDetailViewPresenting = true
                editingToDoItem = nil
                isDetailPresented = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .foregroundStyle(.white, .blue)
                    .frame(width: 44, height: 44)
                    .shadow(radius: 8, y: 4)
            }
            .padding(.bottom, 20)
        }
    }
    
    private var detailView: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                if isDetailViewPresenting {
                    ToDoItemDetail(
                        editingToDoItem: $editingToDoItem,
                        isDetailPresented: $isDetailViewPresenting,
                        onComplete: { toDoItem in onSave(toDoItem) },
                        onDismiss: { onDismiss() },
                        onDelete: { onDelete() }
                    )
                } else {
                    ContentUnavailableView("Выберите задачу", systemImage: "filemenu.and.selection")
                }
            } else {
                ToDoItemDetail(
                    editingToDoItem: $editingToDoItem,
                    isDetailPresented: $isDetailViewPresenting,
                    onComplete: { toDoItem in onSave(toDoItem) },
                    onDismiss: { onDismiss() },
                    onDelete: { onDelete() }
                )
            }
        }
    }
    
    private func listRow(for toDoItem: Binding<ToDoItem>) -> some View {
        ListRow(toDoItem: toDoItem,
                onComplete: { toDoItemsStore.addOrUpdate(toDoItem.wrappedValue) })
        .onTapGesture {
            presentDetailView(for: toDoItem.wrappedValue)
        }
        .swipeActions(edge: .leading) {
            completeAction(for: toDoItem.wrappedValue)
        }
        .swipeActions(edge: .trailing) {
            deleteAction(for: toDoItem.wrappedValue)
            infoAction(for: toDoItem.wrappedValue)
        }
    }
    
    private func completeAction(for toDoItem: ToDoItem) -> some View {
        Button {
            toDoItemsStore.addOrUpdate(
                ToDoItem(
                    id: toDoItem.id,
                    text: toDoItem.text,
                    importance: toDoItem.importance,
                    dueDate: toDoItem.dueDate,
                    isCompleted: !toDoItem.isCompleted,
                    dateCreated: toDoItem.dateCreated,
                    dateEdited: toDoItem.dateEdited
                )
            )
        } label: {
            Image(systemName: toDoItem.isCompleted ? "circle" : "checkmark.circle.fill")
        }
        .tint(.green)
    }
    
    private func deleteAction(for toDoItem: ToDoItem) -> some View {
        Button(role: .destructive) {
            editingToDoItem = toDoItem
            onDelete()
        } label: {
            Image(systemName: "trash.fill")
        }
    }
    
    private func infoAction(for toDoItem: ToDoItem) -> some View {
        Button {
            presentDetailView(for: toDoItem)
        } label: {
            Image(systemName: "info.circle.fill")
        }
    }
    
    private func presentDetailView(for toDoItem: ToDoItem) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            isDetailViewPresenting = true
            editingToDoItem = toDoItem
        } else {
            isDetailPresented = true
            editingToDoItem = toDoItem
        }
    }
    
    private func discardDetailView() {
        isDetailViewPresenting = false
        editingToDoItem = nil
        isDetailPresented = false
    }
    
    private func onSave(_ toDoItem: ToDoItem) {
        withAnimation {
            toDoItemsStore.addOrUpdate(toDoItem)
        }
    }
    
    private func onDismiss() {
        discardDetailView()
    }
    
    private func onDelete() {
        withAnimation {
            if let editingToDoItem = editingToDoItem {
                toDoItemsStore.delete(editingToDoItem)
            }
        }
        
        discardDetailView()
    }
}

struct ToDoItemsList_Previews: PreviewProvider {
    static var previews: some View {
        let toDoItemsStore = ToDoItemsStore()
        
        return ToDoItemsList(toDoItemsStore: toDoItemsStore)
    }
}
