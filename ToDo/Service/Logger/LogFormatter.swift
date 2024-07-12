import Foundation
import CocoaLumberjackSwift

class LogFormatter: NSObject, DDLogFormatter {
    private let dateFormatter: DateFormatter
    
    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        super.init()
    }
    
    func format(message logMessage: DDLogMessage) -> String? {
        let dateAndTime = dateFormatter.string(from: logMessage.timestamp)
        let logLevel: String
        
        switch logMessage.flag {
        case .debug: logLevel = "DEBUG"
        case .info: logLevel = "INFO"
        case .warning: logLevel = "WARNING"
        case .error: logLevel = "ERROR"
        default: logLevel = "VERBOSE"
        }
        
        let fileName = (logMessage.file as NSString).lastPathComponent
        let lineNumber = logMessage.line
        let logMessage = logMessage.message
        
        return "[\(dateAndTime)] [\(logLevel)] [\(fileName): \(lineNumber)] - \(logMessage)"
    }
}
