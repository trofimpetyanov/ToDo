import Foundation

extension Date {
    var dayMonthFormatted: String {
        self.formatted(.dateTime.day().month(.wide).locale(.init(identifier: "ru_RU")))
    }
}
