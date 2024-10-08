import SwiftUI
import SwiftData
import LoggerPackage

@MainActor
struct ToDoItemDetail: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var editingToDoItem: ToDoItem?
    
    let onSave: (ToDoItem) -> Void
    let onDismiss: () -> Void
    let onDelete: (ToDoItem) -> Void
    
    @State private var text: String = ""
    @State private var importance: Importance = .basic
    
    @State private var color: Color = .red
    @State private var isColorToggled = false
    @State private var isColorPickerPresented: Bool = false
    
    @State private var dueDate = Date(timeIntervalSinceNow: 86400)
    @State private var isDueDateToggled = false
    @State private var isDatePickerShown = false
    
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Дело")
                .navigationBarTitleDisplayMode(.inline)
                .background(AppColors.backPrimary)
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 56)
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
        .onAppear {
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
                    case .low:
                        Image.systemImage(
                            "arrow.down",
                            for: .boldSystemFont(ofSize: UIFont.buttonFontSize),
                            tint: .gray
                        )
                    case .basic:
                        Text("нет")
                    case .important:
                        Image.systemImage(
                            "exclamationmark.2",
                            for: .boldSystemFont(ofSize: UIFont.buttonFontSize),
                            tint: .red
                        )
                    }
                }
            }
            .pickerStyle(.segmented)
            .fixedSize()
        }
    }
    
    private var colorPickerRow: some View {
        HStack {
            Text("Цвет")
            
            Circle()
                .fill(color)
                .frame(width: isColorToggled ? 24 : 0, alignment: .center)
                .offset(x: isColorToggled ? -12 : 0)
                .padding(.leading, 16)
                .animation(.bouncy(duration: 0.2), value: isColorToggled)
                .onTapGesture {
                    isColorPickerPresented = true
                }
            
            Toggle("", isOn: $isColorToggled)
            
        }
        .sheet(isPresented: $isColorPickerPresented) {
            ColorWheelPicker(color: $color)
                .presentationDetents([.fraction(3/5)])
                .presentationDragIndicator(.visible)
                .background(AppColors.backPrimary)
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
            colorPickerRow
            toggleRow
            
            if isDatePickerShown && isDueDateToggled {
                datePickerRow
            }
        }
    }
    
    private var deleteSection: some View {
        Group {
            if let editingToDoItem = editingToDoItem {
                Section {
                    Button(role: .destructive) {
                        onDelete(editingToDoItem)
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
}

// MARK: – Buttons
extension ToDoItemDetail {
    private var saveButton: some View {
        Button("Сохранить") {
            let plainText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let newDueDate: Date?
            if isDueDateToggled {
                newDueDate = dueDate.clean
            } else {
                newDueDate = nil
            }
            
            if let toDoItem = editingToDoItem {
                let newToDoItem = ToDoItem(
                    id: toDoItem.id,
                    text: plainText,
                    importance: importance,
                    dueDate: newDueDate,
                    isCompleted: toDoItem.isCompleted,
                    color: isColorToggled ? color.hex : nil,
                    dateCreated: toDoItem.dateCreated,
                    dateEdited: Date())
                
                onSave(newToDoItem)
            } else {
                let newToDoItem = ToDoItem(
                    text: plainText,
                    importance: importance,
                    dueDate: newDueDate,
                    color: isColorToggled ? color.hex : nil)
                
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
}

// MARK: – Methods
extension ToDoItemDetail {
    private func setupEditingToDoItem() {
        if let editingToDoItem = editingToDoItem {
            text = editingToDoItem.text
            importance = editingToDoItem.importance
            isColorToggled = editingToDoItem.color != nil
            isDueDateToggled = editingToDoItem.dueDate != nil
            dueDate = editingToDoItem.dueDate ?? Date(timeIntervalSinceNow: 86400)
            
            if let hex = editingToDoItem.color {
                color = Color(hex: hex)
            }
        } else {
            text = ""
            importance = .basic
            dueDate = Date(timeIntervalSinceNow: 86400)
            isDueDateToggled = false
            isDatePickerShown = false
            isColorToggled = false
        }
    }
}

#Preview {
    ToDoItemDetail(
        editingToDoItem: .constant(ToDoItemsStore.mock[0]),
        onSave: { _ in },
        onDismiss: {},
        onDelete: { _ in }
    )
}
