
import Combine
import Foundation

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}

public struct EmptyResponse: Decodable {}

/// Protocol defining a HTTP request
public protocol Request {
    /// Response type for this request
    associatedtype Response: Decodable

    /// Path for request url
    var path: String { get }
    /// HTTP method used for request
    var method: HTTPMethod { get }
    /// Parameters that will be encoded into the request
    var parameters: ParametersEncoder? { get }
    /// Custom HTTP headers that will be encoded into request
    var customHeaders: [String: String]? { get }
}

public protocol CustomResponseErrorProvider {
    func error(for data: Data?, response: URLResponse) -> Error
}

extension Request {
    public var parameters: ParametersEncoder? { return nil }
    public var customHeaders: [String: String]? { return nil }

    public func urlRequest(baseURL: URL) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL), url.isValid else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
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
