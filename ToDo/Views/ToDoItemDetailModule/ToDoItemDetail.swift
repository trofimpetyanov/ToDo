import SwiftUI
import SwiftData
import LoggerPackage

struct ToDoItemDetail: View {
    @Query(sort: \Category.id) private var categories: [Category]
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var editingToDoItem: ToDoItem?
    
    let onSave: (ToDoItem) -> Void
    let onDismiss: () -> Void
    let onDelete: () -> Void
    
    @State private var text: String = ""
    @State private var importance: Importance = .ordinary
    @State private var category: Category = .other
    @State private var dueDate = Date(timeIntervalSinceNow: 86400)
    @State private var isDueDateToggled = false
    @State private var isDatePickerShown = false
    
    @State private var isEditing = false
    @State private var isCategoryDetailPresenting = false
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Дело")
                .navigationBarTitleDisplayMode(.inline)
                .background(AppColors.backPrimary)
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 56)
                .sheet(isPresented: $isCategoryDetailPresenting) {
                    NavigationStack {
                        CategoryDetail(
                            onSave: { category in self.category = category },
                            onDismiss: { isCategoryDetailPresenting = false })
                    }
                }
                .toolbarBackground(horizontalSizeClass == .regular ? .visible : .automatic, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        saveButton
                    }
                    
                    ToolbarItem(placement: .cancellationAction) {
                        cancelButton
                    }
                    
                    ToolbarItem(placement: .keyboard) {
                        hideButton
                    }
                }
            
        }
        .onChange(of: editingToDoItem) {
            setupEditingToDoItem()
        }
        .onAppear() {
            Logger.logInfo("ToDoItemDetail appeared.")
            
            setupEditingToDoItem()
        }
    }
    
    private var contentView: some View {
        Group {
            switch horizontalSizeClass {
            case .regular:
                regularSizeContentView
            default:
                defaultSizeContentView
            }
        }
    }
    
    private var regularSizeContentView: some View {
        HStack {
            Form {
                textSection
            }
            .scrollIndicators(.hidden)
            
            if !isEditing || UIDevice.current.userInterfaceIdiom != .phone {
                Form {
                    detailsSection
                    deleteSection
                }
            }
        }
        .animation(.default, value: isEditing)
    }
    
    private var defaultSizeContentView: some View {
        Form {
            textSection
            detailsSection
            deleteSection
        }
    }
    
    private var textSection: some View {
        Section {
            TextField("Что надо сделать?", text: $text, axis: .vertical)
                .lineLimit(5...)
                .onTapGesture {
                    isEditing = true
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    isEditing = false
                }
        }
    }
    
    private var importanceRow: some View {
        HStack {
            Text("Важность")
            
            Spacer()
            
            Picker("Важность", selection: $importance) {
                ForEach(Importance.allCases, id: \.self) { importance in
                    switch importance {
                    case .unimportant:
                        Image.systemImage("arrow.down", for: .boldSystemFont(ofSize: UIFont.buttonFontSize), tint: .gray)
                    case .ordinary:
                        Text("нет")
                    case .important:
                        Image.systemImage("exclamationmark.2", for: .boldSystemFont(ofSize: UIFont.buttonFontSize), tint: .red)
                    }
                }
            }
            .pickerStyle(.segmented)
            .fixedSize()
        }
    }
    
    private var categoryRow: some View {
        HStack {
            Text("Категория")
            
            Spacer()
            
            Menu {
                Picker("Категория", selection: $category) {
                    ForEach(categories) { category in
                        Label(
                            title: {
                                Text(category.name)
                            },
                            icon: {
                                Image.systemImage(
                                    "circle.fill",
                                    for: .systemFont(ofSize: 16),
                                    tint: UIColor(Color(hex: category.color))
                                )
                            }
                        )
                        .tag(category)
                    }
                }
                
                Button {
                    isCategoryDetailPresenting = true
                } label: {
                    Label(
                        title: { Text("Новая категория") },
                        icon: { Image(uiImage: .add) }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } label: {
                HStack {
                    Circle()
                        .fill(Color(hex: category.color))
                        .frame(width: 24, height: 24)
                    
                    Text(category.name)
                }
            }
        }
    }
        
    private var toggleRow: some View {
        Toggle(isOn: $isDueDateToggled) {
            VStack(alignment: .leading) {
                Text("Сделать до")
                
                if isDueDateToggled {
                    Button {
                        withAnimation {
                            isDatePickerShown.toggle()
                        }
                    } label: {
                        Text(dueDate.dayMonthFormatted)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .submitScope()
                }
            }
            .animation(.interactiveSpring, value: isDueDateToggled)
        }
    }
    
    private var datePickerRow: some View {
        DatePicker(
            "Дедлайн",
            selection: $dueDate,
            in: Date(timeIntervalSinceNow: 86400)...,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
    }
    
    private var detailsSection: some View {
        Section {
            importanceRow
            categoryRow
            toggleRow
            
            if isDatePickerShown && isDueDateToggled {
                datePickerRow
            }
        }
    }
    
    private var deleteSection: some View {
        Group {
            if editingToDoItem != nil {
                Section {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Удалить")
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button("Сохранить") {
            let plainText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let newDueDate: Date?
            if isDueDateToggled {
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
                newDueDate = Calendar.current.date(from: dateComponents)
            } else {
                newDueDate = nil
            }
            
            if let toDoItem = editingToDoItem {
                let newToDoItem = ToDoItem(
                    id: toDoItem.id,
                    text: plainText,
                    importance: importance,
                    dueDate: newDueDate,
                    category: category,
                    categoryId: category.id,
                    isCompleted: toDoItem.isCompleted,
                    dateCreated: toDoItem.dateCreated,
                    dateEdited: Date()
                )
                
                onSave(newToDoItem)
            } else {
                let newToDoItem = ToDoItem(
                    text: plainText,
                    importance: importance,
                    dueDate: newDueDate,
                    category: category,
                    categoryId: category.id
                )
                
                Logger.logDebug("Saving new ToDoItem: \(newToDoItem.id).")
                
                onSave(newToDoItem)
            }
        }
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    private var cancelButton: some View {
        Button("Отменить") {
            onDismiss()
        }
    }
    
    private var hideButton: some View {
        Button("Скрыть", systemImage: "keyboard.chevron.compact.down") {
            isEditing = false
            
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            Logger.logInfo("Hiding keyboard.")
        }
    }
    
    private func setupEditingToDoItem() {
        if let editingToDoItem = editingToDoItem {
            text = editingToDoItem.text
            importance = editingToDoItem.importance
            isDueDateToggled = editingToDoItem.dueDate != nil
            dueDate = editingToDoItem.dueDate ?? Date(timeIntervalSinceNow: 86400)
            
            if let category = editingToDoItem.category, let neededCategory = categories.first(where: { $0.id == category.id }) {
                self.category = neededCategory
            } else {
                category = categories.first ?? .other
            }
            
            Logger.logDebug("Editing ToDoItem: \(editingToDoItem.id).")
        } else {
            text = ""
            importance = .ordinary
            dueDate = Date(timeIntervalSinceNow: 86400)
            isDueDateToggled = false
            isDatePickerShown = false
            category = categories.first ?? .other
        }
    }
}

#Preview {
    ToDoItemDetail(
        editingToDoItem: .constant(ToDoItemsStore.mock[0]),
        onSave: { _ in },
        onDismiss: {},
        onDelete: {}
    )
    .modelContainer(for: Category.self)
}
