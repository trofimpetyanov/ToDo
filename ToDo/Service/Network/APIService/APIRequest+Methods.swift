import Foundation
import LoggerPackage

extension APIRequest where Response: Decodable & Sendable {
    func send() async throws -> Response {
        try await Task.retrying {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIRequestError.requestFailed
            }

            if let error = APIRequestError(rawValue: httpResponse.statusCode) {
                throw error
            } else if httpResponse.statusCode != 200 {
                throw APIRequestError.requestFailed
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(Response.self, from: data)
        }.value
    }
}

extension APIRequest {
    func send() async throws {
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIRequestError.requestFailed
        }
        
        if let error = APIRequestError(rawValue: httpResponse.statusCode) {
            throw error
        } else if httpResponse.statusCode != 200 {
            throw APIRequestError.requestFailed
        }
    }
}

extension Task where Failure == Error {
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        minDelay: TimeInterval = 2,
        maxDelay: TimeInterval = 120,
        factor: Double = 2,
        jitter: Double = 0.05,
        maxRetryCount: Int = 6,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            var attempts = 0
            var delay = minDelay
            
            while attempts < maxRetryCount {
                do {
                    return try await operation()
                } catch {
                    attempts += 1
                    if attempts >= maxRetryCount {
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
