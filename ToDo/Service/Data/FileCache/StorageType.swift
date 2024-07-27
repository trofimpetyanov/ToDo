import Foundation
import SwiftUI

enum StorageType: String, CaseIterable {
    case file
    case swiftData
    case sqlite
}

extension StorageType: Identifiable, Hashable {
    var id: Int {
        hashValue
    }
}

extension StorageType {
    var title: String {
        switch self {
        case .file: "Файл"
        case .swiftData: "SwiftData"
        case .sqlite:  "SQLite"
        }
    }
    
    var imageName: String {
        switch self {
        case .file: "doc"
        case .swiftData: "swiftdata"
        case .sqlite: "square.2.layers.3d.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .file: .pink
        case .swiftData: .gray
        case .sqlite: .cyan
        }
    }
}
