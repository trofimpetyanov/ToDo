import Foundation

extension APIRequest where Response: Decodable {
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
        let decoded = try decoder.decode(Response.self, from: data)
        
        return decoded
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
