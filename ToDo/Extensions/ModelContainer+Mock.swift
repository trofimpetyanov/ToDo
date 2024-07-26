import Foundation
import SwiftData

extension ModelContainer {
    // swiftlint:disable:next force_try
    static let mock = try! ModelContainer(for: ToDoItem.self, configurations: .init())
}
