import SwiftUI
import SwiftData

struct CategoryDetail: View {
    @Environment(\.modelContext) private var context

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
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    NavigationStack {
        CategoryDetail(onDismiss: { })
    }
}
