import Foundation

extension Date {
    
    /// Initializes a `Date` from a given `Any` type representing a time interval since 1970.
    ///
    /// This initializer attempts to parse the input as either a `TimeInterval` or a `String`
    /// that can be converted to a `TimeInterval`.
    ///
    /// - Parameter anyTimeIntervalSince1970: The value to parse, which can be of type `TimeInterval` or `String`.
    init?(anyTimeIntervalSince1970: Any?) {
        if let dueDateInterval = anyTimeIntervalSince1970 as? TimeInterval {
            self.init(timeIntervalSince1970: dueDateInterval)
        } else if let anyTimeIntervalSince1970 = anyTimeIntervalSince1970 as? String,
                  let dueDateInterval = TimeInterval(anyTimeIntervalSince1970) {
            self.init(timeIntervalSince1970: dueDateInterval)
        } else {
            return nil
        }
    }
}
