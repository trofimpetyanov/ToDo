import Foundation

protocol APIRequest: Sendable {
    associatedtype Response
    
    var path: String { get }
    var method: String { get }
    var request: URLRequest { get }
    
    var data: Data? { get }
    var revision: UInt32 { get }
    
    var token: String { get }
}

extension APIRequest {
    var method: String { "GET" }
    var host: String { "hive.mrdekk.ru" }
}

extension APIRequest {
    var data: Data? { nil }
}

extension APIRequest {
    var request: URLRequest {
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = host
        components.path = path
        
        var request = URLRequest(url: components.url!)
        
        request.httpMethod = method
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let data = data {
            request.httpBody = data
            request.addValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}

extension APIRequest {
    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }
}
