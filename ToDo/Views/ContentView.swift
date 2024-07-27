import SwiftUI

struct ContentView: View {
    @State var toDoItemsStore: ToDoItemsStore
    
    var body: some View {
        TabView {
            ToDoItemsList(toDoItemsStore: toDoItemsStore)
                .tabItem { Label("Мои Дела", systemImage: "checklist") }
            
            SettingsView()
                .tabItem { Label("Настройки", systemImage: "gear") }
        }
    }
}

#Preview {
    ContentView(toDoItemsStore: .init(modelContainer: .mock))
}
