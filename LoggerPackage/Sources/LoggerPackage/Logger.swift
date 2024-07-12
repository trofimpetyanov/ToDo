import Foundation
import CocoaLumberjackSwift

/// A utility struct for configuring and using logging functionality with CocoaLumberjack.
public struct Logger {
    
    /// Sets up the logging configuration based on the build configuration.
    ///
    /// In `DEBUG` mode, configures logging to output to the console.
    /// In non-`DEBUG` mode, configures logging to output to a file.
    public static func setup() {
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
    
    /// Logs a verbose level message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file where the log message originated (default is `#file`).
    ///   - function: The function where the log message originated (default is `#function`).
    ///   - line: The line number where the log message originated (default is `#line`).
    public static func logVerbose(_ message: DDLogMessageFormat, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogVerbose(message, file: file, function: function, line: line)
    }
    
    /// Logs a debug level message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file where the log message originated (default is `#file`).
    ///   - function: The function where the log message originated (default is `#function`).
    ///   - line: The line number where the log message originated (default is `#line`).
    public static func logDebug(_ message: DDLogMessageFormat, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogDebug(message, file: file, function: function, line: line)
    }
    
    /// Logs an info level message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file where the log message originated (default is `#file`).
    ///   - function: The function where the log message originated (default is `#function`).
    ///   - line: The line number where the log message originated (default is `#line`).
    public static func logInfo(_ message: DDLogMessageFormat, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogInfo(message, file: file, function: function, line: line)
    }
    
    /// Logs a warning level message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file where the log message originated (default is `#file`).
    ///   - function: The function where the log message originated (default is `#function`).
    ///   - line: The line number where the log message originated (default is `#line`).
    public static func logWarning(_ message: DDLogMessageFormat, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogWarn(message, file: file, function: function, line: line)
    }
    
    /// Logs an error level message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file where the log message originated (default is `#file`).
    ///   - function: The function where the log message originated (default is `#function`).
    ///   - line: The line number where the log message originated (default is `#line`).
    public static func logError(_ message: DDLogMessageFormat, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        DDLogError(message, file: file, function: function, line: line)
    }
    
}
