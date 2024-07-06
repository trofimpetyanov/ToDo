import SwiftUI

struct ToDoItemDetail: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var editingToDoItem: ToDoItem?
    
    let onSave: (ToDoItem) -> Void
    let onDismiss: () -> Void
    let onDelete: () -> Void
    
    @State private var text: String = ""
    @State private var importance: Importance = .ordinary
    
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
        .onAppear() {
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
    
    // The color picker is circular and bigger on purpose, smaller one is hard to select.
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
                onSave(
                    ToDoItem(
                        id: toDoItem.id,
                        text: plainText,
                        importance: importance,
                        dueDate: newDueDate,
                        color: isColorToggled ? color.hex : nil,
                        isCompleted: toDoItem.isCompleted,
                        dateCreated: toDoItem.dateCreated,
                        dateEdited: Date()
                    )
                )
            } else {
                onSave(
                    ToDoItem(
                        text: plainText,
                        importance: importance,
                        dueDate: newDueDate,
                        color: isColorToggled ? color.hex : nil
                    )
                )
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
        }
    }
    
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
            importance = .ordinary
            dueDate = Date(timeIntervalSinceNow: 86400)
            isDueDateToggled = false
            isDatePickerShown = false
            isColorToggled = false
        }
    }
}

#Preview {
    ToDoItemDetail(
        editingToDoItem: .constant(FileCache.mock[0]),
        onSave: { _ in },
        onDismiss: {},
        onDelete: {}
    )
}