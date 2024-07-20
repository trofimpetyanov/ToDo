import Foundation

enum APIRequestError: Int, Error {
    case badRevision = 400
    case authFailed = 401
    case itemNotFound = 404
    case serverError = 500
    case requestFailed = -1
}
