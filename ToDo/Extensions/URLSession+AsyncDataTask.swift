import Foundation
import LoggerPackage

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            guard !Task.isCancelled else {
                continuation.resume(throwing: CancellationError())
                Logger.logInfo("Data Task was cancelled.")
                
                return
            }
            
            let task = self.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    
                    Logger.logError("Data Task error: \(error.localizedDescription)")
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                    
                    Logger.logInfo("Data Task completed successfully.")
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    
                    Logger.logError("Data Task error: Bad server response.")
                }
            }
            
            Task {
                await withTaskCancellationHandler {
                    task.resume()
                } onCancel: {
                    task.cancel()
                }
            }
        }
    }
}
