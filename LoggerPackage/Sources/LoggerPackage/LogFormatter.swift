import Foundation
import CocoaLumberjack

/// A custom log formatter for formatting log messages with CocoaLumberjack.
public class LogFormatter: NSObject, DDLogFormatter {
    private let dateFormatter: DateFormatter
    
    /// Initializes a new instance of `LogFormatter`./
    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        super.init()
    }
    
    /// Formats the provided log message into a readable string.
    ///
    /// - Parameter logMessage: The log message object containing the message and metadata.
    /// - Returns: A formatted string representation of the log message.
    public func format(message logMessage: DDLogMessage) -> String? {
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
