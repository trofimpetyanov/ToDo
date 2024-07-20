import Foundation

extension Date {
    var clean: Date {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let date = Calendar.current.date(from: dateComponents)
        
        return date!
    }
}

extension Date? {
    var clean: Date? {
        guard let self = self else { return nil }
        
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let date = Calendar.current.date(from: dateComponents)
        
        return date
    }
}
