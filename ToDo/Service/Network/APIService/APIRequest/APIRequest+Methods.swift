import Foundation
import LoggerPackage

extension APIRequest where Response: Decodable & Sendable {
    func send() async throws -> Response {
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
        
    }
}

extension APIRequest {
    func send() async throws {
        let (_, response) = try await URLSession.shared.dataTask(for: request)
        
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
