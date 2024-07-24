import SwiftUI
import SwiftData
import LoggerPackage

struct ToDoItemsList: View {
    @ObservedObject var toDoItemsStore: ToDoItemsStore
    
    @State private var newToDoItemText: String = ""
    @State private var editingToDoItem: ToDoItem?
    
    @State private var isDetailPresented: Bool = false
    @State private var isDetailViewPresenting: Bool = false
    
    @State private var isCalendarViewPresenting: Bool = false
    
    @State private var isLoading: Bool = true
    
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
            }
            .sheet(
                isPresented: $isDetailPresented,
                content: {
                    detailView
                }
            )
        }
    }
    
    private var listSection: some View {
        List {
            if UIDevice.current.userInterfaceIdiom == .pad {
                Button("Каледнарь", systemImage: "calendar") {
                    isCalendarViewPresenting = true
                }
            }
            
            Section {
                ForEach($toDoItemsStore.currentToDoItems) { toDoItem in
                    listRow(for: toDoItem)
                }
                
                TextField("Новое", text: $newToDoItemText)
                    .onSubmit {
                        let plainText = newToDoItemText.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !plainText.isEmpty {
                            let toDoItem = ToDoItem(text: newToDoItemText)
                            
                            Task {
                                await toDoItemsStore.add(toDoItem)
                            }
                        }
                        
                        newToDoItemText = ""
                    }
                    .submitLabel(.done)
                    .padding(.leading, 40)
            } header: {
                HStack {
                    Text("Выполнено – \(toDoItemsStore.completedCount)")
                        .contentTransition(.numericText())
                        .animation(.default, value: toDoItemsStore.completedCount)
                    
                    Spacer()
                    
                    settingsMenu
                        .textCase(.none)
                }
            }
        }
        .navigationTitle("Мои Дела")
        .background(AppColors.backPrimary)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 56)
        .animation(.default, value: toDoItemsStore.currentToDoItems)
        .safeAreaInset(edge: .bottom) {
            addNewItemButton
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(.circular)
                        
                        VStack(alignment: .leading) {
                            Text("Не забудьте вставить")
                            Text("свой токен.")
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            
            if UIDevice.current.userInterfaceIdiom != .pad {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        CalendarView(toDoItemsStore: toDoItemsStore)
                            .navigationTitle("Календарь")
                            .toolbarTitleDisplayMode(.inline)
                            .toolbarBackground(.visible, for: .navigationBar)
                            .background(AppColors.backPrimary)
                            .ignoresSafeArea(edges: .bottom)
                    } label: {
                        Label("Календарь", systemImage: "calendar")
                    }
                }
            }
        }
        .onAppear {
            Logger.logInfo("ToDoItemsList appeared.")
            
            Task {
                while true {
                    isLoading = await toDoItemsStore.networkManager.isLoading
                    try await Task.sleep(for: .seconds(1))
                }
            }
        }
    }
    
    private var settingsMenu: some View {
        Menu("Опции", systemImage: "line.3.horizontal.decrease.circle") {
            Button {
                withAnimation {
                    toDoItemsStore.areCompletedShown.toggle()
                }
                
                Logger.logDebug("Toggled completed items visibility to \(toDoItemsStore.areCompletedShown).")
            } label: {
                Label(
                    "\(toDoItemsStore.areCompletedShown ? "Скрыть" : "Показать") выполненные",
                    systemImage: toDoItemsStore.areCompletedShown ? "eye.slash" : "eye"
                )
            }
            
            Divider()
            
            Menu("Сортировать", systemImage: "arrow.up.arrow.down") {
                Picker("Опции", selection: $toDoItemsStore.sortingOption) {
                    ForEach(ToDoItemsStore.SortingOption.allCases) { option in
                        Text(option.rawValue)
                            .tag(option)
                    }
                    
                }
                .onChange(of: toDoItemsStore.sortingOption) { oldValue, newValue in
                    Logger.logDebug("Sorting option changed from \(oldValue) to \(newValue).")
                }
                
                Divider()
                
                Picker("Порядок", selection: $toDoItemsStore.sortingOrder) {
                    ForEach(ToDoItemsStore.SortingOrder.allCases) { order in
                        Text(order.rawValue)
                            .tag(order)
                    }
                }
                .onChange(of: toDoItemsStore.sortingOrder) { oldValue, newValue in
                    Logger.logDebug("Sorting order changed from \(oldValue) to \(newValue).")
                }
            }
        }
    }
    
    private var addNewItemButton: some View {
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
    
    private var detailView: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                if isCalendarViewPresenting {
                    CalendarView(toDoItemsStore: toDoItemsStore)
                        .navigationTitle("Календарь")
                        .toolbarTitleDisplayMode(.inline)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .background(AppColors.backPrimary)
                        .ignoresSafeArea(edges: .bottom)
                } else if isDetailViewPresenting {
                    ToDoItemDetail(
                        editingToDoItem: $editingToDoItem,
                        onSave: { toDoItem in onSave(toDoItem) },
                        onDismiss: { onDismiss() },
                        onDelete: { toDoItem in onDelete(toDoItem) })
                } else {
                    ContentUnavailableView("Выберите задачу", systemImage: "filemenu.and.selection")
                }
            } else {
                ToDoItemDetail(
                    editingToDoItem: $editingToDoItem,
                    onSave: { toDoItem in onSave(toDoItem) },
                    onDismiss: { onDismiss() },
                    onDelete: { toDoItem in onDelete(toDoItem) }
                )
            }
        }
    }
    
    private func listRow(for toDoItem: Binding<ToDoItem>) -> some View {
        ListRow(toDoItem: toDoItem,
                onComplete: { await toDoItemsStore.addOrUpdate(toDoItem.wrappedValue) })
        .onTapGesture {
            isCalendarViewPresenting = false
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
            Task {
                await toDoItemsStore.addOrUpdate(
                    ToDoItem(
                        id: toDoItem.id,
                        text: toDoItem.text,
                        importance: toDoItem.importance,
                        dueDate: toDoItem.dueDate,
                        isCompleted: !toDoItem.isCompleted,
                        color: toDoItem.color,
                        dateCreated: toDoItem.dateCreated,
                        dateEdited: toDoItem.dateEdited
                    )
                )
            }
        } label: {
            Image(systemName: toDoItem.isCompleted ? "circle" : "checkmark.circle.fill")
        }
        .tint(.green)
    }
    
    private func deleteAction(for toDoItem: ToDoItem) -> some View {
        Button(role: .destructive) {
            onDelete(toDoItem)
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
}

// MARK: – Methods
extension ToDoItemsList {
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
        Task {
            await toDoItemsStore.addOrUpdate(toDoItem)
        }
        
        onDismiss()
    }
    
    private func onDismiss() {
        discardDetailView()
        
        Logger.logInfo("ToDoItemDetail dismissed.")
    }
    
    private func onDelete(_ toDoItem: ToDoItem) {
        Task {
            await toDoItemsStore.delete(toDoItem)
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
