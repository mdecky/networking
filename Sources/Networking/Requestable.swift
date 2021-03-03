
import Foundation

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}

public struct EmptyResponse: Decodable {}

public protocol Requestable {
    associatedtype Response: Decodable

    var path: String { get }
    var method: HTTPMethod? { get }
    var parameters: ParametersEncoding? { get }
    var customHeaders: [String: String]? { get }
}

public protocol CustomResponseErrorProvider {
    func error(for data: Data?, response: URLResponse) -> Error
}

extension Requestable {
    public var customHeaders: [String: String]? { return nil }

    public func urlRequest(baseURL: URL) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL), url.isValid else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method?.rawValue
        if let parameters = parameters {
            request = try parameters.encodeParameters(into: request)
        }

        if let customHeaders = customHeaders {
            for header in customHeaders {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        return request
    }
}

extension URL {
    var isValid: Bool {
        let hasValidScheme = (scheme != nil && scheme != "")
        return hasValidScheme || port != nil
    }
}
