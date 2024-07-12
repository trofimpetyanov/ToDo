import SwiftUI
import SwiftData

struct CategoryDetail: View {
    @Environment(\.modelContext) private var context

    let onSave: (Category) -> Void
    let onDismiss: () -> Void
    
    @State var text: String = ""
    @State var color: Color = .red
    
    @State var isColorPickerPresented = false
    
    var body: some View {
        Form {
            TextField("Название", text: $text)
            
            colorRow
        }
        .navigationTitle("Категория")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.backPrimary)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 56)
        .onAppear {
            Logger.logInfo("CategoryDetail appeared.")
        }
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
    
    private var colorRow: some View {
        HStack {
            Text("Цвет")
            
            Spacer()
            
            Circle()
                .fill(color)
                .frame(width: 24, alignment: .center)
                .offset(x: -12)
                .padding(.leading, 16)
                .onTapGesture {
                    isColorPickerPresented = true
                }
                .onChange(of: isColorPickerPresented) { _, newValue in
                    Logger.logInfo("Color picker \(newValue ? "appeared" : "disappeared").")
                }
        }
        .sheet(isPresented: $isColorPickerPresented) {
            ColorWheelPicker(color: $color)
                .presentationDetents([.fraction(3/5)])
                .presentationDragIndicator(.visible)
                .background(AppColors.backPrimary)
        }
    }
    
    private var saveButton: some View {
        Button("Сохранить") {
            let plainText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let category = Category(name: plainText, color: color.hex)
            
            context.insert(category)
            
            onSave(category)
            onDismiss()
            
            Logger.logDebug("Category saved: \(category.id).")
        }
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    private var cancelButton: some View {
        Button("Отменить") {
            onDismiss()
            
            Logger.logInfo("CategoryDetail dismissed.")
        }
    }
    
    private var hideButton: some View {
        Button("Скрыть", systemImage: "keyboard.chevron.compact.down") {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            Logger.logDebug("Hiding keyboard.")
        }
    }
}

#Preview {
    NavigationStack {
        CategoryDetail(onSave: { _ in }, onDismiss: { })
    }
}
