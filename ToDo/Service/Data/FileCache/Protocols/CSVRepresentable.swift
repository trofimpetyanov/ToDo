import Foundation

@MainActor
protocol CSVRepresentable {
    var csv: String { get }
    
    static func parse(csv: String) -> Self?
}
