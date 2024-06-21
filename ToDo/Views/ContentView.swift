import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(FileCache.mock) { toDo in
                Label(
                    title: { Text(toDo.text) },
                    icon: { Image(systemName: toDo.isCompleted ? "checkmark.circle.fill" : "circle") }
                )
            }
            .navigationTitle("ToDos")
        }
    }
}

#Preview {
    ContentView()
}
