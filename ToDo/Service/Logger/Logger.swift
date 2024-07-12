import Foundation
import CocoaLumberjackSwift

struct Logger {
    
    static func setup() {
        let logFormatter = LogFormatter()
        
        #if DEBUG
        // Console Logger.
        DDLog.add(DDOSLogger.sharedInstance)
        DDOSLogger.sharedInstance.logFormatter = logFormatter
        
        #else
        // File Logger.
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 0
        fileLogger.maximumFileSize = 1 * 1024 * 1024
        fileLogger.logFileManager.maximumNumberOfLogFiles = 2
        fileLogger.logFormatter = logFormatter
        DDLog.add(fileLogger)
        
        #endif
    }
    
    static func logVerbose(_ message: DDLogMessageFormat, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogVerbose(message, file: file, function: function, line: line)
    }
    
    static func logDebug(_ message: DDLogMessageFormat, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogDebug(message, file: file, function: function, line: line)
    }
    
    static func logInfo(_ message: DDLogMessageFormat, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogInfo(message, file: file, function: function, line: line)
    }
    
    static func logWarning(_ message: DDLogMessageFormat, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogWarn(message, file: file, function: function, line: line)
    }
    
    static func logError(_ message: DDLogMessageFormat, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogError(message, file: file, function: function, line: line)
    }
    
}
