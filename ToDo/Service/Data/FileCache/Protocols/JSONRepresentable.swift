import Foundation

@MainActor
protocol JSONRepresentable {
    var json: Any { get }
    
    static func parse(json: Any) -> Self?
}
