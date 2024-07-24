import Foundation
import LoggerPackage

extension Task where Failure == Error {
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        minDelay: TimeInterval = 2,
        maxDelay: TimeInterval = 120,
        factor: Double = 2,
        jitter: Double = 0.05,
        maxAttempts: Int = 6,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            var attempt = 0
            var delay = minDelay
            
            while attempt < maxAttempts {
                do {
                    if attempt != 0 {
                        Logger.logVerbose("Attempt \(attempt + 1) of retying data task.")
                    }
                    
                    return try await operation()
                } catch {
                    if attempt != 0 {
                        Logger.logVerbose("Attempt \(attempt + 1) failed.")
                    }
                    
                    attempt += 1
                    if attempt >= maxAttempts {
                        throw error
                    }
                    
                    let jitterValue = delay * jitter * Double.random(in: -1...1)
                    let delayWithJitter = delay + jitterValue
                    delay = min(delay * factor, maxDelay)
                    
                    try await Task<Never, Never>.sleep(for: .seconds(delayWithJitter))
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}
