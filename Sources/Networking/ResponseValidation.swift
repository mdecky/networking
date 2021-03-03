
import Combine
import Foundation

public protocol ResponseValidation {
    func validate<Request: Requestable>(
        request: Request, response: URLResponse, data: Data) ->
    AnyPublisher<Data, Error>
}

final class HTTPResponseValidator: ResponseValidation {
    let isCustomError: (HTTPURLResponse) -> Bool
    
    init(isCustomError: @escaping (HTTPURLResponse) -> Bool = { $0.statusCode == 400 }) {
        self.isCustomError = isCustomError
    }
    
    func validate<Request: Requestable>(
        request: Request, response: URLResponse, data: Data) ->
    AnyPublisher<Data, Error>
    {
        Just((request: request, response: response, data: data))
            .tryMap { output -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(URLError.Code.badServerResponse)
                }
                if self.isCustomError(httpResponse),
                   let customErrorProvider = request as? CustomResponseErrorProvider {
                    throw customErrorProvider.error(for: data, response: response)
                }
                guard httpResponse.isSuccesfulResponse else {
                    throw HTTPValidationError(response: httpResponse, data: output.data)
                }

                return data
            }
            .eraseToAnyPublisher()
    }
}

struct HTTPValidationError: Error, CustomDebugStringConvertible {
    let response: HTTPURLResponse
    let data: Data

    var debugDescription: String {
        "Request failed on validation with response: \(response) and data in base64: \(data.base64EncodedString())"
    }
}

private extension HTTPURLResponse {
    var isSuccesfulResponse: Bool {
        (200..<300).contains(statusCode)
    }
}
