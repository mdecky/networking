
import Foundation

public protocol ParametersEncoding {
    func encodeParameters(into request: URLRequest) throws -> URLRequest
}

public final class JSONBodyParameters<Parameters: Encodable>: ParametersEncoding {
    let parameters: Parameters

    private let jsonEncoder: JSONEncoder

    public init(_ parameters: Parameters, jsonEncoder: JSONEncoder = .init()) {
        self.parameters = parameters
        self.jsonEncoder = jsonEncoder
    }

    public func encodeParameters(into request: URLRequest) throws -> URLRequest {
        var request = request
        let body = try jsonEncoder.encode(parameters)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }
}

public final class URLQueryParameters: ParametersEncoding {
    let parameters: [String: CustomStringConvertible]

    public init(_ parameters: [String: CustomStringConvertible]) {
        self.parameters = parameters
    }

    public func encodeParameters(into request: URLRequest) throws -> URLRequest {
        guard !parameters.isEmpty else { return request }
        guard let url = request.url else {
            throw URLError(.badURL)
        }

        var request = request
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        components?.queryItems = parameters
            .map { URLQueryItem(name: $0.key, value: $0.value.description) }
        request.url = components?.url

        return request
    }
}
